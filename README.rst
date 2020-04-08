SDI bridge
==========

Introduction
------------

This repository contains an open hardware design files for SDI to MIPI CSI-2 bridging device created by `Antmicro <https://antmicro.com/>`_.
This device enables to connect industrial and broadcast cameras to the devices with digital signal processors that are operating with MIPI signal standard.
The design was created in KiCad and will be released as Open Source Hardware (OSHW)

Board overview
--------------

The board is equipped with input BNC connector and output 50-pin  MIPI CSI-2 connector. Additional SDI loopback BNC connector also has been provided. SDI signal coversion is implemented with a `Semtech GS2971A <https://www.semtech.com/products/broadcast-video/receivers-deserializers/gs2971a>`_ deserializer which is passing the parrallel 10-bit sigall to the `CrossLink <http://www.latticesemi.com/en/Products/FPGAandCPLD/CrossLink>`_. The CrossLink is video bridging & processing optimized FPGA with MIPI D-PHY bridging capabilities and it converts parralel signall to the output MIPI CSI-2 format. There are SPI and I2C programming interfaces and audio I2S output connector. Configuration dip switches has been implemented to make this device more comprehensive platform for signall processing.

.. Image:: img/vis_front.png

Key Features
------------

   * Operation at 2.97Gb/s, 2.97/1.001Gb/s, 1.485Gb/s,1.485/1.001Gb/s and 270Mb/s
   * Supports SMPTE ST 425 (Level A and Level B),SMPTE ST 424, SMPTE ST 292, SMPTE ST 259-C andDVB-ASI
   * Integrated adaptive cable equalizer and output loopback bnc connector.
   * Audio de-embedder for 8 channels of 48kHz audio exposed on I2S 10 pin header.
   * Two 4-lane MIPI D-PHY transceivers at 6 Gbps per PHY exposed at 50 pin FFC connector.
   * I2C programming and communication iterface to CrossLink and Semtech deserializer.
   * SPI programming interface to program CrossLink.
   * 12 Dip-switches for Semtech configuration pins.
   * 2 led indicators for user purposes
      
Board dimensions
----------------

.. Image:: img/SDI_dimensions.png

