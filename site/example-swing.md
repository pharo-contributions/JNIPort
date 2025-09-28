# Example - Controlling a Swing window

The SwingWindow screencast shows you how to control a Swing window from Smalltalk.

You need the Adobe Flash Player to watch the screencast.

This is the source code for the example shown in the screencast:

```smalltalk
jvm := JVM current.
frame := (jvm findClass: #'javax.swing.JFrame')  new_String: 'JNIPort!'.
closeOp := frame static get_DISPOSE_ON_CLOSE.
frame setDefaultCloseOperation_int: closeOp.
frame pack; setVisible_boolean: true.
"We can hide the frame:"
frame setVisible_boolean: false.
"And show it again:"
frame setVisible_boolean: true.
"Add an image pane:"
icon := (jvm findClass: #'javax.swing.ImageIcon') new_String: 'DarkCoast.jpg'.
label := (jvm findClass: #'javax.swing.JLabel') new_Icon: icon.
pane := (jvm findClass: #'javax.swing.JScrollPane') new_Component: label.
frame getContentPane add_Component: pane.
frame pack.
"Remove the frame:"
frame getContentPane remove_Component: pane.
frame pack.
"Close the frame:"
frame dispose.
```