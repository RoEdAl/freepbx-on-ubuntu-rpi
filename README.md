# Unattended installation of *FreePBX* on *Ubuntu Server for Raspberry Pi* via *cloud-init*.

This project demonstrates how to create `user-data` (part of `cloud-init` database) with desciption
how to download and install *FreeBPX* on *Ubuntu Server for Raspberry Pi* at first boot.

This solution was tested on:

* *Raspberry Pi* 2B (32-bit only),
* *Raspberry Pi* 3B(+),
* *Raspberry Pi* 4B.

## Why *cloud-init*?

*Cloud-init* is a software mainly developed for cloud server instances that will set up the server automatically using the provided metadata.
This metadata describes how your server should look like, e.g. which packages should be installed and commands that’ll be executed on init.
Even if it is focused on cloud instances it may be used on real machines too.
All editions of *Ubuntu Server* distribution (incluing *Raspberry Pi* ones) have *cloud-init* preintstallled so it may be used to (pre)install *FreePBX*.

## Usage

### Basic usage

- Download [Ubutnu Server for Raspberry Pi](http://ubuntu.com/download/raspberry-pi) image and write it to *microSD* card.
- [Download](http://github.com/RoEdAl/freepbx-on-ubuntu-rpi/releases/latest) and extract proper *cloud-init* package:

    * for 64-bit version use `cloud-init-arm64.7z` package,
    * for 32-bit version use `cloud-init-armhf.7z` package.

- **Before** inserting your *microSD* card into *Raspberry Pi*  copy some files from `cloud-init` package to it:

  * Copy `user-data` file to root directory of the first partition (FAT, label: **system-boot**).
  * **Optional**: Copy `network-config` file to root directory of the first partition (FAT, label: **system-boot**).
  * **Optional**: Copy `05_logging.cfg` file to `/etc/cloud/cloud.cfg.d` directory of the second partition (EXT4, label: **writable**).

- Insert microSD card into your *Raspberry Pi*, connect Ethernet and apply power.

  Please do not connect a monitor or keyboard. During installation *Raspberry Pi* will be
  configured as **headless** machine so for example HDMI will be **turned off** after reboot.

- Use the serial console or SSH to the IP address given to the board by your router.

  User and password: **ubuntu**. At first login you will be forced to change password.
  **Be patient**: It may take several minutes before you can log in to your Pi.

  You may check *cloud-init* status by following command:

  ```sh
  cloud-init status
  ```

  Possible answers:

  * `status: running`,
  * `status: done`.

  **Be patient**: The full installation process of *FreePBX* may take up to an hour!.
  After (hopefully successfull) instalation you must reboot your machine.

### Advanced usage - building custom images.

You may also create customized *Ubuntu Server* images:

#### Requirements:

* [cloud-init](http://cloudinit.readthedocs.io/en/latest/),
* [(go-)task](http://taskfile.dev),
* [yq](http://mikefarah.gitbook.io/yq/),
* libarchive-tools (bsdtar).

#### Building

Clone this repository and execute following commands:

```sh
task download-ubuntu-server-lts-img
sudo task process-ubuntu-imgs
```

Modified images will be created into `build` folder.

## What is the format of `user-data` file?

Currently `user-data` is a gzip compressed *MIME multi-part archive*.
Multi-part archive contains:

* cloud config file (YAML format),
* few shell scripts.

You may check theese files on running *Rapberry Pi*:

* cloud config file: `/var/lib/cloud/instance/cloud-config.txt`,

   ```sh
   sudo yq /var/lib/cloud/instance/cloud-config.txt
   ```

* scripts directory: `/var/lib/cloud/instance/scripts`.

  ```sh
  sudo cat /var/lib/cloud/instance/scripts/*.sh
  ```

See [cloud-init: User data formats](http://cloudinit.readthedocs.io/en/latest/explanation/format.html) for more info about user data formats.

## Links

* [Cloud-Init: The Good Parts](http://www.hashicorp.com/resources/cloudinit-the-good-parts),
* [FreePBX](http://www.freepbx.org/),
* [Ubuntu for Raspberry Pi](https://ubuntu.com/download/raspberry-pi),
* [Installing FreePBX 16 on Debian 10.9](http://wiki.freepbx.org/display/FOP/Installing+FreePBX+16+on+Debian+10.9).
