# OrangePi+ Kernel

This repository helps building a Linux 3.4.39 kernel for an [OrangePiPlus](http://linux-sunxi.org/Xunlong_Orange_Pi_Plus) board.

It is based on [Boris Lovosevic (loboris)](https://github.com/loboris/OrangePI-Kernel/) kernel, however
  * it produces a smaller kernel (800 k instead of 1M),
  * more drivers are included in.

## Usage

   Customize kernel version in the **mybuild.sh** shell-script, then run ``./mybuild.sh``.
   
   After installing and booting on the new kernel, don't forget to perform a ``depmod -a``.

## Issues
  * how to use a 4.x kernel? (or even a more recent 3.x one)
  * update kernel version in mybuild.sh script
  * nand driver ?
  * using a more recent toolchain
  * creating debian packages

