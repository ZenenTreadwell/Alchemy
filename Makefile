# This Makefile exists because it's my favorite way to simplify running
# groups of commands directly from the command line
# Bare Metal Alchemist, 2022

alchemy:
	@chmod +x recipes/alchemy.sh
	@recipes/alchemy.sh

aesthetic:
	@chmod +x recipes/init.sh
	@recipes/init.sh

autonomy:
	@chmod +x recipes/ao.sh
	@recipes/ao.sh

acquisition:
	@chmod +x recipes/get-image.sh
	@recipes/get-image.sh

imbuement:
	@chmod +x recipes/write-image.sh
	@recipes/write-image.sh

preparations:
	@chmod +x recipes/prep-rpi-usb.sh
	@recipes/prep-rpi-usb.sh

prosperity:
	@echo "This will install prestashop eventually"

free:
	@echo "This will install freespace, once it exists"
		
manifest:
	@chmod +x recipes/wordpress.sh
	@recipes/wordpress.sh

help:
	@cat README.md





































# Extra stuff to make it fun / interesting
something:
	@echo "You might need to be a little more creative than that..."

cool: 
	@echo "Maybe try 'make help' if you're confused?"

arcana:
	$(eval MOD = cd 🜍;)
	@cd ~

curiosus:
	@$(MOD) ls

signum:
	@$(MOD) pwd


