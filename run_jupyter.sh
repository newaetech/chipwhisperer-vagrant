#!/bin/bash
source /home/vagrant/pyenv.tail
pyenv activate cw
cd /home/vagrant/work/projects/chipwhisperer
echo "running jupyter" > ../cronjupyter.log
export BOKEH_RESOURCES=inline
jupyter notebook --no-browser 2>> ../jupyter.log >> ../jupyter.log
echo "Notebook didn't run or stopped!" >> ../cronjupyter.log
