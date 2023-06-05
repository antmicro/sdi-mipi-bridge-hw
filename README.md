# SDI to MIPI CSI-2 Bridge Hardware Design

Copyright (c) 2020-2023 [Antmicro](https://www.antmicro.com)

![SDI-MIPI Bridge](/img/sdi-mipi-bridge.jpg)

## Overview

This project contains open hardware KiCad design files for Antmicro's SDI to MIPI CSI-2 bridge.
This device enables connecting industrial and filmmaking cameras and video accessories to edge AI platforms which often include the MIPI CSI-2 interface.

The board includes an SDI input BNC connector and Antmicro's standard 50-pin FFC output connector (compatible with a range of our open hardware boards) exposing MIPI CSI-2 lanes as well as an I2C bus for configuration.

An additional SDI output (loopback) BNC connector is also available.

SDI signal conversion is implemented with a Semtech [GS2971A](https://www.semtech.com/products/broadcast-video/receivers-deserializers/gs2971a) deserializer which passes the parrallel 10-bit video data to the Lattice CrossLink [LIF-MD6000-6KMG80I](http://www.latticesemi.com/en/Products/FPGAandCPLD/CrossLink).
The CrossLink FPGA includes programmable logic and dedicated MIPI D-PHY transceivers.
It can be configured to accept parallel video data from the deserializer and transmit it over MIPI CSI-2 to the host platform.
SPI and I2C programming interfaces are exposed so the deserializer and the CrossLink FPGA can be configured from the host platform.

### Project structure

The main directory contains KiCad PCB project files, a LICENSE and README.
The remaining files are stored in the following directories:

* ``lib`` - contains the component libraries
* ``doc`` - contains board schematic in PDF
* ``img`` - contains graphics for this README

## Key Features

* Implements Single Link (3G-SDI) video conversion
* Supports SMPTE ST 425 (Level A and Level B), SMPTE ST 424, SMPTE ST 292, SMPTE ST 259-C and DVB-ASI as defined by the Semtec GS2971A specification
* Integrated loopback BNC connector for easy daisy-chaining with multiple SDI video accessories
* Audio de-embedder for 8 channels of 48kHz audio exposed on I2S 10 pin header
* Two 4-lane MIPI CSI-2 interfaces with up to 6 Gbps, each exposed on the 50 pin FFC connector.
* I2C configuration interface to handle CrossLink FPGA and SDI deserializer
* SPI interface for CrossLink configuration
* 12x DIP switches to initially configure the deserializer
* 2 LED indicators for user purposes

## Getting started

Please refer to the [SDI to MIPI CSI-2](https://github.com/antmicro/sdi-mipi-bridge) bridge repository which aggregates the hardware design (this project), linux kernel sources, how-to documentation and reference HDL design for the CrossLink FPGA.

## License

This project is licensed under the [Apache-2.0](LICENSE) license.
