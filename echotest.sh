pname=test
eip_dev=1
eip_qa=2
eip_staging1=3
eip_staging2=4
rds_dev_endp=rds1
rds_qa_endp=rds2
rds_staging_endp=rds3

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

#for ((i=333;i>=1;i--))
#do
	##echo "							$i \n"
	#sleep 1
#done

#rds_dev_endp=`aws rds describe-db-instances |grep -i address | grep dev| cut -d '"' -f4`
#rds_qa_endp=`aws rds describe-db-instances |grep -i address | grep qa| cut -d '"' -f4`
#rds_staging_endp=`aws rds describe-db-instances |grep -i address | grep staging| cut -d '"' -f4`



echo '"rds-dev Endpoint"' ':''"' " $rds_dev_endp " '"' >> ~/$pname-creds.json
echo '"rds-qa Endpoint"' ':''"' "$rds_dev_endp"'"' >> ~/$pname-creds.json
echo '"rds-staging Endpoint"' ':''"' "$rds_dev_endp"'"' >> ~/$pname-creds.json
echo '}' >> ~/$pname-creds.json
