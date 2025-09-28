# JavaWrapperGeneratorSettings

The `JavaWrapperGeneratorSettings` control which methods will be generated for a new predefined wrapper class. These settings are only used at development time, you do not need them in a runtime system. They let you control in detail which methods and fields of a Java class are made accessible by generating Smalltalk methods for them. The default settings generate methods for public methods, fields, and constructors. The JNI lets you use private and protected methods and fields too. The different flags are explained in the comments of the methods in the 'accessing' protocol of JavaWrapperGeneratorSettings. The JavaWrapperGeneratorSettings are accessed by sending `wrapperGeneratorSettings` to an instance of `JVMSettings`.

Code snippets

```smalltalk
| wrapperGeneratorSettings |
wrapperGeneratorSettings := JVMSettings default wrapperGeneratorSettings.
wrapperGeneratorSettings includePrivateMethods: true.
```