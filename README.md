# chipwhisperer-vagrant
chipwhisperer-vagrant is a repo containing the needed vagrant file and scripts for building the ChipWhisperer Jupyter vm. It should take care of everything needed, including installing packages, installing python modules using pip, enabling needed jupyter extensions, and creaing an @reboot cron job to run jupyter.

The created VM is called ChipWhisperer Jupyter and it should be stored in the regular spot where VirtualBox puts its VMs. 

See setup.sh for the shell commands used to setup the VM

## Building the VM
To build the VM, navigate to this folder and run `vagrant up`. Users will now have to log into the VM, update the password, add a password to Jupyter (`$ jupyter notebook password`) and reboot.

## Connecting to Jupyter
Jupyter can now be connected to via `localhost:8888`.

**JUYPTER CAN ONLY BE CONNECTED TO ON FIREFOX/CHROME, EDGE/SAFARI DON'T WORK, OTHER BROWSERS UNTESTED**
## Potential Issues and Troubleshooting
Most issues occur when moving the VM to a new machine.

* VM Freezes on Boot
    * This is typically caused by Serial Port 1 being disabled. It can be fixed by enabling it and setting Port Mode to Disconnected
* Permission Error when running VM
    * Usually caused by trying to run the VM on a Unix-like host off an NTFS filesystem (say a USB flash drive). Can be fixed by copying the VM files onto the host's normal file system
