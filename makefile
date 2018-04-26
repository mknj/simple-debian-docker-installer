all: debian_stretch_docker.iso
prepare:
        apt-get update
	apt-get install genisoimage bsdtar cpio curl make
example-preseed.txt:
	curl -O https://www.debian.org/releases/stable/example-preseed.txt
mini.iso:
	curl -O http://cdn-fastly.deb.debian.org/debian/dists/Debian9.4/main/installer-amd64/current/images/netboot/mini.iso
#	curl -O http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/alpine-virt-3.7.0-x86_64.iso

starttestvm:
	kvm -hda vm.qcow2 -boot c -net nic -net user -m 256 -localtime -k de
installtestvm:
	qemu-img create -f qcow2 vm.qcow2 8G
	kvm -cdrom debian_stretch_docker.iso -hda vm.qcow2 -boot d -net nic -net user -m 256 -localtime -k de
debian_stretch_docker.iso: mini.iso preseed.cfg
	rm -rf iso
	mkdir iso
	bsdtar -C "iso" -xf - <mini.iso
	find iso|xargs chmod +w
	gunzip iso/initrd.gz
	echo preseed.cfg | cpio -H newc -o -A -F iso/initrd
	gzip iso/initrd
	sed -i -e "s/Install/FORMAT C: and install docker/" iso/txt.cfg
	genisoimage -r -J -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o debian_stretch_docker.iso iso
