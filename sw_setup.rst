BSP supporting SDI-MIPI Bridge
==============================

The BSP is based on Linux4Tegra 32.4.4 release.

Hardware setup
--------------

The BSP is prepared for Jetson Xavier NX module on `Antmicro's Jetson Nano Baseboard <https://github.com/antmicro/jetson-nano-baseboard>`_.
The SDI-MIPI Bridge board is connected to the J7 FFC connector of the baseboard.

Building the software
---------------------

To enable SDI-MIPI Bridge support, a custom kernel needs to be built. The steps to fetch, build and apply it to stock L4T 32.4.4 package are listed below.

1. Obtain and extract cross-compilation toolchain

   .. code-block:: bash

      wget http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
      tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
      export PATH=$(pwd)/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin:$PATH

2. Obtain and set up the L4T BSP

   .. code-block:: bash

      wget https://developer.nvidia.com/embedded/L4T/r32_Release_v4.4/r32_Release_v4.4-GMC3/T186/Tegra186_Linux_R32.4.4_aarch64.tbz2
      tar xf Tegra186_Linux_R32.4.4_aarch64.tbz2
      wget https://developer.nvidia.com/embedded/L4T/r32_Release_v4.4/r32_Release_v4.4-GMC3/T186/Tegra_Linux_Sample-Root-Filesystem_R32.4.4_aarch64.tbz2
      sudo tar xf Tegra_Linux_Sample-Root-Filesystem_R32.4.4_aarch64.tbz2 -C Linux_for_Tegra/rootfs/
      pushd Linux_for_Tegra
      sudo ./apply_binaries.sh
      sudo chown -R $USER rootfs/lib/modules
      sudo chown -R $USER rootfs/lib/firmware
      popd

3. Obtain the kernel sources

   .. code-block:: bash

      git clone https://github.com/antmicro/sdi-mipi-bridge-linux

4. Build the kernel

   .. code-block:: bash

      pushd sdi-mipi-bridge-linux
      export ARCH=arm64
      export CROSS_COMPILE=aarch64-linux-gnu-
      make tegra_defconfig
      make -j$(nproc)

5. Install the kernel image, modules and device tree blob to the BSP

   .. code-block:: bash

      cp ./arch/arm64/boot/Image ../Linux_for_Tegra/kernel/
      cp ./arch/arm64/boot/dts/tegra194-p3668-all-p3509-0000.dtb ../Linux_for_Tegra/kernel/dtb/
      INSTALL_MOD_PATH=../Linux_for_Tegra/rootfs/ make modules_install
      sudo chown -R root ../Linux_for_Tegra/rootfs/lib/modules
      sudo chown -R root ../Linux_for_Tegra/rootfs/lib/firmware
      popd


6. Copy helper scripts from this repository to the root filesystem

   .. code-block:: bash

      git clone https://github.com/antmicro/sdi-mipi-bridge
      pushd sdi-mipi-bridge
      cp -r scripts/* ../Linux_for_Tegra/rootfs/usr/local/bin/
      popd

Flashing BSP to the device
--------------------------

To flash the BSP to the device, put it in recovery mode, connect to the host PC with a USB cable and use the following command to flash it:

.. code-block:: bash

   pushd Linux_for_Tegra
   sudo ./flash.sh jetson-xavier-nx-devkit-emmc mmcblk0p1
   popd

Software usage
--------------

After flashing with the modified BSP and booting the device, there should be a ``/dev/video0`` file and ``/sys/class/fpga_manager/fpga0`` directory present in the filesystem.
In order to test the video streaming from the SDI-MIPI bridge, perform the following steps:

1. Load appropriate firmware for the desired format:

   For 720p60:

   .. code-block:: bash

      echo "sdi_bridge/sdi_bridge_720p60.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

   For 1080p30:

   .. code-block:: bash

      echo "sdi_bridge/sdi_bridge_1080p30.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

   For 1080p60:

   .. code-block:: bash

      echo "sdi_bridge/sdi_bridge_1080p60.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

2. Test streaming using gstreamer (make sure to set up framesize of the SDI source correctly)

   For 1080p formats:

   .. code-block:: bash

      gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw,width=1920,height=1080' ! xvimagesink

   For 720p format:

   .. code-block:: bash

      gst-launch-1.0 v4l2src device=/dev/video0 ! 'video/x-raw,width=1280,height=720' ! xvimagesink

Alternatively, helper scripts that perform the above steps for each format can be used:

.. code-block:: bash

   SDI_720p60.sh
   SDI_1080p30.sh
   SDI_1080p60.sh
