### Localization
d-i debian-installer/language string en
d-i debian-installer/country string FI
d-i debian-installer/locale string en_US.UTF-8

# Keyboard selection.
d-i keyboard-configuration/xkb-keymap select fi


### Network configuration
d-i netcfg/choose_interface select auto
# Automatic network configuration is the default.
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
# Disable that annoying WEP key dialog.
# d-i netcfg/wireless_wep string


### Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string http://ftp.fi.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string


### Account setup
d-i passwd/root-password password ${var.root_password}
d-i passwd/root-password-again password ${var.root_password}
d-i passwd/make-user boolean false
d-i preseed/late_command string \
    in-target sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config


### Clock and time zone setup
# Controls whether or not the hardware clock is set to UTC.
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Helsinki
d-i clock-setup/ntp boolean true


### Partitioning
d-i partman-auto/method string lvm
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto-lvm/new_vg_name string vg0

d-i partman-basicfilesystems/no_swap boolean false
d-i partman-auto/expert_recipe string                         \
      boot-root-data ::                                       \
              256 500 256 ext4                                \
                      $primary{ } $bootable{ }                \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ /boot }                     \
              .                                               \
              ${var.root_size} 10000 ${var.root_size} ext4    \
                      $lvmok{ } lv_name{ root }               \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ / }                         \
              .                                               \
              ${var.data_size} 10000 ${var.data_size} ext4    \
                      $lvmok{ } lv_name{ data }               \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ /data }                     \

d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true


### Base system installation
d-i apt-setup/cdrom/set-first boolean false
d-i apt-setup/services-select multiselect security, updates
d-i apt-setup/security_host string security.debian.org


### Package selection
tasksel tasksel/first multiselect minimal
d-i pkgsel/include string openssh-server
d-i pkgsel/upgrade select safe-upgrade

# disable automatic package updates
d-i pkgsel/update-policy select none
d-i pkgsel/upgrade select full-upgrade

popularity-contest popularity-contest/participate boolean false


### Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev  string default


### Finishing up the installation
# During installations from serial console, the regular virtual consoles
# (VT1-VT6) are normally disabled in /etc/inittab. Uncomment the next
# line to prevent this.
d-i finish-install/keep-consoles boolean true
# Avoid that last message about the install being complete.
d-i finish-install/reboot_in_progress note
