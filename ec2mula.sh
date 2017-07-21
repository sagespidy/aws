
clear
echo "please Enter project name"
read pname
clear
aws configure
#Get startup script
cd ~
rm -rf ~/non-interactive-apache2.sh
wget https://raw.githubusercontent.com/sagespidy/Apache2/master/non-interactive-apache2.sh
sed -i "s/usr_name=lvme/usr_name=$pname/" ~/non-interactive-apache2.sh
#rm -rf ~/jdk-tomcat-nginx.sh
#wget https://raw.githubusercontent.com/sagespidy/tomcat/master/jdk-tomcat-nginx.sh
#sed -i "s/usr_name=lvme/usr_name=$pname/" ~/jdk-tomcat-nginx.sh

# define groups
g1=dev
g2=qa
g3=staging
r1=rds-dev
r2=rds-qa
r3=rds-staging
s=staging-elb
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
g_id_staging_elb=`aws ec2 create-security-group --group-name $s --description "security group for $s development environment in EC2" | grep sg | cut -d '"' -f4`
echo "security groups created \n Authorisation in progress ..."
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

echo "Ec2 Authorisation completed"

# Authorise DEV_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 3306 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 3306 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 3306 --source-group $g_id_dev

# Authorise qa_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 3306 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 3306 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 3306 --source-group $g_id_qa

# Authorise DEV_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 3306 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 3306 --cidr 182.74.105.34/32
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 3306 --source-group $g_id_staging

# Authorise ELb sec group
aws ec2 authorize-security-group-ingress --group-name $s --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $s --protocol tcp --port 443 --cidr 0.0.0.0/0

echo "RDS Authorisation done ...."

# create-key-pair

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
#echo "Please enter the type of instance (Example format : t2.small)" :
#read i_type
echo "Enter the ami of Operating system you want to Launch"
read ami
# Create instance
dev=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_dev --count 1 --instance-type t2.micro --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}'  --user-data file://~/non-interactive-apache2.sh | cut -d '"' -f2`

#Create Name tag
aws ec2 create-tags --resources $dev --tags Key=Name,Value=ec2-dev
echo "dev stance created   $dev"


staging=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_staging --count 1 --instance-type t2.micro --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}' --user-data file://~/non-interactive-apache2.sh | cut -d '"' -f2`

 #Create Name tag
 aws ec2 create-tags --resources $staging --tags Key=Name,Value=ec2-Staging1
 echo "staging stance created   $staging"

qa1=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_qa --count 1 --instance-type t2.micro --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}' --user-data file://~/non-interactive-apache2.sh | cut -d '"' -f2`

#Create Name tag
aws ec2 create-tags --resources $qa1 --tags Key=Name,Value=ec2-qa1
echo "qa1 instance created   $qa1"

qa2=`aws ec2 run-instances --image-id $ami --security-group-ids $g_id_qa --count 1 --instance-type t2.micro --key-name $kp --query 'Instances[0].InstanceId' --block-device-mappings  '{"DeviceName": "/dev/sda1","Ebs": {"VolumeSize": 30}}'  --user-data file://~/non-interactive-apache2.sh | cut -d '"' -f2`

#Create Name tag
aws ec2 create-tags --resources $qa2 --tags Key=Name,Value=ec2-qa2
echo "qa2 stance created   $qa2"

#Allocate Elastic-IP address
eip_dev=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`
eip_staging=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`
eip_qa1=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`
eip_qa2=`aws ec2 allocate-address |grep Public | cut -d '"' -f4`

echo "4 Elastic ip allocated. :)"

echo "Waiting 33 seconds ..."

for ((i=33;i>=1;i--))
do
	echo -e "							$i \n"
	sleep 1
done

aws ec2 associate-address --instance-id $dev --public-ip $eip_dev
aws ec2 associate-address --instance-id $staging --public-ip $eip_staging
aws ec2 associate-address --instance-id $qa1 --public-ip $eip_qa1
aws ec2 associate-address --instance-id $qa2 --public-ip $eip_qa2


Echo "Elastic-IP's Assigned to their Respective servers"

# onto RDS Creation
sleep 2
clear

echo "Creating Dev RDS"

aws rds create-db-instance --db-instance-identifier $pname-Dev --allocated-storage 10 --db-instance-class db.t2.micro --engine mysql --master-username $pname --master-user-password $pname-456$%^ --no-multi-az --auto-minor-version-upgrade --vpc-security-group $g_id_dev_rds --storage-type gp2 --tags '{"Key": "Name","Value": "rds-dev"}'
sleep 2
clear
echo " Creating QA RDS"

aws rds create-db-instance --db-instance-identifier $pname-QA --allocated-storage 10 --db-instance-class db.t2.micro --engine mysql --master-username $pname --master-user-password $pname-456$%^ --no-multi-az --auto-minor-version-upgrade --vpc-security-group $g_id_qa_rds --storage-type gp2 --tags '{"Key":
"Name","Value": "rds-qa"}'
sleep 2
clear

echo " Creating staging RDS"

aws rds create-db-instance --db-instance-identifier $pname-Staging --allocated-storage 10 --db-instance-class db.t2.micro --engine mysql --master-username $pname --master-user-password $pname-456$%^ --no-multi-az --auto-minor-version-upgrade --vpc-security-group $g_id_staging_rds --storage-type gp2 --tags '{"Key": "Name","Value": "rds-staging"}'
sleep 2
clear
echo "Done with RDS Creation"

# Bucket Creation
echo "Creating buckets .."
aws s3 mb s3://$pname-dev-bucket
aws s3 mb s3://$pname-qa-bucket
aws s3 mb s3://$pname-staging-bucket
aws s3 mb s3://$pname-prod-bucket

echo "following buckets have been created : \n\n\n Dev \n Qa \n staging \n Production"

# Create IAM Users
echo "Creating iam user"
aws iam create-user --user-name $pname
aws iam create-login-profile --user-name $pname --password $pname-456$%^
aws iam create-access-key --user-name $pname > ~/$pname-creds.json
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --user-name $pname
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --user-name $pname
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess --user-name $pname

echo '{' >> ~/$pname-creds.json

echo ' "IAM UserName" ' ':' '"'"$pname" '"' >> ~/$pname-creds.json
echo '"IAM User Password"' ':' '"' "$pname-456$%^" '"' "\n\n" >> ~/$pname-creds.json
echo '}' >> ~/$pname-creds.json

echo '{' >> ~/$pname-creds.json

echo '"ssh UserName" ' ':' '"' "$pname" '"' >> ~/$pname-creds.json
echo '"ssh Password"' ':' '"' "$pname-123#@" '"' >> ~/$pname-creds.json


echo '"Dev server ip"' ':' '"' "$eip_dev" '"' "\n" >> ~/$pname-creds.json
echo '"QA server ip"' ':' '"' "$eip_qa" '"' "\n" >> ~/$pname-creds.json
echo '"staging1 server ip"' ':' '"' "$eip_staging1" '"' "\n" >> ~/$pname-creds.json
echo '"staging2 server ip"' ':' '"' "$eip_staging2" '"' "\n" >> ~/$pname-creds.json

echo '}' >> ~/$pname-creds.json

echo
echo

echo '{' >> ~/$pname-creds.json
echo '"RDS UserName' ':' '"' "$pname" '"' >> ~/$pname-creds.json
echo '"RDS Password" :' '"' "$pname-456$%^" '"' >> ~/$pname-creds.json

echo "Waiting 333 seconds ..."

for ((i=333;i>=1;i--))
do
	echo "							$i \n"
	sleep 1
done

rds_dev_endp=`aws rds describe-db-instances |grep -i address | grep dev| cut -d '"' -f4`
rds_qa_endp=`aws rds describe-db-instances |grep -i address | grep qa| cut -d '"' -f4`
rds_staging_endp=`aws rds describe-db-instances |grep -i address | grep staging| cut -d '"' -f4`



echo '"rds-dev Endpoint"' ':''"' "$rds_dev_endp"'"' >> ~/$pname-creds.json
echo '"rds-qa Endpoint"' ':''"' "$rds_qa_endp"'"' >> ~/$pname-creds.json
echo '"rds-staging Endpoint"' ':''"' "$rds_staging_endp"'"' >> ~/$pname-creds.json
echo '}' >> ~/$pname-creds.json
