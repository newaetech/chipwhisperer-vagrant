SHELL := /bin/bash

all:
	# cp /vagrant/run_jupyter.sh ~/
	apt-get update -y
	#AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	sudo apt-mark hold grub*
	# apt-get upgrade -y
	apt-get install -y curl git mc net-tools
	apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev
	apt-get install -y libreadline-dev libsqlite3-dev wget curl libncurses5-dev libncursesw5-dev
	apt-get install -y xz-utils tk-dev libffi-dev liblzma-dev python3-openssl
	apt-get install -y gcc-avr
	apt-get install -y avr-libc
	apt-get install -y gcc-arm-none-eabi
	apt-get install -y make
	apt-get install -y dos2unix
	apt-get install -y python3-gmpy2
	apt-get install -y jq
	apt-get install -y pandoc
	apt-get install -y libmpfr-dev libmpc-dev
	apt-get install -y vim
	apt-get install -y usbutils
	apt-get install -y libusb-1.0.0-dev
	dos2unix /home/vagrant/pyenv.tail
	apt-get install -y openocd
	apt-get clean

	su vagrant - -c "make stage2"

	#find /home/vagrant/work/projects -exec dos2unix {} \;

	# USB permissions
	cp /home/vagrant/work/projects/chipwhisperer/hardware/50-newae.rules /etc/udev/rules.d/
	usermod -a -G plugdev vagrant
	usermod -a -G dialout vagrant
	udevadm control --reload-rules

	# copy cron script from vagrant folder
	# cp /vagrant/run_jupyter.sh /home/vagrant/
	dos2unix /home/vagrant/run_jupyter.sh
	chown -R vagrant:vagrant /home/vagrant/run_jupyter.sh
	chmod +x /home/vagrant/run_jupyter.sh

	# jupyter stuff
	su vagrant -  -c "source /home/vagrant/pyenv.tail; pyenv activate cw; jupyter contrib nbextension install --user"

	# copy jupyter config
	mkdir -p /home/vagrant/.jupyter
	# cp /vagrant/jupyter_notebook_config.py /home/vagrant/.jupyter/

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

	printf "\
	if grep -q \"password\" \"/home/vagrant/.jupyter/jupyter_notebook_config.json\"; then \\n \
		if ps aux | grep \"jupyter-notebook\" | grep "versions"; \\n \
			then echo \"Jupyter notebook server started\"; \\n \
		else \\n \
			echo \"Jupyter notebook process not started. Check logs in work/projects\" \\n \
		fi \\n \
	else \\n \
	    echo \"Please set password for Jupyter:\"; \\n \
	    jupyter notebook password; echo \"Thank you. Reboot to start Jupyter\"; \\n \
	fi\
	" >> /home/vagrant/.bashrc


	#setup pyenv for user
	su vagrant - -c "source /home/vagrant/pyenv.tail; pyenv global 3.9.7/envs/cw"
	#pyenv global 3.6.7/envs/cw



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

	cd /home/vagrant/work/projects && git clone https://github.com/newaetech/chipwhisperer 2>&1
	cd /home/vagrant/work/projects/chipwhisperer && git pull \
	&& git submodule update --init jupyter/ && cd jupyter && git checkout master
	cd /home/vagrant/work/projects && git clone https://github.com/newaetech/phywhispererusb
	cd /home/vagrant/work/projects && git clone https://github.com/Ledger-Donjon/lascar


	&& cd /home/vagrant/work/projects/chipwhisperer \
	&& find ./hardware/victims/cw305_artixtarget -type f -exec shred -uzfn 1 "{}" \; \
	&& find ./hardware/victims/firmware/hal/silabs_sdk -type f -exec shred -uzfn 1 "{}" \; \
	&& find ./hardware/victims/firmware/esp32 -type f -exec shred -uzfn 1 "{}" \; \


	pyenv install 3.9.7
	pyenv virtualenv 3.9.7 cw
	make stage4

stage4:
	( \
	set -x; \
	set -e; \
	source /home/vagrant/pyenv.tail; \
	pyenv activate cw; \
	pip install wheel; \
	pip install --upgrade pip; \
	pip install phoenixAES terminaltables; \
	pip install numpy; \
	pip install nbparameterise; \
	pip install gmpy2; \
	pip install fastdtw; \
	cd /home/vagrant/work/projects/chipwhisperer/jupyter; \
	ls; \
	pip install -r requirements.txt; \
	pip install tqdm --upgrade; \
	cd ..; \
	python3 setup.py develop; \
	cd /home/vagrant/work/projects/lascar; \
	pip install --upgrade colorama; \
	python setup.py install; \
	cd /home/vagrant/work/projects/phywhispererusb; \
	python setup.py develop; \
	)

