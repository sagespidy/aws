#!/bin/bash

echo
echo
echo 				"Welcome! This script will create a security group"
echo
echo "Please enter the name of group to created in aws: "
# Ask the user for aws security group name to be
read g_name

# Command to create a aws  security group and output the group details into a file


aws ec2 create-security-group --group-name $g_name --description "security group for $g_name development environment in EC2" > $g_name.secgrp


echo
echo
echo -e "The security group has been created. \n "
echo
echo
##
## store group id in a var
g_id=`cat $g_name.secgrp | grep sg | cut -d '"' -f4`
echo "group id is $g_id"

##
##
# Command to add open  ports in Above created security group

#enable ssh
aws ec2 authorize-security-group-ingress --group-name $g_name --protocol tcp --port 22 --cidr 0.0.0.0/0
#enable HTTP

aws ec2 authorize-security-group-ingress --group-name $g_name --protocol tcp --port 80 --cidr 0.0.0.0/0
#enable HTTPS
aws ec2 authorize-security-group-ingress --group-name $g_name --protocol tcp --port 443 --cidr 0.0.0.0/0
echo -e "By Default, the following ports are enabled: \n 22		SSH\n 80		HTTP\n 443 		HTTPS"

###
### Create pem file
####


echo " Welcome! This script will create a key pair "
echo -e "\n\n\n"

echo "Please enter the name of key-pair to be created:"
read kp
aws ec2 create-key-pair --key-name $kp --query 'KeyMaterial' --output text > $kp.pem
echo -e "\n\n\n"
echo "Key-pair Created SuccessFully.\n  "
chmod 400 $kp.pem
#
#
# finally Launch instance with ubuntu

#

echo -e " \n\n\n\ "
echo "Please enter the type of instance (Example format : t2.small)" :
read i_type

# Launch ec2 with exiting sec grp and key pair
aws ec2 run-instances --image-id ami-e13739f6 --security-group-ids $g_id --count 1 --instance-type $i_type --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings file://~/aws/size.json

echo "instance created."
