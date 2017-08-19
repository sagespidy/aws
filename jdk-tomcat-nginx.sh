#!/bin/bash
if [ $UID -ne 0 ] ; then
echo " 403 Error !!.  Please run me as root"
exit
fi


echo "####################################################################################################"
echo "#                                                                                                  #"
echo "# 		Welcome!! This script will install Java environment                                          #"
echo "#                                            							                                         #"
echo "####################################################################################################"

# update system repos
apt-get update -y

#Install python software properties

apt-get install python-software-properties -y
#
apt-get install zip unzip htop ncdu -y

# Add PPA java repository
add-apt-repository ppa:webupd8team/java -y
apt-get update

#Accept java license
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

# install Java JRE and JDK from the PPA repository
apt-get install oracle-java8-installer -y

echo 'JAVA_HOME="/usr/lib/jvm/java-8-oracle/jre"' >> /etc/environment
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle/jre' >> /etc/bash.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/bash.bashrc

# Install tomcat
cd /opt
wget http://mirror.fibergrid.in/apache/tomcat/tomcat-8/v8.5.15/bin/apache-tomcat-8.5.15.tar.gz
tar -xvzf apache-tomcat-8.5.15.tar.gz
mv apache-tomcat-8.5.15 tomcat

echo 'export CATALINA_OPTS="$CATALINA_OPTS -Xms512m"' > /opt/tomcat/bin/setenv.sh
echo 'export CATALINA_OPTS="$CATALINA_OPTS -Xmx856m"' >> /opt/tomcat/bin/setenv.sh
echo 'export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxPermSize=512m"' >> /opt/tomcat/bin/setenv.sh


apt-get install -y mysql-client

echo "Creating a New User...."

echo -e " \n\n\n "

echo " Please enter the name of user: "
# Take input from user

usr_name=lvme


# Make a new user and  set his Password
useradd $usr_name -d /opt/tomcat -s /bin/bash

chown -R $usr_name:$usr_name /opt

echo "$usr_name:$usr_name-123#@"|chpasswd


# Enable SSH login

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config


service ssh restart

echo -e "\n\n\n\n\n\n"
echo -e "\n\n\n\n\n\n"
echo "SSH via Password Authentication enabled"
apt-get install -y ntp
DEBIAN_FRONTEND=noninteractive  apt-get install -y postfix


apt-get install -y nginx
cd ~
wget https://raw.githubusercontent.com/sagespidy/tomcat/master/default
mv default /etc/nginx/sites-enabled/default
