# Alchemy
A collection of scripts for working with bare metal.

## Initialization
This script package requires some initialization to make sure that the system it runs on has the necessary tools to work properly.
Run `./init.sh` to set up the environment (**You might have to run `chmod +x init.sh` to use it**)

## Commands

`make acquisition` runs a script that downloads a file (either Raspbian or Manjaro) and confirms it with a sha256 sum.

`make imbuement` looks for available USBs attached to the device and writes an image to it.

`make preparations` configures some basic settings for use on a fresh RPi installation (SSH, hostname)

`make aesthetic` is meant to be run on a freshly installed operating system.
It installs some utilities that I rely on for maximum developmental efficiency and generally makes the terminal nicer to look at.

`make autonomy` runs an interactive installer to get AO up and running on the current system

`make manifest` Installs and configures Wordpress on the system

### A Note on "resources" vs. "images"
the `images/` folder is where alchemy scripts will store files meant to be written to hard drives, generally operating systems.
Due to the nature of images being both bulky and platform-dependent, they are not included by default in this ecosystems.

The `resources/` folder contains templates and other files that are small enough to be moved around with the scripts.
Some of these files are fragile and should be considered read-only.
