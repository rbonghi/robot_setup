#!/bin/bash
# Copyright (C) 2018, Raffaello Bonghi <raffaello@rnext.it>
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    
# Update the NVIDIA Jetson Kernel
# Reference
# Thanks @jetsonhacks
# https://github.com/NVIDIA-Jetson/jetson-trashformers/wiki/Re-configuring-the-Jetson-TX2-Kernel
# http://www.jetsonhacks.com/2017/03/25/build-kernel-and-modules-nvidia-jetson-tx2/
# https://github.com/jetsonhacks/buildJetsonTX2Kernel

MODULE_NAME="Update the NVIDIA Jetson Kernel"
MODULE_DESCRIPTION="This module update the NVIDIA Jetson and add new features:
FTDI driver converter
ACM driver"
MODULE_DEFAULT=0

KERNEL_FOLDER="kernel/kernel-4.4"

make_kernel()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "Make kernel"
    tput sgr0
    
    # Builds the kernel and modules
    # Assumes that the .config file is available
    cd $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FOLDER
    
    make prepare
    make modules_prepare
    make -j6
    make modules
    make modules_install
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

copy_images()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)
    
    tput setaf 6
    echo "Copy images"
    tput sgr0
    
    cd $KERNEL_DOWNLOAD_FOLDER/$KERNEL_FOLDER
    
    sudo cp arch/arm64/boot/zImage /boot/zImage
    sudo cp arch/arm64/boot/Image /boot/Image
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

get_kernel_sources()
{
    # Local folder
    local LOCAL_FOLDER=$(pwd)

    # List of kernel link
    local KERNEL_LINK=""
    if [ $JETSON_L4T == "28.2" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r28_Release_v2.0/BSP/source_release.tbz2"
    elif [ $JETSON_L4T == "28.1" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r28_Release_v1.0/BSP/source_release.tbz2"
    elif [ $JETSON_L4T == "27.1" ] ; then
        KERNEL_LINK="http://developer.download.nvidia.com/embedded/L4T/r27_Release_v1.0/BSP/r27.1.0_sources.tbz2"
    fi
    # Variable kernel file
    local KERNEL_FILE=$(basename "${KERNEL_LINK}")

    # Install qt5-default and pkg-config
    sudo apt-get install qt5-default pkg-config -y
    
    tput setaf 6
    echo "Move in download folder: $KERNEL_DOWNLOAD_FOLDER"
    tput sgr0
    # Move in jetson folder
    cd $KERNEL_DOWNLOAD_FOLDER
    
    # Download kernel
    tput setaf 6
    echo "Download source kernel $JETSON_L4T"
    tput sgr0
    # wget $KERNEL_LINK
    
    tput setaf 6
    echo "Extracting $KERNEL_FILE from source release"
    tput sgr0
    #tar -xvf $KERNEL_FILE public_release/kernel_src.tbz2

    tput setaf 6
    echo 'Expanding kernel_src.tbz2'
    tput sgr0
    #tar -xvf public_release/kernel_src.tbz2
    
    cd $KERNEL_FOLDER
    #zcat /proc/config.gz > .config
    
    # Ready to configure kernel
    #make xconfig
    
    # Restore previuous folder
    cd $LOCAL_FOLDER
}

script_run()
{
    # Dowload folder
    KERNEL_DOWNLOAD_FOLDER="/usr/src"
    
    tput setaf 6
    echo "Update the NVIDIA Jetson Kernel $(uname -r)"
    tput sgr0
    
    if [ $JETSON_L4T == "27.1" ] || [ $JETSON_L4T == "28.1" ] || [ $JETSON_L4T == "28.2" ] ; then
        # Run get kernel sources
        get_kernel_sources 
        
        # Make the kernel
        #make_kernel
        
        # Copy images
        #copy_images
        
        # Require reboot
        tput setaf 1
        echo "Enable require reboot"
        tput sgr0
        #MODULES_REQUIRE_REBOOT=1
        
    else
        tput setaf 1
        echo "This kernel updater doesn't work with this Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"
        tput sgr0
    fi
}


