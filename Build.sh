#!/bin/bash
#########################################
# Checking If You Are Root or NOT       #
 if [ "$EUID" -ne 0 ]                   #
 then echo "Please run as root"         #
   exit                                 #
fi                                      #
#########################################
# Setting Variables 

osname="CodeX-OS"
codename="CodeX"
osbuilder="MenaMaged"
version="v3.0"
arch="amd64"
nvdia="true"
kernel="(kernel 5.10.0-13-amd64)"
baseimg=DVD.iso
volume="$osname"
customimg=tmp/$osname
#isoname="$osname-DVD-$(date -u)"
isoname="$osname-$arch-DVD"
rtdir="tmp/root"
etc="$rtdir/etc"
squshfs="$customimg/live/filesystem.squashfs"
moddir=sysmods
basesys=$moddir/isort
hosts="$rtdir/etc/hosts"
osurl="https://www.codexeg.net/"
################################################################################
# Initialization 
init (){
echo -e "\e[1;31mCleaning old Work Directories"
#mount $baseimg
rm -r -f tmp
echo -e "\e[1;31mCreating New Work Directories"
mkdir tmp
mkdir $rtdir
mkdir tmp/$osname
echo -e "\e[1;31mMounting the base ISO "
#mount $baseimg $basesys -o loop
echo -e "\e[1;31mCopying Data to the Customization Directory"
cp -r $basesys/* $customimg/
}
echo -e "\e[1;31mChoosen Config is:"
echo -e "\e[1;31mArchitecture: \e[1;37m$arch"
sleep 1
echo -e "\e[1;31mBuilt By: \e[1;37m$osbuilder"
sleep 1
#########################################################################################
bootsrtb()
{
debootstrap --arch $arch bullseye $rtdir http://deb.debian.org/debian/
}
##############################################################
#Building iso 
build(){
echo -e "\e[1;31mBuilding \e[1;37m$osname \e[1;31mISO"
xorriso -as mkisofs -iso-level 3 -A "$isoname-Live" -p "$osbuilder" -publisher "$osbuilder" -V "$volume" -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -o "$isoname.iso" tmp/$osname
}
###############################################################
adblk()
{
  echo " Starting AD BLOCKER"
echo "hosts file location is '$hosts'"
echo "Date: $(date)" > $hosts
url1="https://adaway.org/hosts.txt"
url2="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
url3="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
echo "Fetching $url1"
sudo curl $url1 >> "$hosts"
echo "Fetching $url2"
sudo curl $url2 >> "$hosts"
echo "Fetching $url3"
sudo curl $url3 >> "$hosts"
}
################################################################################
# Modding SYSTEM 
sysmod(){
echo -e "\e[1;31mInstalling Mac Theme"
rm -r -f $rtdir/usr/share/palsma/desktoptheme/*
rm -r -f $rtdir/usr/share/palsma/look-and-feel/org*
#rm -r -f $rtdir/usr/share/aurorae/themes/*
rm -r -f $rtdir/usr/share/color-schemes/*
rm -r -f $rtdir/usr/share/icons/breeze*
rm -r -f $rtdir/usr/share/icons/oxygen*
rm -r -f $rtdir/usr/share/Kvantum/*
#rm -r -f $rtdir/usr/share/plymouth/*
rm -r -f $rtdir/usr/share/desktop-base/*
#rm -r -f $rtdir/usr/share/sddm/themes/*
#rm -r -f $rtdir/etc/xdg/colors/*
cp -r $moddir/rootf/* $rtdir/
#wget https://build.anbox.io/android-images/2018/06/12/android_amd64.img > $rtdir/var/lib/anbox/android.img
#adblk
}
###################################################################################################################################
#Nvdia
nvdiain(){
  if [ $nvdia = "true" ] 
then
echo "Installing Nvdia Drivers"
chroot $rtdir/ apt install nvidia-driver
 fi

}
##################################################
#rtmod
chrot()
{

echo -e "\e[1;31mAdding Dns"
echo 'nameserver 8.8.8.8' > $etc/resolv.conf
echo -e "\e[1;31mAdding Sources.list"
chroot $rtdir/ apt install wget gpg gnupg* -y
chroot $rtdir/ apt install linux-image-$arch -y

sudo chroot $rtdir/ wget -O- https://dl.google.com/linux/linux_signing_key.pub | sudo chroot $rtdir/ gpg --dearmor > $etc/apt/trusted.gpg.d/google.gpg 
sudo chroot $rtdir/ wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo chroot $rtdir/ apt-key add -
sudo chroot $rtdir/ wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo chroot $rtdir/ apt-key add -
sudo chroot $rtdir/  wget -O - http://apt.metasploit.com/metasploit-framework.gpg.key | sudo chroot $rtdir/ apt-key add -
sleep 1

echo "deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free
deb http://deb.debian.org/debian/ buster-updates main contrib non-free
deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free
deb http://deb.debian.org/debian/ bullseye main contrib
deb-src http://deb.debian.org/debian/ bullseye main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
deb-src http://security.debian.org/debian-security bullseye-security main contrib
deb http://deb.debian.org/debian/ bullseye-updates main contrib
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib
deb http://ftp.us.debian.org/debian stretch main contrib non-free
deb-src http://ftp.us.debian.org/debian stretch main contrib non-free
deb http://deb.debian.org/debian buster-backports main contrib non-free
deb https://packages.microsoft.com/repos/vscode stable main
deb http://deb.anydesk.com/ all main
deb http://downloads.metasploit.com/data/releases/metasploit-framework/apt lucid main
deb http://dl.google.com/linux/chrome/deb/ stable main
"> $etc/apt/sources.list
echo -e "\e[1;31mAdding os-release"
echo "$codename-PC" > $etc/hostname
echo "PRETTY_NAME="$osname GNU/Linux $version \($codename\)"
NAME="$osname"
VERSION_ID="$version"
VERSION="$version \($codename\)"
VERSION_CODENAME=$codename
ID=$codename
HOME_URL="$osurl"
" > $etc/os-release
chroot $rtdir/ apt update 
sleep 5
chroot $rtdir/ apt install --fix-broken
echo -e "\e[1;31mInstalling Packages"
sleep 2
chroot $rtdir/ apt install calamares pulseaudio-module-bluetooth firmware-linux firmware-iwlwifi kde-spectacle google-chrome-stable cheese eom brasero shotcut geany inkscape net-tools gpm sudo curl cmake gnome-keyring ssh gdebi telnet wpasupplicant xserver-xorg-video-vesa xserver-xorg-input-all adb tlp vlc gcc build-essential libreoffice libreoffice-kde5 ark code anydesk anbox -y
echo -e "\e[1;31mInstalling Wine"
chroot $rtdir/ apt install wine* -y
nvdiain

echo -e "\e[1;31mInstalling Plasma"
chroot $rtdir/ apt install kde-plasma-desktop -y
chroot $rtdir/ apt install plasma-nm -y
chroot $rtdir  apt install qt5-style-kvantum qt5-style-kvantum-themes -y
sysmod

}
###################################################################################################################################
# Modding Squashfs
modimg(){

#echo -e "\e[1;31mUnsquashing FileSystem"
#unsquashfs -d $rtdir $squshfs
#echo -e "\e[1;31mRemoving Stock FileSystem"
rm -f $squshfs
chroot $rtdir passwd -d root
chrot
echo -e "\e[1;31mSquashing FileSystem"
mksquashfs $rtdir/ $squshfs -comp xz
}
####################################################################################################################################
###
init
bootsrtb
modimg
build  
