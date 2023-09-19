Unattended instalation of FreePBX on Ubuntu for Raspberry Pi via cloud-init.

Installation:

- Download Ubutnu for Raspberry Pi image and write it to microSD card.

  Download link: http://ubuntu.com/download/raspberry-pi

- BEFORE inserting your microSD card into Raspberry Pi copy some files from this package to it:

  - Copy user-data file to root directory of the first partition (FAT, label: system-boot).
  - OPTIONAL Copy network-config file to root directory of the first partition (FAT, label: system-boot).
  - OPTIONAL Copy 05_logging.cfg file to /etc/cloud/cloud.cfg.d directory of the second partition (EXT4, label: writable).

- Insert microSD card into your Raspberry Pi, connect Ethernet and apply power.
- Use the serial console or SSH to the IP address given to the board by your router.

  User and password: ubuntu.
  At first login you will be forced to change password.
  
  Be patient. It may take several minutes before you can log in to your Pi.

- You may check check installation process just by following journal logs:
  
  # journalctl -f

- You may also check cloud-init status by following command:

  # cloud-init status

--------------------

The installation process of FreePBX may take up to an hour so be patient!
After successfull instalation you must reboot machine.

# sudo reboot

After reboot you may upgrade your system:

# sudo apt upgrade

Check also apache2 and freepbx services status:

# systemctl status apache2 freepbx
