# SuperTelegram
SuperTelegram is a set of tools for Telegram messaging service by NileGroup.

## Build

### Build tools
To build SuperTelegram you need Qt5.5, Gcc/G++ compiler and OpenSSL.

### Prepair environments
If you want to build SuperTelegram for android, First of all you need to set some environment variables:

    export ANDROID_HOME=/PATH/TO/ANDROID-SDK/ROOT/
    export ANDROID_NDK_HOST=linux-x86_64
    export ANDROID_NDK_PLATFORM=android-9
    export ANDROID_NDK_ROOT=/PATH/TO/ANDROID-NDK/ROOT/
    export ANDROID_NDK_TOOLCHAIN_PREFIX=arm-linux-androideabi
    export ANDROID_NDK_TOOLCHAIN_VERSION=4.9
    export ANDROID_NDK_TOOLS_PREFIX=arm-linux-androideabi
    export ANDROID_SDK_ROOT=/PATH/TO/ANDROID-SDK/ROOT/
    export JAVA_HOME=/PATH/TO/JAVA_JDK/ROOT/
    export JAVA_TOOL_OPTIONS=-javaagent:/usr/share/java/jayatanaag.jar 

### Build
To Build SuperTelegram, Enter blow commands in the terminal:

    mkdir build && cd build
    qmake .. -r OPENSSL_INCLUDE_PATH+=/PATH/TO/OPENSSL/HEADERS/DIRECTORY/PARENT/  OPENSSL_LIB_DIR=/PATH/TO/OPENSSL/LIBRARIES/DIRECTORY
    make
