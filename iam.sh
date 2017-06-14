pname=test
aws iam create-user --user-name $pname
aws iam create-login-profile --user-name $pname --password $pname-456$%^ > ~/$pname-iam_creds.json
aws iam create-access-key --user-name $pname >> ~/$pname-iam_creds.json
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --user-name $pname
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --user-name $pname
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess --user-name $pname
