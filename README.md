# Alchemy
A collection of scripts for transmuting bare metal and encouraging
autonomous decentralization.

## Initialization
Ideally, this package should be able to be initialized by running `make alchemy`.
It may be the case that your system does not support `make` by default,
in which case you can initialize the environment by running the following:
`chmod +x recipes/alchemy.sh; recipes/alchemy.sh`

## Recipes
Recipes are a core component of the Alchemy ecosystem. They are stored
in the `recipes/` directory and common ones can be sourced via make.

Some basic recipes are listed below:

`make autonomy` runs an interactive installer to get AO up and running on the current system

`make acquisition` runs a script that downloads a file (either Raspbian or Manjaro) and confirms it with a sha256 sum.

`make imbuement` looks for available USBs attached to the device and writes an image to it.

`make preparations` configures some basic settings for use on a fresh RPi installation (SSH, hostname)

`make aesthetic` is meant to be run on a freshly installed operating system.
It installs some utilities that I rely on for maximum developmental
efficiency and generally makes the terminal nicer to look at.

`make manifest` Installs and configures Wordpress on the system

## Ingredients
Another core component of the Alchemy ecosystem are ingredients, which
are groups of shell commands that can be sourced for use in recipes.
These ingredients loosely follow themes which are outlined in greater
detail within the ingredient files iteself. Brief summaries:

`lead` is the base component for recipes and other ingredients as well.
It provides infrastructure that makes development in Alchemy more accessible.

`tin` corresponds to hardware and interaction with physical systems.

`iron` forms the core of web development and system operation

`copper` corresponds to connectivity to other systems on the network.

`silver` is an ethical system of currency that is aimed to support the trade
of goods and services within a smaller community. **WIP**

`gold` corresponds to the Bitcoin/Lightning ecosystem.

### Other folders
the `images/` folder is where alchemy scripts will store files meant to be written to hard drives, generally operating systems.
Due to the nature of images being both bulky and platform-dependent, they are not included by default in this ecosystems.

The `resources/` folder contains templates and other files that are small enough to be moved around with the scripts.
Some of these files are fragile and should be considered read-only.

### Design Notes
#### POSIX Compatibility
This is important to aim for in the name of making something that is
as universal as possible. Aim to only use /bin/sh compatible syntax.
