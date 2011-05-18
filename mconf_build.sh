#!/bin/bash

# using the unofficial Crystax NDK
NDK_DIR=~/Codes/android-ndk-r4-crystax
PREBUILT=$NDK_DIR/build/prebuilt/linux-x86/arm-eabi-4.4.0
PLATFORM=$NDK_DIR/build/platforms/android-8/arch-arm

# if you prefer to use the official Android NDK, uncomment the following commands
#NDK_DIR=~/codes/android-ndk-r5b
#PREBUILT=$NDK_DIR/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86
#PLATFORM=$NDK_DIR/platforms/android-8/arch-arm

#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/errno.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/posix_types.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/limits.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/stddef.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/fcntl.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/capability.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/stat.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/sockios.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/in.h $PLATFORM/usr/include/linux/
#cp $PLATFORM/../../android-3/arch-arm/usr/include/linux/in6.h $PLATFORM/usr/include/linux/

list_files() {
	echo 'LOCAL_SRC_FILES := \' > ../$1_files.mk

    # run a fake make
    make --dry-run | \
    # select all the lines of make output that contains .c and .S files
    egrep -i '\.c|\.S' | \
    # select just the filenames followed by ' \'
    sed -e 's:\(.*\) \(.*\.[cS]\)\(.*\):\2 \\:g' | \
    # select the just the files from the wanted library
    egrep -i "$1/" | \
    # put the result on .mk file
    sort >> ../$1_files.mk
}

cd jni/ffmpeg

./configure --help > ../configure.options
./configure --target-os=linux \
    --disable-everything \
    --disable-postproc \
    --disable-avfilter \
    --disable-network \
    --disable-ffmpeg \
    --disable-ffprobe \
	--arch=arm \
	--enable-version3 \
	--enable-gpl \
	--enable-nonfree \
	--enable-cross-compile \
    --enable-encoder=flv \
    --enable-decoder=flv \
	--cc=$PREBUILT/bin/arm-eabi-gcc \
	--cross-prefix=$PREBUILT/bin/arm-eabi- \
	--nm=$PREBUILT/bin/arm-eabi-nm \
	--extra-cflags="-fPIC -DANDROID -I$PLATFORM/usr/include" \
	--enable-armv5te \
	--extra-ldflags="-Wl,-T,$PREBUILT/arm-eabi/lib/ldscripts/armelf.x -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib $PREBUILT/lib/gcc/arm-eabi/4.4.0/crtbegin.o $PREBUILT/lib/gcc/arm-eabi/4.4.0/crtend.o -lc -lm -ldl" \
	--logfile=../configure.log

list_files 'libavutil'
list_files 'libavcodec'
# point corrections
echo 'libavcodec/rawdec.c \' >> ../libavcodec_files.mk
list_files 'libavformat'
list_files 'libswscale'

cd ../..

$NDK_DIR/ndk-build clean
$NDK_DIR/ndk-build -j 4