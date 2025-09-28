# Names of Generated Wrapper Methods

The topmost level of JNIPort is capable of generating wrapper Smalltalk classes for existing Java classes. The wrapper class has automatically-generated methods that allow you to use the Java object as if it were a Smalltalk object.

The generated methods are of two kinds:

1. Forwarding methods that collect together their arguments and forward them to the corresponding method of the underlying Java object.
1. Accessor methods that read or set the fields of the underlying Java object.

In both cases, the name of the Smalltalk method is determined by following a set pattern. The rest of this section describes the pattern in detail, but first, here are a few examples:

Field access is via generated “getter” and “setter” methods:

Constructors are methods on the class static, here are some examples from java.lang.String:

| Java Field               | Generated getter | Generated setter |
| ------------------------ | ---------------- | ---------------- |
| int aField;              | #get_aField      |  #set_aField:    |
| final int aField;        | #get_aField      | —                |
| java.lang.String aField; | #get_aField      | #set_aField:     |


| Java Method | Generated selector<br>(JNIPort 2.0 and higher) | Generated selector<br>(JNIPort 1.9 and earlier, JNIPort for Dolphin Smalltalk) |
| ------------------------- | -------------------------- | -------------------------- |
| int size() {...}          |	#size                      | #size_null                 |
| void shutdown() {...}     | #shutdown                  | #shutdown_null             |
| void parse(java.lang.String msg) {...} | #parse_String:| #parse_String:             |
| void shutdown(java.lang.String msg, boolean urgent) {...} |  #shutdown_String:boolean: | #shutdown_String:boolean: |
| boolean check(java.net.URL[] urls) {...} | #check_URLArray: | #check_URLArray:  |



| String Constructor  | Generated selector <br>(JNIPort 2.0 and higher) | Generated selector <br> (JNIPort 1.9 and earlier, JNIPort for Dolphin Smalltalk)                |
| ------------------------- | ------------------------------ | ---------------------- |
| String()                  | #new                           | #new_null              |
| String(char ch)           | #new_char:                     | #new_char:             |
| String(java.lang.StringBuffer buffer) | #new_StringBuffer: | #new_StringBuffer:     |

## Names for Forwarding Methods

Given a Java class, each of its methods is fully identified by a combination of its name and its signature — the name alone is not enough (since method names can be overloaded). Hence, to identify a specific method, we need:

- The method's name.
- The method's return type.
- The types of all of the method's parameters, in order.

In practice, the method's return type can be ignored since Java does not allow overloading on return type (although the JVM itself does). So, we can think of a Java method's “full” name as being somehow composed of its normal name and the types of any arguments. The names of generated Smalltalk methods follow this thinking.

(By the way, if you are using a version of Java that supports so-called “generics” then you will need to know that generics are invisble to the Java runtime (they are merely a hack implemented entirely in the Java compiler), and so they are invisible to JNIPort too. The types seen by the Java runtime are what determine the correct names to use, and they are the names of the generic types after “erasure”.

The general pattern is that a Java method called, say, “aMethod()”, with arguments of types “Type1”, “Type2”, and “Type3”,

    int aMethod(Type1 a, Type2 b, Type3 c) { ... } 

will be represented by a Smalltalk method with selector #aMethod_Type1:Type2:Type3:. That is, the first keyword of the Smalltalk selector is the name of the Java method, followed by an underscore, '_', and then the type of the first argument. Subsequent keywords are just the types of the corresponding arguments.

In more detail:

JNIPort 1.9 and earlier, JNIPort for Dolphin Smalltalk: If the Java method is called aMethod(), say, then the Smalltalk method will be called: #aMethod_null. The '_null' is important since it prevents name clashes between native Smalltalk method names and generated Java methods with unrelated meanings.

JNIPort 2.0 and later: If the Java method is called aMethod(), then the Smalltalk method will be called: #aMethod.

If the Java method, called 'aMethod', has one or more arguments, then the Smalltalk method's selector will be formed by starting with 'aMethod_' and then appending a segment for each of the arguments. Each segment will be the name of that argument's type, simplified by following the rules below.

If the type is a primitive, then the segment will just be the name of that primitive. Note: the case is not changed, so a Java method like:

```java
int multiply(int n, int m) { ... } 
```
would be represented by a Smalltalk method called #multiply_int:int:.

If the type is a class or interface, then the segment is the short name of that class or interface (i.e. not fully qualified). E.g. a Java method like:

```java
void write(java.lang.String message, java.io.WriteStream out) { ... } 
```

would be represented by a Smalltalk method called #write_String:WriteStream:. Note that, again, the case of the type name is unchanged (and so does not follow conventional Smalltalk rules — again, this is necessary to avoid ambiguity).

If the type is an array type, then the segment is formed by appending 'Array' to the base-type name as many times as necessary. E.g: a Java method like:

```java
void aMethod(String[] strings, boolean[][] bitmaps) { ... } 
```

would be represented by a Smalltalk method called: #aMethod_StringArray:booleanArrayArray:.

## Names for Accessor Methods

Access to fields of Java objects is via generated Smalltalk accessor methods. Given a variable called 'aField', the generated getter and setter methods in Smalltalk are called #get_aField and set_aField: respectively. Fields declared to be “final” have no generated setter.

## Names for Static Members

Using static members (class side fields and methods) follows exactly the same pattern as instance-side members. The difference is that the Smalltalk methods are defined on a “class static” object that stands for the Java class. It's worth mentioning that, because of this, there is never any ambiguity between class-side and instance-side members.

## Names for Constructors

These are treated like static methods called “new”. E.g. the Java constructor for a `java.lang.String` from an array of chars:

```java
String(char[] chars) { ... } 
```
is represented by a method on the String class static called #new_charArray:

## Handling Ambiguity

It is possible for more than one Java method to map onto the same Smalltalk selector. It is impossible to fix the problem in general (without making the scheme too verbose or complicated to use), but the most common cases can be fixed.

One way ambiguity occurs is when there are two versions of a class or interface with the same name in different packages. If a method is overloaded to handle both of these cases (a not unreasonable situation) then JNIPort will try to generate two corresponding Smalltalk wrapper methods with the same selector. (Since the two argument types have the same short name). 

If JNIPort finds that it is generating two methods with the same selector, then it attempts to get around the problem as follows. Firstly it tries using the long forms of all the type names. So if the Java class had two methods like:

```java
void aMethod(org.whatever.Something) { ... }
void aMethod(org.wherever.Something) { ... }  
```

then JNIPort would generate a method called `#aMethod_Something:` that just threw an AmbiguousJavaMethodError exception. It would also generate two real forwarding methods with names `#aMethod_orgwhateverSomething:` and `#aMethod_orgwhereverSomething:` that forwarded to the corresponding methods. In this case the segment of the selector is made from the fully-qualified type name with any '`.`'s removed.

If that does not resolve the ambiguity then JNIPort will generate even longer selectors that also include the return type of the method, so that:

```java
int aMethod(org.whatever.Something) { ... }
double aMethod(org.what.ever.Something) { ... } 
```

would be wrapped as `#aMethod_int_orgwhateverSomething:` and `#aMethod_double_orgwhateverSomething:`.

This is already getting to the point of being unusable, so if even that doesn't work then JNIPort just gives up. In the current implementation, it will generate both wrapper methods in the longest form, and so one of them (arbitrarily chosen) will overwrite the other. It would probably be better if it didn't generate either of them in this case, so the current behaviour should be considered to be a bug.

Rather surprisingly, the JVM allows classes to have multiple fields with the same name, provided that they are of different declared types. The Java compiler won't let you do it, but it is perfectly legal for JVM classfiles. In this case JNIPort will use the same kinds of techniques as it does for avoiding ambiguous selectors for forwarding methods (arguably, this is overkill). So if the Java class had fields like (this is not legal Java):

```java
int aField;
double aField; 
```

then JNIPort will generate two getter methods with names: `#get_int_aField`, and `#get_double_aField`, and will generate a dummy getter, `#get_aField` that raises an AmbiguousJavaMethodError exception. Similarly for setter methods if there are any.

If this sort of thing happens to you in practice, then you can always fall back to the Java Base and write your own wrapper methods with whatever names you want.