# ------------------------------------------------------------------------
# Copyright 2019 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

#!/bin/bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
product=$1
version=$2
deploymentPattern=$3
dbType=$4

################################################ WSO2 Product ####################################################
sudo rm  /var/lib/dpkg/lock-frontend
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
echo "Installing unzip"
sudo apt install unzip  &> apt.log
echo "Installing mysql-client"
sudo apt-get install -q -y mysql-client &>> apt.log
echo "Installing pip"
sudo DEBIAN_FRONTEND=noninteractive apt install -q -y python-pip &>> apt.log
echo "Installing maven"
sudo apt install -q -y maven &>> apt.log

sudo sed -i "s|PRODUCT|${product}|g" /etc/filebeat/filebeat.yml
sudo sed -i "s|VERSION|${version}|g" /etc/filebeat/filebeat.yml

sudo su - wso2user
echo "Copying $product-$version ..."
cp /tmp/$product-$version.zip /home/wso2/
cp /tmp/OpenJDK8U-jdk_8u222_linux_x64.tar.gz /opt

mkdir /home/wso2/endpointCars
cp /tmp/*_staging*.car /home/wso2/endpointCars
cp /tmp/*_production*.car /home/wso2/endpointCars

mkdir /usr/local/bin/bashScripts
cp -r /tmp/util/bashScripts/$product/$version/$deploymentPattern/$dbType/ /usr/local/bin/bashScripts/

mkdir /home/wso2/dbScripts
cp -r /tmp/util/dbScripts/$product/$version/$deploymentPattern/$dbType/ /home/wso2/dbScripts/
chmod -R +x /home/wso2/dbScripts
chmod -R +x /usr/local/bin/bashScripts

echo "Copying sysctl.conf ..."
sudo cp /tmp/conf/sysctl.conf /etc/sysctl.conf -v
echo "Copying limits.conf ..."
sudo cp /tmp/conf/limits.conf /etc/security/limits.conf  -v

echo 'export HISTTIMEFORMAT="%F %T "' >> /etc/profile.d/history.sh
cat /dev/null > ~/.bash_history && history -c
