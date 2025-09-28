# The contents of JNIPort_Docs.zip and JNIPort_Extras.zip

The [JNIPort for VisualWorks download](file-cabinet.md) contains two zip archives. When you load the bundle "JNIPort" from a Store repository into a VisualWorks image, the two archives will be saved in your file system. It depends on the Store settings if you will be prompted for a location to store them, or if they are saved to the directory which you have configured in the settings.

## JNIPort_Docs.zip

This archive contains a folder called "Docs". It contains the complete documentation for the Dolphin Smalltalk version of JNIPort. Extract the archive to any location you like. Open the file Docs/JNIPort.html to start reading.

## JNIPort_Extras.zip

This archive contains a folder "Extras". It contains the following files which you need if you want to make use of all features of JNIPort:

| File              | Description |
| ----------------- | ----------- |
| JNIPort.jar       | This archive contains Java classes needed for implementing callbacks from Java to Smalltalk, and a patch needed for using the JRockit VM. |
| JNIPort.zip       | The archive contains the Java source code for the classes in JNIPort.jar |
| JNIPort-Tests.jar | The archive contains Java classes needed for running the Unit Tests for JNIPort. |
| JNIPort-Tests.zip | The archive contains the Java source code for the classes in JNIPort-Tests.jar |
| DolphinJNIHelper.dll | A dynamic library which is needed for avoiding deadlocks when you use the JNI hooks for monitoring messages from the Java VM, and when the Java code which you execute may run in a different thread. In all other circumstances, this library is not needed. See the page called "The JNIHelper DLL" in Chris Uppal's documentation for more details. The DLL is currently available for Windows only. |
| DolphinJNIHelper.zip | The source code for DolphinJNIHelper.dll. This is needed if you want to compile the library yourself, or port it to another platform. |