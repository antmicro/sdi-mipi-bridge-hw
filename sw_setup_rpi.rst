SDI to MIPI CSI-2 Bridge software setup - Raspberry Pi Compute Module 4
=======================================================================

The BSP is based on the Raspberry Pi OS 2022-04-04 release.

Hardware setup
--------------

The hardware components required for the setup:

* `Antmicro SDI to MIPI CSI-2 Bridge <https://github.com/antmicro/sdi-mipi-bridge>`_
* `Antmicro Raspberry Pi CM4 CSI adapter <https://github.com/antmicro/raspberry-pi-cm4-csi-adapter>`_
* Raspberry Pi Compute Module 4 IO board
* Raspberry Pi Compute Module 4

The SDI-MIPI Bridge board is connected via the Raspberry Pi CM4 CSI adapter to the CAM1 FFC connector of the CM4 IO board.

Due to the SDI-MIPI Bridge's wide range of capabilities and possible support for various different configurations it has 12 Dip-switches for the SDI deserializer setup.
Those variants can be altered by setting the initial switches configuration.
Detailed description of their functions is available in the `Semtech Deserializer documentation <https://semtech.my.salesforce.com/sfc/p/#E0000000JelG/a/44000000MD3i/kpmMkrmUWgHlbCOwdLzVohMm1SDPoVH85guEGK.KXTc>`_.

Below you can find short description of each switch with its default value:

+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Name         | Default | Notes                                                                                                                                                                                                                                                          |
+==============+=========+================================================================================================================================================================================================================================================================+
| USER_SW      | OFF     | General purpose user input connected to PB6D input of Crosslink FPGA.                                                                                                                                                                                          |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SDO_EN       | ON      | Enable/disable to SDO output of the GS2971A, which is buffered and exposed on the 'SDI Output' BNC.                                                                                                                                                            |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| AUDIO_EN     | ON      | Enables/disables audio extraction fuctionality of the GS2971A.                                                                                                                                                                                                 |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| IOPROC_EN    | ON      | Enables/disables signal processing features of the GS2971A like error correction and level conversion.                                                                                                                                                         |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 20bit_10bit  | OFF     | Used to select the output bus width. Must be set low for proper operation on this board.                                                                                                                                                                       |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SMPTE_BYPASS | OFF     | When on, the GS2971A carries out SMPTE scrambling and I/O processing. When OFF, GS2971A operates in data-through mode.                                                                                                                                         |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| DVB_ASI      | OFF     | Enables/disables DVB-ASI mode of the GS2971A.                                                                                                                                                                                                                  |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SW_EN        | OFF     | When OFF, the default state of GS2971A's SW_EN pin is low. A rising edge (via switch or FPGA GPIO) will cause the GS2971A to re-lock on the input video stream. Generally not needed unless the video source has been externally switched between two source   |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| TIM_861      | ON      | When TIM_861 is HIGH, the GS2971A outputs CEA 861 timing signals (HSYNC/VSYNC/DE) instead of H:V:F digital timing signals.                                                                                                                                     |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| RC_BYP       | OFF     | When on, the serial digital output is the re-timed version of the serial input. When OFF, the serial digital output is simply the buffered version of the serial input, bypassing the GS2971A's internal reclocker.                                            |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| STANDBY      | OFF     | When on, the GS2971A is placed in a power-saving mode. No data processing occurs, and the digital I/Os are powered down.                                                                                                                                       |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| JTAG_HOST    | OFF     | When on, the GS2971A's host interface port is configured for JTAG test. When OFF, the GS2971A operates normally.                                                                                                                                               |
+--------------+---------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Building the software
---------------------

To enable SDI-MIPI Bridge support, a custom kernel needs to be built. The steps to fetch, build and install it with the stock Raspberry Pi OS 2022-04-04 BSP are listed below.

1. Obtain and extract the cross-compilation toolchain:

   .. code-block:: bash

      wget http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
      tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
      export PATH=$(pwd)/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin:$PATH

2. Obtain and flash the Raspberry Pi OS BSP to an SD card

   .. code-block:: bash

      wget https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-04-07/2022-04-04-raspios-bullseye-arm64.img.xz
      xzcat 2022-04-04-raspios-bullseye-arm64.img.xz | dd of=/dev/sdX bs=512 # where X is a letter of a block device representing the SD card

3. Obtain the kernel sources

   .. code-block:: bash

      git clone https://github.com/antmicro/sdi-mipi-bridge-linux-rpi

4. Build the kernel

   .. code-block:: bash

      cd sdi-mipi-bridge-linux-rpi
      mkdir ../modules
      export INSTALL_MOD_PATH=../modules/
      export ARCH=arm64
      export CROSS_COMPILE=aarch64-linux-gnu-
      KERNEL=kernel8
      make bcm2711_defconfig
      make -j$(nproc)
      make modules_install

4. Install binaries on the SD card

   .. code-block:: bash

      sudo cp arch/arm64/boot/dts/broadcom/*.dtb <sd_card>/boot/
      sudo cp arch/arm64/boot/dts/overlays/*.dtb* <sd_card>/boot/overlays/
      sudo cp arch/arm64/boot/dts/overlays/README <sd_card>/boot/overlays/
      sudo cp arch/arm64/boot/Image <sd_card>/boot/
      sudo cp -r ../modules/lib/modules/* <sd_card>/lib/modules/

5. Include the following lines in the `<sd_card>/boot/config.txt` file

   .. code-block:: bash

      kernel=Image
      dtoverlay=dwc2,dr_mode=host
      dtoverlay=disable-bt
      dtoverlay=sdi-mipi-bridge-j5-cam1-4lane

Software usage
--------------

After flashing with the modified host software and booting the device, there should be a ``/dev/video0`` file and ``/sys/class/fpga_manager/fpga0`` directory present in the filesystem.
In order to test the video streaming from the SDI-MIPI bridge, perform the following steps:

1. Load the appropriate firmware for the desired format:

   For 720p60:

   .. code-block:: bash

      echo sdi_bridge/sdi_bridge_720p60.bit | sudo tee /sys/class/fpga_manager/fpga0/load

   For 1080p30:

   .. code-block:: bash

      echo sdi_bridge/sdi_bridge_1080p30.bit | sudo tee /sys/class/fpga_manager/fpga0/load

   For 1080p60:

   .. code-block:: bash

      echo sdi_bridge/sdi_bridge_1080p60.bit | sudo tee /sys/class/fpga_manager/fpga0/load

2. Testing the video stream

   The video stream can be tested with the ``qv4l2`` application. In the General Settings tab expected pixel format and frame size need to be set to match the the SDI video source and loaded bitstream.

