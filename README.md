# Overview of the issue

Kotlin compiler eforces case senstiveness on case insensitive file systems (Mac OS, Windows).

# Example explanation

In this example, mirroring a more complicated real case we found at Free Now, a resource folder is named `FreeNow` and
a package is named `freenow`, same name with different cases. When the build runs in a case insenstive file system
resources and classes go to the same folder. Because resources are copied before compilation, classes end up inside
the `FreeNow` directory.

When another module references the class `freenow.core.Core` the compiler says no such class exists. But this onl happens
with Kotlin classes: Java classes get successfully compiled.

# More about the real case

The biggest challenge with this issue was figuring it out. It appeared while converting Java classes to Kotlin. Not only all
previous Java code worked, but the error message at first seems to make no sense. Intriguingly builds worked fine on the
Continuous Integration build system, but failed on any developer computer. It took a long investigation time to find the
problematic resources folder and it took even longer to understand the exact reason.

# Example structure

This example consists of 3 modules:

- A "core" module, which contains the resoueces folder with the problematic case
- A "Java consumer" module, that makes use of the "core" module and shows Java compiler is not affected by the issue
- A "Kotlin consumer" module, that fails to compile when the `freenow.core.Core` class is referenced

# How to test

The issue only happens when it runs in a case insenstive file system. Mac OS and Windows were tested and failed with the
same error message. Notice Mac OS can also run with a case senstive file system. The build succeeds on Linux, as expected.

To show how the issue was first spotted the project contains Maven build files (`pom.xml`). To see how the Maven build fails
simply run `mvn clean compile` at the root of the project.

The expected output is:
```
[INFO] --- kotlin-maven-plugin:1.3.71:compile (compile) @ case-sensiveness-bug-report-kotlin-consumer ---
[WARNING] Duplicate source root: /Users/lucasls/freenow/code/kotlin-case-sensiveness-bug-report/kotlin-consumer/src/main/kotlin
[ERROR] /Users/lucasls/freenow/code/kotlin-case-sensiveness-bug-report/kotlin-consumer/src/main/kotlin/freenow/consumer/Consumer.kt: (3, 16) Unresolved reference: core
[ERROR] /Users/lucasls/freenow/code/kotlin-case-sensiveness-bug-report/kotlin-consumer/src/main/kotlin/freenow/consumer/Consumer.kt: (6, 5) Unresolved reference: Core
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for case-sensiveness-bug-report 0.0.1-SNAPSHOT:
[INFO] 
[INFO] case-sensiveness-bug-report ........................ SUCCESS
[INFO] case-sensiveness-bug-report-core ................... SUCCESS
[INFO] case-sensiveness-bug-report-java-consumer .......... SUCCESS
[INFO] case-sensiveness-bug-report-kotlin-consumer ........ FAILURE
```

But to demonstrate the issue is not related to the Kotlin Maven plugin, a `build.sh` file is also included. It uses `kotlinc` 
and `javac` directly. To see how it fails simply run `./buiild.sh` at the root of the project.

The expected output is:
```
Compiling Java Consumer code
8       build/java-consumer/freenow/consumer/Consumer.class
8       build/java-consumer/freenow/consumer
8       build/java-consumer/freenow
8       build/java-consumer
Java compilation works on any platform, cause it respects system case sensitiveness

Compiling Kotlin Consumer code
kotlin-consumer/src/main/kotlin/freenow/consumer/Consumer.kt:3:16: error: unresolved reference: core
import freenow.core.Core
               ^
kotlin-consumer/src/main/kotlin/freenow/consumer/Consumer.kt:6:5: error: unresolved reference: Core
    Core().sayHello()
    ^
Kotlin compilation fails on case insensitive platforms (Mac OS, Windows), works otherwise (Linux)
```
