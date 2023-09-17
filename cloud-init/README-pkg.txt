Unattended instalation of FreePBX on Ubuntu for Raspberry Pi via cloud-init.

Installation:

- Download Ubutnu for Raspberry Pi image and write image to microSD card.
- BEFORE inserting your microSD card into Raspberry Pi copy some files from this package to it:

    - Copy user-data file to root directory of the first partition (FAT, label: system-boot).
    - OPTIONAL Copy network-config file to root directory of the first partition (FAT, label: system-boot).
    - OPTIONAL Copy 05_logging.cfg file to /etc/cloud/cloud.cfg.d directory of the second partition (EXT4, label: writable).

- Insert microSD card into your Raspberry Pi, plug Ethernet cable and power supply.
- After boot login to your machine via SSH. User and password: ubuntu.

  Be patient. It may take several minutes before you can log in to your computer.
  At first login you will be forced to change password.

- You may check check installation process just by following journal logs:
  
  # journalctl -f

- You may also check cloud-init status by following command:

  # cloud-init status

--------------------

The installation process of FreePBX may take up to half an hour or even more so be patient!
After successfull instalation you must reboot machine.

# sudo reboot

After reboot you may upgrade your system also:

# sudo apt upgrade

Check also apache2 and freepbx services status:

# systemctl status apache2 freepbx
