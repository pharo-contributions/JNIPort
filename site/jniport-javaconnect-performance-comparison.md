# Performance Comparison

Johan Brichau has [compared the performance of JavaConnect 2.0-beta and JNIPort](https://web.archive.org/web/20120331171815/http://www.info.ucl.ac.be:80/~jbrichau/javaconnect.html) (1.5 or earlier, he didn't name the version). He found that JNIPort was slow when looking up Java classes. This has changed with JNIPort 1.6. A smaller part of the effect was actually due to the fact that he used Strings for class names instead of Symbols, but most of the time was actually lost in a single non-local return statement from a critical block in JavaClassIndex>>findClass:

```smalltalk
symbol := aClassName asSymbol.
sharedMutex critical: [index at: symbol ifPresent: [:it | ^ it]].
```
Replacing this with

```smalltalk
symbol := aClassName asSymbol.
classStatic := sharedMutex critical: [index at: symbol ifAbsent: [nil]].
classStatic notNil ifTrue: [^classStatic].
```

led to a significant speedup. Together with some other optimizations, the speedup in JNIPort 1.6 leads to JNIPort now being faster than JavaConnect 2.0-beta.

Before looking at time, please keep in mind that the performance of your application will not be influenced very much by the speed of JNIPort. If it is, then think about the design of your code. Reducing the number of calls from Smalltalk to Java will have a much larger effect than any performance improvements in JNIPort or JavaConnect can have. The people at CodeMesh explain this very nicely.

Joachim Geidel has reproduced Johan's tests on a MacBook Pro with a 2.4 GHz Intel Core 2 Duo, 4 GB 667 MHz DDR2 SDRAM, and Mac OS X 10.5.8. The VisualWorks version was 7.7. The Java runtime has the following versions:

> java.vm.version: 1.5.0_20-141\
java.runtime.version: 1.5.0_20-b02-315

To make sure that garbage collection doesn't interfere too much on the Smalltalk side, he made NewSpace larger by a factor of 10, and also doubled all other space sizes:

```smalltalk
ObjectMemory sizesAtStartup: #(10.0 10.0 2.0 2.0 2.0 2.0 2.0)
```

Joachim also increased growthRegimeUpperBound to 500 MB such that OldSpace garbage collection is not an issue. For each test, he started the image, started the Java VM, and ran three repetitions of the test code separated by two global garbage collections after each repetition. The absolute times are higher than in Johan's tests, which is probably due to the hardware used.

Here are the results:

| Example                  | JavaConnect Time (ms) | JNIPort 1.6 Time (ms) |
| ------------------------ | --------------------- | --------------------- |
| [Example 1](#example-1)  | 4761, 4531, 5505      | 2902, 2727, 2619      |
| [Example 2](#example-2)  | 4396, 4329, 4025      | 2001, 1905, 1937      |
| [Example 3](#example-3)  | 1633, 1653, 1654      | 1713, 1637, 1575      |
| [Example 3](#example-3)  | 1633, 1653, 1654      | 1713, 1637, 1575      |
| [Example 4](#example-4)  | 998, 1034, 1020       | 1081, 1027, 1040      |
| [Example 5](#example-5)  | 76182, 83766, 69253   | 23203 18541 18183     |
| [Example 6](#example-6)  | 43199, 36090, 40820   | 11892, 11182, 11048   |
| [Example 7](#example-7)  | 8715, 10815, 9694     | 6283, 5778, 5822      |
| [Example 8](#example-8)  | 8896, 11000, 9899     | 5954, 5569, 5558      |
| [Example 9](#example-9)  |   10748, 13383, 16518, 15875<br>2nd round:<br>11245, 9637, 18830, 6461 	     |  5608, 4804, 4782, 4802<br>2nd round:<br>5708, 4785, 4770, 4780    |

  
## Code

### Example 1

JavaConnect

```smalltalk
Time millisecondsToRun: [
  1000000 timesRepeat: [
    JavaWorld.org.dmp.javaconnect.tests. ValueTypeTests main_StringArray: nil.
  ]
]
```

JNIPort

```smalltalk
Time millisecondsToRun: [
  1000000 timesRepeat: [
    (JVM default findClass: #'org.dmp.javaconnect.tests.ValueTypeTests') main_StringArray: nil.
  ]
] 
```

### Example 2

JavaConnect

```smalltalk
| cl |
cl := JavaWorld.org.dmp.javaconnect.tests.
ValueTypeTests.
Time millisecondsToRun: [
1000000 timesRepeat: [
cl main_StringArray: nil
]]
```

JNIPort

```smalltalk
 | cl |
cl := (JVM default findClass: #'org.dmp.javaconnect.tests.ValueTypeTests').
Time millisecondsToRun: [
1000000 timesRepeat: [
cl main_StringArray: nil.
]] 	
```

### Example 3

JavaConnect

```smalltalk
Time millisecondsToRun: [
1000000 timesRepeat: [
JavaWorld.org.dmp.javaconnect.tests.
ValueTypeTests get_staticTest.
]] 
```

JNIPort

```smalltalk
Time millisecondsToRun: [
1000000 timesRepeat: [
(JVM default findClass: #'org.dmp.javaconnect.tests.ValueTypeTests') get_staticTest.
]] 
```

### Example 4

JavaConnect

```smalltalk
| cl |
cl := JavaWorld.org.dmp.javaconnect.tests.
ValueTypeTests.
Time millisecondsToRun: [
1000000 timesRepeat: [
cl get_staticTest.
]]
```

JNIPort

```smalltalk
| cl |
cl := (JVM default findClass: #'org.dmp.javaconnect.tests.ValueTypeTests').
Time millisecondsToRun: [
1000000 timesRepeat: [
cl get_staticTest.
]]
```

### Example 5

JavaConnect

```smalltalk
Time millisecondsToRun: [
500000 timesRepeat: [
JavaWorld.org.dmp.javaconnect.tests.
ReferenceTypeTests new returnsClassB.
]]
```

JNIPort

```smalltalk
Time millisecondsToRun: [
500000 timesRepeat: [
(JVM default findClass: #'org.dmp.javaconnect.tests.ReferenceTypeTests') new_null returnsClassB_null.
]]
```

### Example 6

JavaConnect

```smalltalk
| i |
i := JavaWorld.org.dmp.javaconnect.tests.
ReferenceTypeTests new.
Time millisecondsToRun: [
500000 timesRepeat: [
i returnsClassB.
]]
```

JNIPort

```smalltalk
| i |
i := (JVM default findClass: #'org.dmp.javaconnect.tests.ReferenceTypeTests') new_null.
Time millisecondsToRun: [
500000 timesRepeat: [
i returnsClassB_null.
]]
```

### Example 7

JavaConnect

```smalltalk
Time millisecondsToRun: [
100000 timesRepeat: [
| object |
object := JavaWorld.org.dmp.javaconnect.tests.
ClassAndObjectTests new.
JavaWorld.org.dmp.javaconnect.tests.
ClassAndObjectTests returnSameObject_Object:
object]]
```

JNIPort

```smalltalk
Time millisecondsToRun: [
100000 timesRepeat: [
| object |
object := (JVM default findClass: #'org.dmp.javaconnect.tests.ClassAndObjectTests') new.
(JVM default findClass: #'org.dmp.javaconnect.tests.ClassAndObjectTests') returnSameObject_Object: object
]]
```

### Example 8

JavaConnect

```smalltalk
| cl |
cl := JavaWorld.org.dmp.javaconnect.tests.
ClassAndObjectTests.
Time millisecondsToRun: [
100000 timesRepeat: [
object := cl new.
cl returnSameObject_Object: object
]]
```

JNIPort

```smalltalk
 | cl |
cl := (JVM default findClass: #'org.dmp.javaconnect.tests.ClassAndObjectTests').
Time millisecondsToRun: [
100000 timesRepeat: [
object := cl new.
cl returnSameObject_Object: object
]] 
```

### Example 9

JavaConnect

```smalltalk
Time millisecondsToRun:
[5000 timesRepeat:
[| line_count char_count word_count buf s st |
line_count := 0.
char_count := 0.
word_count := 0.
buf := JavaWorld.java.io.BufferedReader
new_Reader: (JavaWorld.java.io.StringReader
new_String: 'JavaConnect allows to seamlessly use Java libraries in Smalltalk as if they were Smalltalk libraries.
Use it if you like it.').
[((s := buf readLine) = nil) not] whileTrue:
[line_count := line_count + 1.
st := JavaWorld.java.util.StringTokenizer
new_String: s String: ' ,;.'.
[st hasMoreTokens] whileTrue:
[word_count := word_count + 1.
s := st nextToken.
char_count := char_count + s length]]]]
```

JNIPort

```smalltalk
Time millisecondsToRun:
[5000 timesRepeat:
[| line_count char_count word_count buf s st
jvm |
jvm := JVM default.
line_count := 0.
char_count := 0.
word_count := 0.
buf := (jvm findClass: #'java.io.BufferedReader')
new_Reader:
((jvm findClass: #'java.io.StringReader')
new_String: 'JavaConnect allows to seamlessly use Java libraries in Smalltalk as if they were Smalltalk libraries.
Use it if you like it.').
[((s := buf readLine_null) = nil) not] whileTrue:
[line_count := line_count + 1.
st := (jvm findClass: #'java.util.StringTokenizer')
new_String: s String: ' ,;.'.
[st hasMoreTokens_null] whileTrue:
[word_count := word_count + 1.
s := st nextToken_null.
char_count := char_count + s length_null]]]] 
```
