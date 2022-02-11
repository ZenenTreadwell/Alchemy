# This Makefile exists because it's my favorite way to simplify running groups of commands directly from the command line
#
# Variables
IMAGE := raspios_lite_arm64.zip
DOWNLOAD_LINK := https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-11-08/2021-10-30-raspios-bullseye-arm64-lite.zip

aesthetic:
	@chmod +x scripts/init.sh
	@scripts/init.sh

autonomy:
	@chmod +x scripts/ao.sh
	@scripts/ao.sh

acquisition:
	@chmod +x scripts/get-image.sh
	@scripts/get-image.sh

imbuement:
	@chmod +x scripts/write-image.sh
	@scripts/write-image.sh

preparations:
	@chmod +x scripts/prep-rpi-usb.sh
	@scripts/prep-rpi-usb.sh
		
manifest:
	@chmod +x scripts/wordpress.sh
	@scripts/wordpress.sh
