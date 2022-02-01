# Alchemy
A collection of scripts for working with bare metal.

## Commands

`make acquisition` runs a script that downloads a file (either Raspbian or Manjaro) and confirms it with a sha256 sum.

`make imbuement` looks for available USBs attached to the device and writes an image to it.

`make preparations` configures some basic settings for use on a fresh RPi installation (SSH, hostname)

`make it-pretty` is meant to be run on a freshly installed operating system.
It installs some utilities that I rely on for maximum developmental efficiency and generally makes the terminal nicer to look at.

`make autonomy` runs an interactive installer to get AO up and running on the current system

`make manifest` Installs and configures Wordpress on the system

### A Note on "resources" vs. "images"
These are two folders that scripts will pull data from and write data to. In no case should any of these files be modified directly.
Scripts will copy them to a workspace or the base directory and make modifications there before implementing them.

The difference between a 'resource' and an 'image' (in the case of this ecosystem) is that *resources are platform agnostic*, meaning
that they will apply universally to whatever system they are installed on. Conversely, *images are platform-specific*, and therefore
are subject to the architecture of the computer system in order to do what they need to do.

For the sake of not filling this project with unnecessary data, I will rely on download scripts to populate the images folder.

