#!/usr/bin/env bash

apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y git
apt-get install -y gcc-avr
apt-get install -y avr-libc
apt-get install -y gcc-arm-none-eabi

# https://github.com/bbcmicrobit/micropython/issues/514
rm *.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-dev_3.0.0.20180802-2_all.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb
dpkg -iy libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb libnewlib-dev_3.0.0.20180802-2_all.deb 
apt-get install -y make
python3 -m pip install --upgrade pip
pip3 install jupyter
pip3 install numpy
pip3 install tqdm
pip3 install matplotlib
pip3 install termcolor
pip3 install jupyter_contrib_nbextensions
jupyter contrib nbextension install --system

#currently need to manually enable these...doing this doesn't work
jupyter nbextensions enable toc2/main
jupyter nbextensions enable collapsible_headings/main

pip install jupyter_nbextensions_configurator
jupyter nbextensions_configurator enable --system

echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"2b3e\", ATTRS{idProduct}==\"ace2\", MODE=\"0664\", GROUP=\"plugdev\"" > /etc/udev/rules.d/99-newae.rules
usermod -a -G plugdev vagrant
udevadm control --reload-rules
git clone https://github.com/newaetech/chipwhisperer
chown -R vagrant:vagrant chipwhisperer
cd chipwhisperer/software
git checkout cw5dev
git pull
python3 setup.py install
