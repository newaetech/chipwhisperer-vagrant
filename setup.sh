#!/usr/bin/env bash

# normal apt installs
apt-get update
apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y git
apt-get install -y gcc-avr
apt-get install -y avr-libc
apt-get install -y gcc-arm-none-eabi
apt-get install -y make

# https://github.com/bbcmicrobit/micropython/issues/514
# Ubuntu 18.04 arm-none-eabi-gcc has broken libc/nano specs (always tries to use full arm w/invalid instructions)
rm *.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-dev_3.0.0.20180802-2_all.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb
dpkg -i libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb libnewlib-dev_3.0.0.20180802-2_all.deb 

# pip installs
python3 -m pip install --upgrade pip
pip3 install jupyter
pip3 install numpy
pip3 install tqdm
pip3 install matplotlib
pip3 install termcolor
pip3 install jupyter_contrib_nbextensions
pip3 install bokeh
pip3 install jupyter_nbextensions_configurator

# jupyter stuff
jupyter contrib nbextension install --system



# USB permissions
echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"2b3e\", ATTRS{idProduct}==\"ace2\", MODE=\"0664\", GROUP=\"plugdev\"" > /etc/udev/rules.d/99-newae.rules
echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"2b3e\", ATTRS{idProduct}==\"ace0\", MODE=\"0664\", GROUP=\"plugdev\"" >> /etc/udev/rules.d/99-newae.rules
usermod -a -G plugdev vagrant
udevadm control --reload-rules

# get chipwhisperer and install
git clone https://github.com/newaetech/chipwhisperer
chown -R vagrant:vagrant chipwhisperer
cd chipwhisperer/software
git checkout cw5dev
git pull
python3 setup.py install

# copy cron script from vagrant folder
cp /vagrant/run_jupyter.sh /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/run_jupyter.sh
chmod +x /home/vagrant/run_jupyter.sh

# copy jupyter config
mkdir -p /home/vagrant/.jupyter
cp /vagrant/jupyter_notebook_config.py /home/vagrant/.jupyter/

# make sure jupyter is under the vagrant user
# maybe just make /home/vagrant all vagrant?
chown vagrant:vagrant -R /home/vagrant/

# currently need to manually enable these...doing this doesn't work
# wrong path?
sudo -Hu vagrant jupyter nbextension enable toc2/main
sudo -Hu vagrant jupyter nbextension enable collapsible_headings/main

jupyter nbextensions_configurator enable --system

# check if cron job already inserted, and if not insert it
if !(crontab -u vagrant -l | grep "run_jupyter\.sh"); then
    (crontab -u vagrant -l 2>/dev/null; echo "@reboot /home/vagrant/run_jupyter.sh") | crontab -u vagrant -
fi

#done now reboot
reboot