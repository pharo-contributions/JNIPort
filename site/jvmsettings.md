# JVMSettings

## The class JVMSettings

An instance of JVMSettings is a configuration for a JVM. It has a name and a list of sub-settings for different aspects of the JVM together with accessor methods to retrieve them. The class JVMSettings holds onto a template which is copied to create a new instance. The template is created when the class JVMSettings is initialized after loading JNIPort into the image. It is stored in the class instance variable named template.

The class also stores an OrderedCollection of predefined instances in the class instance variable named predefined. After loading JNIPort, the OrderedCollection contains one instance with default settings. You can register your own predefined instances for later use. The first element in predefined is the default instance. By inserting an instance as the first one in predefined, it becomes the default instance.

The predefined instances and the template can be stored in and loaded from a registry, such that you can migrate them between images. On Windows, this is the normal Windows registry. On other platforms, it is a directory called .registry in your home directory. The path to the JNIPort settings in the registry is

`HKEY_CURRENT_USER\Software\Metagnostic\JNIPort\Predefined settings`

You can of course change the settings both of the template and the default instance if you need to customize them. It is also possible to store the settings in a different location in the registry. See the implementation of the JVMSettings class method saveToRegistry for an example.

### Code snippets

```smalltalk
JVMSettings default. "Answers the default settings."
JVMSettings predefined. "Answers the list of predefined instances."
JVMSettings named: 'My settings'. "Answers the predefined instance named 'My settings' "
JVMSettings saveToRegistry. "Saves the template and predefined instances to the registry."
JVMSettings loadFromRegistry. "Loads the template and predefined instances from the registry."
```

## Creating a JVMSettings

You can create a new instance of JVMSettings either by copying the template (JVMSettings new), or by copying another instance (someInstance deepCopy). A new JVMSettings instance can be added to the list of predefined instances by sending the message addSettings: to the class JVMSettings. The class method addSettingsNamed: creates a new instance copied from the template and registers it as a predefined instance.

You can tell a JVMSettings whether the JVM will generate "ghost classes". Ghost classes are Smalltalk classes which act as wrappers for Java classes, and which are generated on the fly whenever an instance of a Java class is encountered for which no wrapper class has been defined. It is possible to work without ghost classes, but it is easier to get started by selecting "Generate ghost classes". While this is technically a property of the JNIPortSettings, it is easiest to send usesGhosts: to the JVMSettings.

### Code snippets

```smalltalk
"Create a deep copy of the default instance."
settings := JVMSettings default deepCopy.
"Create a deep copy of the template, which may have different settings  than the default, set its name and configure it to use ghost classes."
settings := JVMSettings new.
settings name: 'My settings'; usesGhosts: true.
"Register it as predefined."
JVMSettings addSettings: settings.
"Create a new predefined instance in one step."
JVMSettings addSettingsNamed: 'My settings'.
```