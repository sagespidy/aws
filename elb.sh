aws elb create-load-balancer --load-balancer-name staging-elb --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80"  --security-groups $g_id_staging_elb --tags '{"Key": "test","Value": "test"}' --availability-zones  us-east-1a us-east-1b us-east-1c us-east-1d us-east-1e 

#aws elb register-instances-with-load-balancer --load-balancer-name my-load-balancer --instances i-d6f6fae3
