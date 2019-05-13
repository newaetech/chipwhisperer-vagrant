SHELL := /bin/bash

all:
	apt-get update -y
	apt-get upgrade -y
	apt-get install -y curl git mc emacs net-tools
	apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev
	apt-get install -y libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev
	apt-get install -y xz-utils tk-dev libffi-dev liblzma-dev python-openssl
	apt-get install -y gcc-avr
	apt-get install -y avr-libc
	apt-get install -y gcc-arm-none-eabi
	apt-get install -y make
	apt-get install -y dos2unix
	# https://github.com/bbcmicrobit/micropython/issues/514
	# Ubuntu 18.04 arm-none-eabi-gcc has broken libc/nano specs (always tries to use full arm w/invalid instructions)
	-rm *.deb
	wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-dev_3.0.0.20180802-2_all.deb
	wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb
	#dpkg -i libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb libnewlib-dev_3.0.0.20180802-2_all.deb 
	dos2unix /home/vagrant/pyenv.tail

	su vagrant - -c "make stage2"

	find /home/vagrant/work/projects -exec dos2unix {} \;

	# USB permissions
	cp /home/vagrant/work/projects/chipwhisperer/hardware/99-newae.rules /etc/udev/rules.d/
	usermod -a -G plugdev vagrant
	#udevadm control --reload-rules

	# copy cron script from vagrant folder
	cp /vagrant/run_jupyter.sh /home/vagrant/
	dos2unix /home/vagrant/run_jupyter.sh
	chown -R vagrant:vagrant /home/vagrant/run_jupyter.sh
	chmod +x /home/vagrant/run_jupyter.sh

	# jupyter stuff
	su vagrant -  -c "source /home/vagrant/pyenv.tail; pyenv activate cw; jupyter contrib nbextension install --user"

	# copy jupyter config
	mkdir -p /home/vagrant/.jupyter
	cp /vagrant/jupyter_notebook_config.py /home/vagrant/.jupyter/

	# make sure jupyter is under the vagrant user
	# maybe just make /home/vagrant all vagrant?
	chown vagrant:vagrant -R /home/vagrant/

	# Enable jupyter extensions
	su vagrant - -c "source /home/vagrant/pyenv.tail; pyenv activate cw; jupyter nbextension enable toc2/main"
	su vagrant - -c "source /home/vagrant/pyenv.tail; pyenv activate cw;  jupyter nbextension enable collapsible_headings/main"

	su vagrant -  -c "source /home/vagrant/pyenv.tail; pyenv activate cw; jupyter nbextensions_configurator enable --user"

	# check if cron job already inserted, and if not insert it
	#(if !(crontab -u vagrant -l | grep "run_jupyter\.sh"); then \
	(crontab -u vagrant -l 2>/dev/null; echo "@reboot /home/vagrant/run_jupyter.sh") | crontab -u vagrant - 
	#fi \
	#)


	#setup pyenv for user
	su vagrant - -c "source /home/vagrant/pyenv.tail; pyenv global 3.6.7/envs/cw"
	#pyenv global 3.6.7/envs/cw

	#set user password to be expired
	chage -d 0 vagrant
	#done now reboot
	reboot



stage2:
	curl https://pyenv.run | bash
	cat pyenv.tail >> ~/.bashrc
	echo "export BOKEH_RESOURCES=inline" >> ~/.bashrc
	(\
	source /home/vagrant/pyenv.tail; \
	make stage3; \
	)

stage3:
	git config --global user.name "Vagrant"
	git config --global user.email "Vagrant@none.com"

	mkdir -p /home/vagrant/work/projects
	cd /home/vagrant/work/projects && git clone https://github.com/newaetech/chipwhisperer
	cd /home/vagrant/work/projects/chipwhisperer && git checkout cw5dev
	cd /home/vagrant/work/projects/chipwhisperer && git pull
	# get lascar
	cd /home/vagrant/work/projects && git clone https://github.com/Ledger-Donjon/lascar

	pyenv install 3.6.7
	pyenv virtualenv 3.6.7 cw
	make stage4

stage4:
	( \
	set -x; \
	set -e; \
	source /home/vagrant/pyenv.tail; \
	pyenv activate cw; \
	pip install --upgrade pip; \
	pip install cufflinks plotly phoenixAES terminaltables; \
	pip install numpy; \
	cd /home/vagrant/work/projects/chipwhisperer/software; \
	pip install -r requirements.txt; \
	python3 setup.py develop; \
	cd /home/vagrant/work/projects/lascar; \
	pip install --upgrade colorama; \
	python setup.py install; \
	)

