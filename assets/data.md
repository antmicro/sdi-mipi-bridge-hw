# SDI to MIPI CSI-2 bridge

## Description

Open source SDI to MIPI CSI-2 bridge. This device allows you to connect SDI inputs over long distances using a single coaxial cable to the otherwise short-range (but extremely popular and widely available) MIPI CSI-2 interface. Compatible with the (Jetson Nano Baseboard).

You can read more about this board on [Antmicro’s blog](https://antmicro.com/blog/2023/02/open-source-fpga-designs-for-the-sdi-to-mipi-csi-2-bridge/).

## Features

* Based on the Lattice CrossLink FPGA
* Implements Single Link (3G-SDI) video conversion
* Supports SMPTE ST 425 (Level A and Level B), SMPTE ST 424, SMPTE ST 292, SMPTE ST 259-C and DVB-ASI as defined by the Semtec GS2971A specification
* Integrated loopback BNC connector for easy daisy-chaining with multiple SDI video accessories
* Audio de-embedder for 8 channels of 48kHz audio exposed on I2S 10 pin header
* Two 4-lane MIPI CSI-2 interfaces with up to 6 Gbps, each exposed on the 50 pin FFC connector
* I2C configuration interface to handle CrossLink FPGA and SDI deserializer
* SPI interface for CrossLink configuration
* 12x DIP switches to initially configure the deserializer
* 2 LED indicators for user purposes

## External urls

* [GitHub](https://github.com/antmicro/sdi-mipi-bridge-hw)
* [Open Source Portal](https://opensource.antmicro.com/projects/sdi-mipi-bridge-hw)

## Related urls

* [Blog note](https://antmicro.com/blog/2023/02/open-source-fpga-designs-for-the-sdi-to-mipi-csi-2-bridge/)

## Related boards

* jetson-orin-baseboard
* jetson-nano-baseboard
* ov9281-camera-board
* hdmi-mipi-bridge
* snapdragon-845-baseboard
