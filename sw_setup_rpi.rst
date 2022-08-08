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

      echo "sdi_bridge/sdi_bridge_720p60.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

   For 1080p30:

   .. code-block:: bash

      echo "sdi_bridge/sdi_bridge_1080p30.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

   For 1080p60:

   .. code-block:: bash

      echo "sdi_bridge/sdi_bridge_1080p60.bit" | sudo tee /sys/class/fpga_manager/fpga0/load

2. Testing the video stream

   The video stream can be tested with the ``qv4l2`` application. In the General Settings tab expected pixel format and frame size need to be set to match the the SDI video source and loaded bitstream.

