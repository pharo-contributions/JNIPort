# Example - Writing to a log file with java.util.logging

The following code is an example of using the java.util.logging package. If you have started the JVM such that it creates ghost classes, you do not have to implement any Smalltalk classes or methods before using the Java classes.

If you evaluate this code in a VisualWorks workspace, the Compiler will warn you that there are no methods corresponding to the messages sent in the code. You can ignore these messages and proceed.

```Smalltalk
| jvm loggerStatic handlerStatic levelStatic logger handler |
"Get the current JVM."jvm := JVM current.
"Find the Java classes needed."
loggerStatic := jvm findClass: 'java.util.logging.Logger'.
handlerStatic := jvm findClass: 'java.util.logging.FileHandler'.
levelStatic := jvm findClass: 'java.util.logging.Level'.
"Create a new Logger."
logger := loggerStatic getLogger_String: 'VisualWorks'.
"Create a new FileHandler which writes to vwlog.txt."
handler := handlerStatic new_String: 'vwlog.txt'.
"Add the handler to the logger and set a logging level."
logger addHandler_Handler: handler.
logger setLevel_Level: levelStatic get_CONFIG.
"Add messages to the log."
logger severe_String: 'Arrgh...'.
logger info_String: 'Better now.'.
"Change the log level, and log this event, too."
logger log_Level: levelStatic get_CONFIG String: 'Log level changed' Object: levelStatic get_INFO.
logger setLevel_Level: levelStatic get_INFO.
```

The code above will create an XML file called vwlog.txt in your working directory with the following contents (with different timestamps, thread index, and encoding, of course):

```xml
<?xml version="1.0" encoding="windows-1252" standalone="no"?>
<!DOCTYPE log SYSTEM "logger.dtd">
<log>
	<record>
		<date>2008-02-17T14:43:08</date>
		<millis>1203255788984</millis>
		<sequence>0</sequence>
		<logger>VisualWorks</logger>
		<level>SEVERE</level>
		<thread>10</thread>
		<message>Arrgh...</message>
	</record>
	<record>
		<date>2008-02-17T14:43:09</date>
		<millis>1203255789812</millis>
		<sequence>1</sequence>
		<logger>VisualWorks</logger>
		<level>INFO</level>
		<thread>10</thread>
		<message>Better now.</message>
	</record>
	<record>
		<date>2008-02-17T14:43:09</date>
		<millis>1203255789812</millis>
		<sequence>2</sequence>
		<logger>VisualWorks</logger>
		<level>CONFIG</level>
		<thread>10</thread>
		<message>Log level changed</message>
		<param>INFO</param>
	</record>
</log>
```