# Java implementations and Operating Systems

Theoretically, JNIPort should work on every operating system where both VisualWorks and Java are available. In practice, there are platforms where it is known to work and a few configurations which are known not to work. If you don't see your favorite configuration on the "known to work" list, this doesn't mean that it wouldn't work. In most cases, JNIPort will work without problems.

## Configurations known to work

- Windows XP, VisualWorks 7.5 / 7.6 / 7.7, Sun J2SE 5.0
- Windows XP, VisualWorks 7.5 / 7.6 / 7.7 / 7.7.1 / 7.8, Sun Java SE 6
- Ubuntu 8.04 32-bit, VisualWorks 7.6, Sun J2SE 5.0
- Ubuntu 8.04 32-bit, VisualWorks 7.6, Sun Java SE 6
- Ubuntu 8.04 64-bit, VisualWorks 7.6 64-bit VM, Sun J2SE 5
- Ubuntu 8.04 64-bit, VisualWorks 7.6 64-bit VM, Sun Java SE 6
- Ubuntu 10.04 64-bit, VisualWorks 7.7 / 7.7.1 / 7.8 32-bit VM, Sun Java SE 6
- Ubuntu 10.04 64-bit, VisualWorks 7.7 / 7.7.1 / 7.8 64-bit VM, Sun Java SE 6
- Ubuntu 10.04 64-bit, VisualWorks 7.7 / 7.7.1 / 7.8 32-bit VM, OpenJDK 6
- Ubuntu 10.04 64-bit, VisualWorks 7.7 / 7.7.1 / 7.8 64-bit VM, OpenJDK 6
- Mac OS X 10.5 Intel, VisualWorks 7.6 / 7.7, Mac OS X JDK 5 / 6
- Mac OS X 10.6.6, VisualWorks 7.5 (with 7.7 VM) / 7.6 (with 7.7 VM) / 7.7 / 7.7.1 / 7.8, Mac OS X JDK 6
- Mac OS X 10.5 PowerPC, VisualWorks 7.7, JamVM: There are some [additional instructions](mac-os-x-10-5-powerpc.md) for this configuration.

## Configurations known not to work

- Mac OS X 10.5 PowerPC, VisualWorks 7.7, Mac OS X JDK 5: For as yet unknown reasons the VM crashes when a mysterious thread attempts a faulty callback into the VisualWorks VM.

- Mac OS X 10.5 Intel, VisualWorks 7.6/7.7, Mac OS X JDK 6: The simple reason for this is that the Java VM on this platform is a 64-bit library, while the VisualWorks virtual machine is a 32-bit application, so they are incompatible.
