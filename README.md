# About JNIPort

## Introduction

JNIPort is a Smalltalk library which allows Java code to be invoked from Smalltalk. It acts as a bridge between the world of Smalltalk objects and a Java Virtual Machine (JVM) where Java code is executing. With JNIPort you can:

- Supplement Smalltalk's libraries with Java libraries.
- Use the normal (to a Smalltalker) interactive way of playing with objects and code in workspaces to learn about and prototype Java operations.
- Continue to use your legacy Java code as you migrate to a more grown-up language…;-)

## Documentation

See [Documentation](site/index.md) for detailed documentation

## Get JNIPort

See [Downoads](site/file-cabinet.md)

## How it works

You talk to a Java object via a Smalltalk object that acts as a proxy for it. You can call Java methods via the proxy using a lowish-level API where you have to tell the proxy what the method name is, what the argument types are, and so on. Alternatively you can use a higher level of wrapper methods that are either statically generated, or created dynamically.

Java classes are represented explicitly by wrapper objects (called class statics), so each proxy for a Java instance has both a Smalltalk class and a reference to the (shared) class static. The Smalltalk class defines the wrapper methods for calling the Java object's methods, and accessing its fields. The class static is the single member of a different Smalltalk class that has methods for using the “static” methods and fields of the Java class. The class static also has methods corresponding to the Java class's constructors, so it acts as a factory for new instances. (That means that from the point of view of a JNIPort programmer, Java classes really are objects!)

## What it does not do

A few warnings before you start to expect too much:

- JNIPort does not provide complete interoperability between Java and Smalltalk. For instance it is not possible to create Smalltalk subclasses of Java classes (or the other way around).
- The facilities for calling back from Java into Smalltalk are weak, slow, and clunky.
- JNIPort allows proper interaction with Java objects but it cannot magically give you the ability to redefine Java classes interactively too.
- Deploying applications based on a mixture of Java and Smalltalk may be a somewhat challenging. For instance, needed wrapper classes must not be removed during runtime creation, even when they are not referenced anywhere in the Smalltalk code.

## Supported platforms

JNIPort was originally written by Chris Uppal for [Dolphin Smalltalk](http://www.object-arts.com/) and published under a [liberal license](LICENSE.md) which permits its use in commercial and non-commercial software.

Joachim Geidel has ported JNIPort to [VisualWorks](http://www.cincomsmalltalk.com/) and [Pharo](http://www.pharo-project.org/).

JNIPort has been ported to VA Smalltalk by Ben van Dijk, Adriaan van Os and Rolf van der Vleuten. The VASt version is available from [VAStGoodies.com](https://vastgoodies.com/projects/JNIPort).
