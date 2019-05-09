#!/usr/bin/env bash

# normal apt installs
apt-get update
apt-get upgrade

apt-get install -y python3
apt-get install -y python3-pip
apt-get install -y python3-tk #for matplotlib/lascar
apt-get install -y git
apt-get install -y gcc-avr
apt-get install -y avr-libc
apt-get install -y gcc-arm-none-eabi
apt-get install -y make
apt-get install -y dos2unix

apt-get update
apt-get upgrade

# https://github.com/bbcmicrobit/micropython/issues/514
# Ubuntu 18.04 arm-none-eabi-gcc has broken libc/nano specs (always tries to use full arm w/invalid instructions)
rm *.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-dev_3.0.0.20180802-2_all.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb
dpkg -i libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb libnewlib-dev_3.0.0.20180802-2_all.deb 

# pip installs
python3 -m pip install --upgrade pip

# get lascar and install
git clone https://github.com/Ledger-Donjon/lascar
chown -R vagrant:vagrant lascar
cd lascar
pip3 install --upgrade colorama
python3 setup.py install
cd ..

# get chipwhisperer and install
git clone https://github.com/newaetech/chipwhisperer
chown -R vagrant:vagrant chipwhisperer
cd chipwhisperer/software
git checkout cw5dev
git pull
sudo -Hu vagrant git config --global user.name "Vagrant"
sudo -Hu vagrant git config --global user.email "Vagrant@none.com"
pip3 install -r requirements.txt
python3 setup.py develop

# USB permissions
cd ../hardware
cp 99-newae.rules /etc/udev/rules.d/
usermod -a -G plugdev vagrant
udevadm control --reload-rules

# copy cron script from vagrant folder
cp /vagrant/run_jupyter.sh /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/run_jupyter.sh
chmod +x /home/vagrant/run_jupyter.sh

# jupyter stuff
jupyter contrib nbextension install --system

# copy jupyter config
mkdir -p /home/vagrant/.jupyter
cp /vagrant/jupyter_notebook_config.py /home/vagrant/.jupyter/
#token=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
#echo $token > /home/vagrant/token
#sed -i s/NEWAE/$token/ /home/vagrant/.jupyter/jupyter_notebook_config.py

# make sure jupyter is under the vagrant user
# maybe just make /home/vagrant all vagrant?
chown vagrant:vagrant -R /home/vagrant/

# Enable jupyter extensions
sudo -Hu vagrant jupyter nbextension enable toc2/main
sudo -Hu vagrant jupyter nbextension enable collapsible_headings/main

jupyter nbextensions_configurator enable --system

dos2unix /home/vagrant/run_jupyter.sh /home/vagrant/.jupyter/jupyter_notebook_config.py
# check if cron job already inserted, and if not insert it
if !(crontab -u vagrant -l | grep "run_jupyter\.sh"); then
    (crontab -u vagrant -l 2>/dev/null; echo "@reboot /home/vagrant/run_jupyter.sh") | crontab -u vagrant -
fi

apt-get update
apt-get upgrade
#done now reboot
reboot
