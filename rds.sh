
#
echo "enter project name"
read pname
r1=rds-dev
g_id_dev_rds=`aws ec2 create-security-group --group-name $r1 --description "security group for $r1 development environment in EC2" | grep sg | cut -d '"' -f4`
echo "rds instance type"
read db_class
aws rds create-db-instance --db-instance-identifier $pname-dev --allocated-storage 10 --db-instance-class $db_class --engine mysql --master-username $pname --master-user-password $pname-456$%^ --no-multi-az --auto-minor-version-upgrade --vpc-security-group $g_id_dev_rds --storage-type gp2 --tags '{"Key": "Name","Value": "$r1"}'
