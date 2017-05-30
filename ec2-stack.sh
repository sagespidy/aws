set -e
clear
aws configure
# define groups
g1=dev
g2=qa
g3=staging
r1=rds-dev
r2=rds-qa
r3=rds-staging
# create-security-groups
#dev
g_id_dev=`aws ec2 create-security-group --group-name $g1 --description "security group for $g1 development environment in EC2" | grep sg | cut -d '"' -f4`
#Qa
g_id_qa=`aws ec2 create-security-group --group-name $g2 --description "security group for $g2 development environment in EC2" | grep sg | cut -d '"' -f4`
#staging
g_id_staging=`aws ec2 create-security-group --group-name $g3 --description "security group for $g3 development environment in EC2" | grep sg | cut -d '"' -f4`
#DEV_RDS
g_id_dev_rds=`aws ec2 create-security-group --group-name $r1 --description "security group for $r1 development environment in EC2" | grep sg | cut -d '"' -f4`
#qa_RDS
g_id_qa_rds=`aws ec2 create-security-group --group-name $r2 --description "security group for $r2 development environment in EC2" | grep sg | cut -d '"' -f4`
#staging_rds
g_id_staging_rds=`aws ec2 create-security-group --group-name $r3 --description "security group for $r3 development environment in EC2" | grep sg | cut -d '"' -f4`

# Authorise DEV security group
aws ec2 authorize-security-group-ingress --group-name $g1 --protocol tcp --port 22 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $g1 --protocol tcp --port 22 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $g1 --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $g1 --protocol tcp --port 443 --cidr 0.0.0.0/0

#Authorise QA security group
aws ec2 authorize-security-group-ingress --group-name $g2 --protocol tcp --port 22 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $g2 --protocol tcp --port 22 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $g2 --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $g2 --protocol tcp --port 443 --cidr 0.0.0.0/0

#Authorise staging security group
aws ec2 authorize-security-group-ingress --group-name $g3 --protocol tcp --port 22 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $g3 --protocol tcp --port 22 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $g3 --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $g3 --protocol tcp --port 443 --cidr 0.0.0.0/0

# Authorise DEV_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 22 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 22 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 80 --source-group $g_id_dev

# Authorise qa_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 22 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 22 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 80 --source-group $g_id_qa

# Authorise DEV_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 22 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 22 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 80 --source-group $g_id_staging

# create-key-pair
clear

echo "Do You want create new pem file Yes/no ?"
read x
function f1()
{
  read y
  if [[ $y =~ ^[Yy][eE][sS]$ ]]
  then
    echo "Please enter the name of key-pair to be created:"
    read kp
    aws ec2 create-key-pair --key-name $kp --query 'KeyMaterial' --output text > $kp.pem
    echo -e "\n\n\n"
    echo "Key-pair Created SuccessFully.\n  "
    chmod 400 $kp.pem
    mv $kp.pem ~/
  elif [[ $y =~ ^[nN][oO] ]]
  then
    echo "enter name of pem file | Just name - don't include .pem extension"
    read kp
    echo $kp.pem

  else
    echo 'Please type either "yes" or "no"'
    f1
  fi
}

echo    # (optional) move to a new line
if [[ $x =~ ^[Yy][eE][sS]$ ]]
then
  echo "Please enter the name of pem file to be created:"
  read kp
  aws ec2 create-key-pair --key-name $kp --query 'KeyMaterial' --output text > $kp.pem
  echo  "\n\n\n"
  echo "Pem file Created SuccessFully.\n It can be found in $HOME  "
  chmod 400 $kp.pem
  mv $kp.pem ~/
elif [[ $x =~ ^[nN][oO] ]]
then
  echo "enter name of pem file | Just name - don't include .pem extension"
  read kp
  echo $kp.pem

else
  echo 'Please type either "yes" or "no"'
  f1
fi
clear
echo "Please enter the type of instance (Example format : t2.small)" :
read i_type
echo "Enter the ami of Operating system you want to lauch"
read ami
# Create instance
dev=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_dev --count 1 --instance-type $i_type --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}'  --user-data file:///Users/spidy/shell-scripts/non-interactive-apache2.sh | cut -d '"' -f2`

#Create Name tag
aws ec2 create-tags --resources $dev --tags Key=Name,Value=ec2-dev
echo "dev stance created   $dev"


qa=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_qa --count 1 --instance-type $i_type --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}' --user-data file:///Users/spidy/shell-scripts/non-interactive-apache2.sh | cut -d '"' -f2`

 #Create Name tag
 aws ec2 create-tags --resources $qa --tags Key=Name,Value=ec2-qa
 echo "QA stance created   $qa"

staging1=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_staging --count 1 --instance-type $i_type --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}' --user-data file:///Users/spidy/shell-scripts/non-interactive-apache2.sh | cut -d '"' -f2`

#Create Name tag
aws ec2 create-tags --resources $staging1 --tags Key=Name,Value=ec2-Staging1
echo "staging1 instance created   $staging1"

staging2=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_staging --count 1 --instance-type $i_type --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}'  --user-data file:///Users/spidy/shell-scripts/non-interactive-apache2.sh | cut -d '"' -f2`

#Create Name tag
aws ec2 create-tags --resources $staging2 --tags Key=Name,Value=ec2-staging2
echo "staging2 stance created   $staging2"

#Allocate Elastic-IP address
eip_dev=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`
eip_qa=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`
eip_staging1=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`
eip_staging2=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`

echo "4 Elastic ip allocated. :)"

echo "Waiting 33 seconds ..."

for ((i=30;i>=1;i--))
do
	echo -e "							$i \n"
	sleep 1
done

aws ec2 associate-address --instance-id $dev --public-ip $eip_dev
aws ec2 associate-address --instance-id $qa --public-ip $eip_qa
aws ec2 associate-address --instance-id $staging1 --public-ip $eip_staging1
aws ec2 associate-address --instance-id $staging2 --public-ip $eip_staging2


Echo "Elastic-IP's Assigned to their Respective servers"

# onto RDS Creation
