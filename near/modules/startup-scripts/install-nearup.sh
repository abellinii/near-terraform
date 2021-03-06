#! /bin/bash

#Set login
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN

#change $HOME to install packages as ubuntu
export HOME=/home/ubuntu
NEAR_DIRECTORY=.near/${network}
network=${network}
initialstartup=${initialstartup}
cd $HOME


#Install node v 12 and npm
su - ubuntu -c yes | curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
su - ubuntu -c yes | sudo apt-get install nodejs
su - ubuntu -c yes | sudo apt install npm 



#Install near-shell
echo "export NODE_ENV=$network" >> ~/.bashrc 
su - ubuntu -c echo "export NODE_ENV=$network" >> $HOME/.profile 
su - ubuntu -c sudo yes | npm install -g near-shell


pwd
#Install nearup and make globally executable
apt-get update
apt install  --assume-yes python3 python3-pip
su - ubuntu -c 'pip3 install --user nearup'

#Load on interactive bash 
echo 'source $HOME/.nearup/env' >> ~/.bashrc 

#Ensure nearup is available
source ~/.profile

#Start nearup, stop, replace keys and start again
cd $HOME
nearup run ${network} --account-id ${stakingpool_id} 
if [ !$intialstartup ]; then
    nearup stop
    pwd
    cd $NEAR_DIRECTORY
    rm -rf data
    echo -n '${validator_key}' > validator_key.json
    echo -n '${node_key}' > node_key.json
    nearup run ${network} --account-id ${stakingpool_id}
fi


#Give ubuntu access to .near
apt-get install -y acl
setfacl -R -m u:ubuntu:rwx /home/ubuntu/.near
setfacl -R -m u:ubuntu:rwx /home/ubuntu/.nearup





