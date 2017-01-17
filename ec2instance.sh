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
echo -e "The security group has been created. \n `cat $g_name.secgrp` "
echo
echo
# Command to add open  ports in Above created security group

#enable ssh
aws ec2 authorize-security-group-ingress --group-name $g_name --protocol tcp --port 22 --cidr 0.0.0.0/0
#enable HTTP

aws ec2 authorize-security-group-ingress --group-name $g_name --protocol tcp --port 80 --cidr 0.0.0.0/0
#enable HTTPS
aws ec2 authorize-security-group-ingress --group-name $g_name --protocol tcp --port 443 --cidr 0.0.0.0/0

