clear
echo "please Enter project name"
read pname
clear
aws configure
# define groups
r1=$pname-rds-dev
r2=$pname-rds-qa
r3=-$pname-rds-staging

#DEV_RDS
g_id_dev_rds=`aws ec2 create-security-group --group-name $r1 --description "security group for $r1 development environment in EC2" | grep sg | cut -d '"' -f4`
#qa_RDS
g_id_qa_rds=`aws ec2 create-security-group --group-name $r2 --description "security group for $r2 development environment in EC2" | grep sg | cut -d '"' -f4`
#staging_rds
g_id_staging_rds=`aws ec2 create-security-group --group-name $r3 --description "security group for $r3 development environment in EC2" | grep sg | cut -d '"' -f4`

echo "security groups created \n Authorisation in progress ..."

# Authorise DEV_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 3306 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 3306 --cidr 182.74.105.34/32
#aws ec2 authorize-security-group-ingress --group-name $r1 --protocol tcp --port 3306 --source-group $g_id_dev

# Authorise qa_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 3306 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 3306 --cidr 182.74.105.34/32
#aws ec2 authorize-security-group-ingress --group-name $r2 --protocol tcp --port 3306 --source-group $g_id_qa

# Authorise DEV_RDS security group
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 3306 --cidr 111.93.125.26/32
aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 3306 --cidr 182.74.105.34/32
#aws ec2 authorize-security-group-ingress --group-name $r3 --protocol tcp --port 3306 --source-group $g_id_staging

echo "RDS Authorisation done ...."
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

echo '{' >> ~/$pname-creds.json
echo '{' >> ~/$pname-creds.json
echo '"RDS UserName"' ':' '"' "$pname" '"' >> ~/$pname-creds.json
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
