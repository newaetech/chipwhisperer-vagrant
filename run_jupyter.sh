#!/bin/sh
cd /home/vagrant/chipwhisperer
echo "running jupyter" > ../cronjupyter.log
/usr/local/bin/jupyter notebook --no-browser 2>> ../jupyter.log >> ../jupyter.log
echo "Notebook didn't run or stopped!" >> ../cronjupyter.log
