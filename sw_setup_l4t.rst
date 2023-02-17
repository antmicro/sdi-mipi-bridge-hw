Host software supporting SDI-MIPI Bridge
==============================

The host software is based on Linux4Tegra 32.4.4 release.

Hardware setup
--------------

The host software is prepared for Jetson Xavier NX module on `Antmicro's Jetson Nano Baseboard <https://github.com/antmicro/jetson-nano-baseboard>`_.
The SDI-MIPI Bridge board is connected to the J7 FFC connector of the baseboard.

Due to the SDI-MIPI Bridge's wide range of capabilities and possible support for various different configurations it has 12 Dip-switches for the SDI deserializer setup.
Those variants can be altered by setting the initial switches configuration.
Detailed description of their functions is available in the `Semtech Deserializer documentation <https://semtech.my.salesforce.com/sfc/p/#E0000000JelG/a/44000000MD3i/kpmMkrmUWgHlbCOwdLzVohMm1SDPoVH85guEGK.KXTc>`_.

Below you can find short description of each switch with its default value:

+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Name         | Default | Notes                                                                                                                                                                                                                                                          |
+==============+=========+================================================================================================================================================================================================================================================================+
| USER_SW      | OFF     | "Connected to PB6D input of Crosslink FPGA."                                                                                                                                                                                                                   |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SDO_EN       | ON      | "Enable/disable to SDO output of the GS2971A, which is buffered and exposed on the 'SDI Output' BNC."                                                                                                                                                          |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| AUDIO_EN     | ON      | "Enables/disables audio extraction fuctionality of the GS2971A."                                                                                                                                                                                               |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| IOPROC_EN    | ON      | "Enables/disables signal processing features of the GS2971A like error correction and level conversion."                                                                                                                                                       |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 20bit_10bit  | OFF     | "Used to select the output bus width. Must be set low for proper operation on this board."                                                                                                                                                                     |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SMPTE_BYPASS | OFF     | "When on, the GS2971A carries out SMPTE scrambling and I/O processing. When OFF, GS2971A operates in data-through mode."                                                                                                                                       |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| DVB_ASI      | OFF     | "Enables/disables DVB-ASI mode of the GS2971A."                                                                                                                                                                                                                |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SW_EN        | OFF     | "When OFF, the default state of GS2971A's SW_EN pin is low. A rising edge (via switch or FPGA GPIO) will cause the GS2971A to re-lock on the input video stream. Generally not needed unless the video source has been externally switched between two source" |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| TIM_861      | ON      | "When TIM_861 is HIGH, the GS2971A outputs CEA 861 timing signals (HSYNC/VSYNC/DE) instead of H:V:F digital timing signals."                                                                                                                                   |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| RC_BYP       | OFF     | "When on, the serial digital output is the re-timed version of the serial input. When OFF, the serial digital output is simply the buffered version of the serial input, bypassing the GS2971A's internal reclocker."                                          |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| STANDBY      | OFF     | "When on, the GS2971A is placed in a power-saving mode. No data processing occurs, and the digital I/Os are powered down."                                                                                                                                     |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| JTAG_HOST    | OFF     | "When on, the GS2971A's host interface port is configured for JTAG test. When OFF, the GS2971A operates normally."                                                                                                                                             |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Building the software
---------------------

To enable SDI-MIPI Bridge support, a custom kernel needs to be built. The steps to fetch, build and apply it to stock L4T 32.4.4 package are listed below.

1. Obtain and extract cross-compilation toolchain:

   .. code-block:: bash

      wget http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
      tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
      export PATH=$(pwd)/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin:$PATH

2. Obtain and set up the L4T-based host software:

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

3. Obtain the kernel sources:

   .. code-block:: bash

      git clone https://github.com/antmicro/sdi-mipi-bridge-linux

4. Build the kernel:

   .. code-block:: bash

      pushd sdi-mipi-bridge-linux
      export ARCH=arm64
      export CROSS_COMPILE=aarch64-linux-gnu-
      make tegra_defconfig
      make -j$(nproc)

5. Install the kernel image, modules and device tree blob to the host software:

   .. code-block:: bash

      cp ./arch/arm64/boot/Image ../Linux_for_Tegra/kernel/
      cp ./arch/arm64/boot/dts/tegra194-p3668-all-p3509-0000.dtb ../Linux_for_Tegra/kernel/dtb/
      INSTALL_MOD_PATH=../Linux_for_Tegra/rootfs/ make modules_install
      sudo chown -R root ../Linux_for_Tegra/rootfs/lib/modules
      sudo chown -R root ../Linux_for_Tegra/rootfs/lib/firmware
      popd


6. Copy helper scripts from this repository to the root filesystem:

   .. code-block:: bash

      git clone https://github.com/antmicro/sdi-mipi-bridge
      pushd sdi-mipi-bridge
      cp -r scripts/* ../Linux_for_Tegra/rootfs/usr/local/bin/
      popd

Flashing host software to the device
--------------------------

To flash the host software to the device, put it in recovery mode, connect to the host PC with a USB cable and use the following command to flash it:

.. code-block:: bash

   pushd Linux_for_Tegra
   sudo ./flash.sh jetson-xavier-nx-devkit-emmc mmcblk0p1
   popd

Software usage
--------------

After flashing with the modified host software and booting the device, there should be a ``/dev/video0`` file and ``/sys/class/fpga_manager/fpga0`` directory present in the filesystem.
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
