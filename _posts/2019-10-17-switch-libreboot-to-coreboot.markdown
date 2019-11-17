---
layout: post
title: "Switch from Libreboot to coreboot"
date: 2019-10-17 19:20:37 +0200
comments: true
categories: [ "coreboot", "libreboot", "debian", "freebsd" ] 
---

<img src="{{ '/images/coreboot_logo.svg' |  remove_first:'/' | absolute_url }}" class="right" width="160" height="160" alt="coreboot_logo" />

I use(d) [Libreboot](https://libreboot.org/) on my [Lenovo W500](https://stafwag.github.io/blog/blog/2019/02/10/how-to-install-libreboot-on-a-thinkspad-w500/). And it works fine... but I want to install [FreeBSD](https://www.freebsd.org/) on it. The [GRUB](https://www.gnu.org/software/grub/) payload Libreboot uses by default isn't compatible with the FreeBSD bootloader. It is possible to boot FreeBSD from GRUB or try to recompile Libreboot with the [SeaBIOS](https://www.seabios.org/) payload. ...But I just wanted to play with [coreboot](https://www.coreboot.org), to be honest :-)

# Prepare

## Blobs

To install coreboot you normally extract the required blobs from your current BIOS, for obvious reasons I didn't want to do this.
Libreboot has a utility ```ich9gen``` to generated the required blobs - Flash descriptors and GBE (gigabit ethernet) -. 

## Install Debian 10 (buster )

I used Debian GNU/Linux 10 (buster) to compile coreboot.

# Libreboot

We need the ```ich9gen``` utility from Libreboot to generated the Blobs in a Free way with the correct MAC address.
The MAC address is normally on a label inside your laptop, or you can write it down from the output of the ```ifconfig``` command.

## Get gpg key

```
staf@coreboot2:~/libreboot$ gpg --keyserver keys.gnupg.net/ --recv-keys 0x969A979505E8C5B2
gpg: /home/staf/.gnupg/trustdb.gpg: trustdb created
gpg: key 969A979505E8C5B2: public key "Leah Rowe (Libreboot signing key) <info@minifree.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1
staf@coreboot2:~/libreboot$ 
```

## Download

Create the libreboot download directory

```
staf@coreboot2:~$ mkdir libreboot
```

Download the checksum files

```
staf@coreboot2:~/libreboot$ wget https://www.mirrorservice.org/sites/libreboot.org/release/stable/20160907/SHA512SUMS
```

Verify

```
staf@coreboot2:~/libreboot$ gpg --verify SHA512SUMS.sig 
```

## Create gbe.bin with the correct mac address

### Download the libreboot util

#### Download

```
staf@coreboot2:~/libreboot$ wget https://www.mirrorservice.org/sites/libreboot.org/release/stable/20160907/libreboot_r20160907_util.tar.xz
```

#### Verify

```
staf@coreboot2:~/libreboot$ sha512sum libreboot_r20160907_util.tar.xz
c5bfa5a06d55c61e5451e70cd8da3f430b5e06686f9a74c5a2e9fe0e9d155505867b0ca3428d85a983741146c4e024a6b0447638923423000431c98d048bd473  libreboot_r20160907_util.tar.xz
staf@coreboot2:~/libreboot$ 
```

```
staf@coreboot2:~/libreboot$ grep c5bfa5a06d55c61e5451e70cd8da3f430b5e06686f9a74c5a2e9fe0e9d155505867b0ca3428d85a983741146c4e024a6b0447638923423000431c98d048bd473 SHA512SUMS
```

#### Untar

```
staf@coreboot2:~/libreboot$ tar xvf libreboot_r20160907_util.tar.xz
```

#### find

```
staf@coreboot2:~/libreboot$ find ./libreboot_r20160907_util | grep -i ich9gen
./libreboot_r20160907_util/ich9deblob/i686/ich9gen
./libreboot_r20160907_util/ich9deblob/armv7l/ich9gen
./libreboot_r20160907_util/ich9deblob/x86_64/ich9gen
staf@coreboot2:~/libreboot$ 
```

#### Copy

```
staf@coreboot2:~/libreboot$ cp ./libreboot_r20160907_util/ich9deblob/i686/ich9gen .
```

#### Create

```
staf@coreboot2:~/libreboot$ ./ich9gen --macaddress XX:XX:XX:XX:XX:XX
You selected to change the MAC address in the Gbe section. This has been done.

The modified gbe region has also been dumped as src files: mkgbe.c, mkgbe.h
To use these in ich9gen, place them in src/ich9gen/ and re-build ich9gen.

descriptor and gbe successfully written to the file: ich9fdgbe_4m.bin
Now do: dd if=ich9fdgbe_4m.bin of=libreboot.rom bs=1 count=12k conv=notrunc
(in other words, add the modified descriptor+gbe to your ROM image)

descriptor and gbe successfully written to the file: ich9fdgbe_8m.bin
Now do: dd if=ich9fdgbe_8m.bin of=libreboot.rom bs=1 count=12k conv=notrunc
(in other words, add the modified descriptor+gbe to your ROM image)

descriptor and gbe successfully written to the file: ich9fdgbe_16m.bin
Now do: dd if=ich9fdgbe_16m.bin of=libreboot.rom bs=1 count=12k conv=notrunc
(in other words, add the modified descriptor+gbe to your ROM image)

descriptor successfully written to the file: ich9fdnogbe_4m.bin
Now do: dd if=ich9fdnogbe_4m.bin of=yourrom.rom bs=1 count=4k conv=notrunc
(in other words, add the modified descriptor to your ROM image)

descriptor successfully written to the file: ich9fdnogbe_8m.bin
Now do: dd if=ich9fdnogbe_8m.bin of=yourrom.rom bs=1 count=4k conv=notrunc
(in other words, add the modified descriptor to your ROM image)

descriptor successfully written to the file: ich9fdnogbe_16m.bin
Now do: dd if=ich9fdnogbe_16m.bin of=yourrom.rom bs=1 count=4k conv=notrunc
(in other words, add the modified descriptor to your ROM image)

staf@coreboot2:~/libreboot$ 
```

This created the required blobs.

```
staf@coreboot2:~/libreboot$ ls *.bin
flashregion_0_flashdescriptor.bin  flashregion_3_gbe.bin  ich9fdgbe_4m.bin  ich9fdnogbe_16m.bin  ich9fdnogbe_8m.bin
flashregion_1_bios.bin             ich9fdgbe_16m.bin      ich9fdgbe_8m.bin  ich9fdnogbe_4m.bin
staf@coreboot2:~/libreboot$ 

```
# Compile Coreboot

## Install the required packages to compile coreboot

```
staf@coreboot2:~$ sudo apt-get install -y bison build-essential curl flex git gnat libncurses5-dev m4 zlib1g-dev
```

## git clone

```
staf@coreboot2:~$ git clone https://review.coreboot.org/coreboot
```

```
staf@coreboot2:~/coreboot$ git submodule update --init --checkout
```

## make nconfig

Run ```make nconfig``` to get the coreboot configuration menu.

```
            /home/staf/coreboot/.config - coreboot configuration
 ┌── coreboot configuration ───────────────────────────────────────────────┐
 │                                                                         │
 │                          General setup  --->                            │
 │                          Mainboard  --->                                │
 │                          Chipset  --->                                  │
 │                          Devices  --->                                  │
 │                          Generic Drivers  --->                          │
 │                          Security  --->                                 │
 │                          Console  --->                                  │
 │                          System tables  --->                            │
 │                          Payload  --->                                  │
 │                          Debugging  --->                                │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 └F1Help─F2SymInfo─F3Help 2─F4ShowAll─F5Back─F6Save─F7Load─F8SymSearch─F9Exi
```

### Mainboard

Select the ```Mainboard vendor (Lenovo)```, ```Mainboard model (ThinkPad W500)```, ```ROM chip size (8192 KB (8 MB))```.

My W500 has a 8MB Rom chip see [https://stafwag.github.io/blog/blog/2019/02/10/how-to-install-libreboot-on-a-thinkspad-w500/](https://stafwag.github.io/blog/blog/2019/02/10/how-to-install-libreboot-on-a-thinkspad-w500/).

```
           /home/staf/coreboot/.config - coreboot configuration
 ┌── Mainboard ────────────────────────────────────────────────────────────┐
 │                                                                         │
 │     *** Important: Run 'make distclean' before switching boards ***     │
 │     Mainboard vendor (Lenovo)  --->                                     │
 │     Mainboard model (ThinkPad W500)  --->                               │
 │     ROM chip size (8192 KB (8 MB))  --->                                │
 │     System Power State after Failure (S5 Soft Off)  --->                │
 │     ()  fmap description file in fmd format                             │
 │     (0x200000) Size of CBFS filesystem in ROM                           │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 │                                                                         │
 └F1Help─F2SymInfo─F3Help 2─F4ShowAll─F5Back─F6Save─F7Load─F8SymSearch─F9Exi

```

### Chipset

Make sure that the Intel firmware is NOT selected. Normally you'd set it to the path of the extracted firmware, but we'll use the blobs from Libreboot and ```dd``` the Free blobs into coreboot ROM.

```
                               /home/staf/coreboot/.config - coreboot configuration
 ┌── Chipset ───────────────────────────────────────────────────────────────────────────────────────┐
 │                                                                                                  │
 │              *** SoC ***                                                                         │
 │              *** CPU ***                                                                         │
 │          [*] Enable VMX for virtualization (NEW)                                                 │
 │          [*] Set IA32_FEATURE_CONTROL lock bit (NEW)                                             │
 │              Include CPU microcode in CBFS (Generate from tree)  --->                            │
 │              *** Northbridge ***                                                                 │
 │              *** Southbridge ***                                                                 │
 │          [ ] Validate Intel firmware descriptor (NEW)                                            │
 │              *** Super I/O ***                                                                   │
 │              *** Embedded Controllers ***                                                        │
 │          [*] Beep on fatal error (NEW)                                                           │
 │          [*] Flash LEDs on fatal error (NEW)                                                     │
 │          [ ] Support bluetooth on wifi cards (NEW)                                               │
 │              *** Intel Firmware ***                                                              │
 │          [ ] Add Intel descriptor.bin file (NEW)                                                 │
 │              Protect flash regions (Unlock flash regions)  --->                                  │
 │                                                                                                  │
 └F1Help─F2SymInfo─F3Help 2─F4ShowAll─F5Back─F6Save─F7Load─F8SymSearch─F9Exit───────────────────────┘

```

### Payload

Make sure the SeeBIOS payload is selected.

```
                               /home/staf/coreboot/.config - coreboot configuration
 ┌── Payload ───────────────────────────────────────────────────────────────────────────────────────┐
 │                                                                                                  │
 │             Add a payload (SeaBIOS)  --->                                                        │
 │             SeaBIOS version (1.12.1)  --->                                                       │
 │             (5000) PS/2 keyboard controller initialization timeout (milliseconds) (NEW)          │
 │          [ ] Hardware init during option ROM execution (NEW)                                     │
 │          [*] Include generated option rom that implements legacy VGA BIOS compatibility (NEW)    │
 │              ()  SeaBIOS config file (NEW)                                                       │
 │              ()  SeaBIOS bootorder file (NEW)                                                    │
 │          [ ] Add SeaBIOS sercon-port file to CBFS (NEW)                                          │
 │              (-1) SeaBIOS debug level (verbosity) (NEW)                                          │
 │                *** Using default SeaBIOS log level ***                                           │
 │          [ ] Add a PXE ROM (NEW)                                                                 │
 │                 Payload compression algorithm (Use LZMA compression for payloads)  --->          │
 │          [*] Use LZMA compression for secondary payloads (NEW)                                   │
 │              Secondary Payloads  --->                                                            │
 │                                                                                                  │
 │                                                                                                  │
 └F1Help─F2SymInfo─F3Help 2─F4ShowAll─F5Back─F6Save─F7Load─F8SymSearch─F9Exit───────────────────────┘

```

#### Save and exit

Press [ F9 ] to save and exit..

```
                              /home/staf/coreboot/.config - coreboot configuration
 ┌── coreboot configuration ────────────────────────────────────────────────────────────────────────┐
 │                                                                                                  │
 │                               General setup  --->                                                │
 │                               Mainboard  --->                                                    │
 │                               Chipset  --->                                                      │
 │                               Devices  --->                                                      │
 │                               Generic Drivers  --->                                              │
 │                               Security  --->                                                     │
 │                               Console  --->                                                      │
 │                               System tables  --->                                                │
 │                               Payload  --->                                                      │
 │                  ┌─────────────────────────────────────────────┐                                 │
 │                  │ Do you wish to save your new configuration? │                                 │
 │                  │ <ESC> to cancel and resume nconfig.         │                                 │
 │                  │                                             │                                 │
 │                  │            <save>    <don't save>           │                                 │
 │                  └─────────────────────────────────────────────┘                                 │
 │                                                                                                  │
 │                                                                                                  │
 └F1Help─F2SymInfo─F3Help 2─F4ShowAll─F5Back─F6Save─F7Load─F8SymSearch─F9Exit───────────────────────┘

```

## Compiling

### Compile the compiler

The first setup is to compile to compiler to compile coreboot. You can specify the number of core to use with ```CPUS=```.

```
staf@coreboot2:~/coreboot$ make crossgcc-i386 CPUS=4
```

### compile coreboot

Run ```make``` to compile your BIOS.

```
staf@coreboot2:~/coreboot$ make
Skipping submodule '3rdparty/amd_blobs'
Skipping submodule '3rdparty/blobs'
Skipping submodule '3rdparty/fsp'
Skipping submodule '3rdparty/intel-microcode'
#
# configuration written to /home/staf/coreboot/.config
#
<snip>
Built lenovo/t400 (ThinkPad W500)

        ** WARNING **
coreboot has been built without an Intel Firmware Descriptor.
Never write a complete coreboot.rom without an IFD to your
board's flash chip! You can use flashrom's IFD or layout
parameters to flash only to the BIOS region.

staf@coreboot2:~/coreboot$ 
```

## add the Libreboot desciption and gbe image

### add it

Copy the coreboot ROM.

```
staf@coreboot2:~/coreboot$ cp ./build/coreboot.rom my_w500.rom
```

and add the Libreboot desciption and gbe image.

```
staf@coreboot2:~/coreboot$ dd if=~/libreboot/ich9fdgbe_8m.bin of=my_w500.rom bs=12k count=1 conv=notrunc
1+0 records in
1+0 records out
12288 bytes (12 kB, 12 KiB) copied, 0.000726109 s, 16.9 MB/s
staf@coreboot2:~/coreboot$ 
```

### test the image with ifdtool

Coreboot includes an utility ```ifdtool``` to extract the blogs from a ROM. We use ```ifdtool``` to test our ROM.

#### Compile and install ifdtool

Goto the ```ifdtool``` source directory.

```
staf@coreboot2:~/coreboot$ cd util/ifdtool/
```

and run ```make install``` this will install ```ifdtool``` to the ```/usr/local/bin/``` directory.

```
staf@coreboot2:~/coreboot/util/ifdtool$ sudo make install
[sudo] password for staf: 
gcc -O2 -g -Wall -Wextra -Wmissing-prototypes -Werror -I../../src/commonlib/include -I../cbfstool/flashmap -include ../../src/commonlib/include/commonlib/compiler.h -c -o ifdtool.o ifdtool.c
gcc -O2 -g -Wall -Wextra -Wmissing-prototypes -Werror -I../../src/commonlib/include -I../cbfstool/flashmap -include ../../src/commonlib/include/commonlib/compiler.h -c -o fmap.o ../cbfstool/flashmap/fmap.c
gcc -O2 -g -Wall -Wextra -Wmissing-prototypes -Werror -I../../src/commonlib/include -I../cbfstool/flashmap -include ../../src/commonlib/include/commonlib/compiler.h -c -o kv_pair.o ../cbfstool/flashmap/kv_pair.c
gcc -O2 -g -Wall -Wextra -Wmissing-prototypes -Werror -I../../src/commonlib/include -I../cbfstool/flashmap -include ../../src/commonlib/include/commonlib/compiler.h -c -o valstr.o ../cbfstool/flashmap/valstr.c
gcc -o ifdtool ifdtool.o fmap.o kv_pair.o valstr.o 
mkdir -p /usr/local/bin
/usr/bin/env install ifdtool /usr/local/bin
staf@coreboot2:~/coreboot/util/ifdtool$ 
```

#### test it

```
staf@coreboot2:~/coreboot$ ifdtool -x my_w500.rom 
File my_w500.rom is 8388608 bytes
  Flash Region 0 (Flash Descriptor): 00000000 - 00000fff 
  Flash Region 1 (BIOS): 00003000 - 007fffff 
  Flash Region 2 (Intel ME): 00fff000 - 00000fff (unused)
  Flash Region 3 (GbE): 00001000 - 00002fff 
  Flash Region 4 (Platform Data): 00fff000 - 00000fff (unused)
staf@coreboot2:~/coreboot$ 
```

# Flash


I had already a custom rom (LibreBoot) on my system, this makes it possible to flash the BIOS without the need to disassemble the laptop to flash it with a clip.

<a href="{{ '/images/switch-libreboot-to-coreboot/grml_relaxed.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/switch-libreboot-to-coreboot/grml_relaxed.png' | remove_first:'/' | absolute_url }}" class="left" width="500" height="333" alt="w500 and pi" /></a>
See [How to install Libreboot on a ThinkPad W500](https://stafwag.github.io/blog/blog/2019/02/10/how-to-install-libreboot-on-a-thinkspad-w500/) if need to flash it from the first time or if you bricked your laptop by flashing a invalid ROM onto it.


## Grml

I used [Grml ](https://grml.org/) to flash coreboot, Grml is nice live GNU/Linux distribution that has [flashrom](https://www.flashrom.org/) included. You'll need to boot it with the ```iomem=relaxed``` kernel paramter to able to flash the BIOS.

Press [ TAB ] on the boot screen and add ```iomem=relaxed``` and press [ ENTER ] to boot.

## test

```
root@grml ~ # flashrom -p internal:laptop=force_I_want_a_brick 
flashrom v0.9.9-r1954 on Linux 4.19.0-1-grml-amd64 (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
coreboot table found at 0x7fad6000.
========================================================================
WARNING! You seem to be running flashrom on an unsupported laptop.
Laptops, notebooks and netbooks are difficult to support and we
recommend to use the vendor flashing utility. The embedded controller
(EC) in these machines often interacts badly with flashing.
See the manpage and https://flashrom.org/Laptops for details.

If flash is shared with the EC, erase is guaranteed to brick your laptop
and write may brick your laptop.
Read and probe may irritate your EC and cause fan failure, backlight
failure and sudden poweroff.
You have been warned.
========================================================================
Proceeding anyway because user forced us to.
Found chipset "Intel ICH9M-E".
Enabling flash write... OK.
Found Macronix flash chip "MX25L6405" (8192 kB, SPI) mapped at physical address 0x00000000ff800000.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) mapped at physical address 0x00000000ff800000.
Found Macronix flash chip "MX25L6406E/MX25L6408E" (8192 kB, SPI) mapped at physical address 0x00000000ff800000.
Found Macronix flash chip "MX25L6436E/MX25L6445E/MX25L6465E/MX25L6473E" (8192 kB, SPI) mapped at physical address 0x00000000ff800000.
Multiple flash chip definitions match the detected chip(s): "MX25L6405", "MX25L6405D", "MX25L6406E/MX25L6408E", "MX25L6436E/MX25L6445E/MX25L6465E/MX25L6473E"
Please specify which chip definition to use with the -c <chipname> option.
1 root@grml ~ #                                                                                                     :(

```

## read the bios

```
1 root@grml ~ # flashrom -c "MX25L6405D" -p internal:laptop=force_I_want_a_brick -r w500libreboot.rom               :(
flashrom v0.9.9-r1954 on Linux 4.19.0-1-grml-amd64 (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
coreboot table found at 0x7fad6000.
========================================================================
WARNING! You seem to be running flashrom on an unsupported laptop.
Laptops, notebooks and netbooks are difficult to support and we
recommend to use the vendor flashing utility. The embedded controller
(EC) in these machines often interacts badly with flashing.
See the manpage and https://flashrom.org/Laptops for details.

If flash is shared with the EC, erase is guaranteed to brick your laptop
and write may brick your laptop.
Read and probe may irritate your EC and cause fan failure, backlight
failure and sudden poweroff.
You have been warned.
========================================================================
Proceeding anyway because user forced us to.
Found chipset "Intel ICH9M-E".
Enabling flash write... OK.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) mapped at physical address 0x00000000ff800000.
Reading flash... done.
flashrom -c "MX25L6405D" -p internal:laptop=force_I_want_a_brick -r   7.38s user 0.01s system 99% cpu 7.392 total
```

and again

```
root@grml ~ # flashrom -c "MX25L6405D" -p internal:laptop=force_I_want_a_brick -r w500libreboot2.rom
flashrom v0.9.9-r1954 on Linux 4.19.0-1-grml-amd64 (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
coreboot table found at 0x7fad6000.
========================================================================
WARNING! You seem to be running flashrom on an unsupported laptop.
Laptops, notebooks and netbooks are difficult to support and we
recommend to use the vendor flashing utility. The embedded controller
(EC) in these machines often interacts badly with flashing.
See the manpage and https://flashrom.org/Laptops for details.

If flash is shared with the EC, erase is guaranteed to brick your laptop
and write may brick your laptop.
Read and probe may irritate your EC and cause fan failure, backlight
failure and sudden poweroff.
You have been warned.
========================================================================
Proceeding anyway because user forced us to.
Found chipset "Intel ICH9M-E".
Enabling flash write... OK.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) mapped at physical address 0x00000000ff800000.
Reading flash... done.
flashrom -c "MX25L6405D" -p internal:laptop=force_I_want_a_brick -r   7.37s user 0.02s system 99% cpu 7.393 total
root@grml ~ # 
```

### compare

```
root@grml ~ # sha1sum w500libreboot*
67438673dd5411bae91ced0e4fdbff06d328ba75  w500libreboot2.rom
67438673dd5411bae91ced0e4fdbff06d328ba75  w500libreboot.rom
root@grml ~ # 
```

### write

```
139 root@grml ~ # flashrom -c "MX25L6405D" -p internal:boardmismatch=force,laptop=force_I_want_a_brick -w coreboot.rom
flashrom v0.9.9-r1954 on Linux 4.19.0-1-grml-amd64 (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
coreboot table found at 0x7fad6000.
========================================================================
WARNING! You seem to be running flashrom on an unsupported laptop.
Laptops, notebooks and netbooks are difficult to support and we
```

*** Have fun ***


# Links

* [https://wiki.gentoo.org/wiki/Coreboot](https://wiki.gentoo.org/wiki/Coreboot)
* [https://flashrom.org/FAQ](https://flashrom.org/FAQ)
