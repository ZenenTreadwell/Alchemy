# Alchemy
A collection of scripts for working with bare metal.

## Commands
`make it-pretty` is meant to be run on a freshly installed operating system.
It installs some utilities that I rely on for maximum developmental efficiency and generally makes the terminal nicer to look at.

`make acquisition` runs a script that downloads a file (in this case, an RPI image) and confirms it with a sha256 sum.

`make imbuement` looks for available USBs attached to the device and writes an image to it.

`make preparations` configures some basic settings for use on a fresh RPi installation (SSH, hostname)
