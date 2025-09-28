# Running the JNIPort tests in VisualWorks

## Prerequisites

### SUnitToo

The tests in the bundle JNIPort Tests are written using the SUnitToo test framework. SUnitToo is a variant of SUnit, and it is included in the VisualWorks distribution as a parcel in the directory $(VISUALWORKS)/Contributed. For documentation of SUnitToo, please read the parcel's comment after loading it. SUnitToo is a prerequisite of the bundle JNIPort Tests, so it will be loaded automatically when you load JNIPort Tests.

You should also load the package SUnitToo(ls), which can be found in `$(VISUALWORKS)/Contributed`. It is a prerequisite of the JNIPort Tools bundle and will be loaded when you load the tools. If you don't want the JNIPort tools, you will have to load SUnitToo(ls) manually. SUnitToo(ls) adds buttons at the bottom of the Refactoring Browser which let you run and debug the tests. You can select one or more bundles or packages to run all test in all subclasses of TestCase in those bundles or packages. Select one or more classes to run all tests in them. You can also select one or more test methods to run specific tests. For more details on how to use SUnitToo, see the package comments of SUnitToo and SUnitToo(ls).

### JAR files

To run the tests, you need the bundle JNIPort and the files JNIPort.jar and JNIPort-Tests.jar from the archive JNIPort_Extras.zip which is part of the JNIPort bundle (version 0.50 or later). Both jar files must be on the Java classpath.

One way to ensure this is to add the files to the classpath in the JVM settings. If you have loaded the bundle `JNIPort Tools`, you can define the classpath in the JNIPort settings tool. In this case, where the classpath is defined as a runtime parameter for the Java virtual machine, the path separator is the semicolon (`;`) on MS Windows, but a colon (`:`) on Linux and MacOS-X. It may be easier to use absolute paths on Linux.

MS Windows with jar files in the working directory:

```
.;JNIPort.jar;JNIPort-Tests.jar
```

Linux, MacOS-X with jar files somewhere else:

```
.:/insert_path_here/JNIPort.jar:/insert_path_here/JNIPort-Tests.jar
```

Another option is to set the CLASSPATH environment variable. In this case, the path separator is always the semicolon (;). If you have copied the two jar files to the working directory, you may set the CLASSPATH like this:

```
CLASSPATH=.;JNIPort.jar;JNIPort-Tests.jar
```

The source code for the classes in JNIPort-Tests.jar is in the corresponding zip file `JNIPort-Tests.zip`. You don't need the source code for running the tests.

## Running the tests

To run the tests in the bundle "JNIPort Tests" using SUnitToo(ls), execute

```smalltalk
JVM default
```

in a workspace, which initializes a running Java VM, or start a JVM from the JNIPort Settings tool. When the JVM is running, select the bundle `JNIPort Tests` in the Refactoring Browser and execute all tests in the bundle by clicking on the "run" button at the bottom of the browser window.

The tests for wrapper generation and for callbacks from Java will report errors when the default JVM configuration is used. You have to use a JVM configured for wrapper generation and callbacks to run them.