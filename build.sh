#!/bin/sh
echo "Cleaning build dir"
rm -rf build

echo
echo "Copying Core resources (including folder with problematic case)"
mkdir -p build/core
cp -r core/src/main/resources/* build/core
du -a build/core

echo
echo "Compiling Core code"
kotlinc core/src/main/kotlin/freenow/core/Core.kt -d build/core
du -a build/core

echo
echo "Compiling Java Consumer code"
javac java-consumer/src/main/java/freenow/consumer/Consumer.java -cp build/core -d build/java-consumer
du -a build/java-consumer
echo "Java compilation works on any file system"

echo
echo "Compiling Kotlin Consumer code"
kotlinc kotlin-consumer/src/main/kotlin/freenow/consumer/Consumer.kt -cp build/core -d build/kotlin-consumer
du -a build/kotlin-consumer
echo "Kotlin compilation fails on case insensitive file systems (Mac OS, Windows)"