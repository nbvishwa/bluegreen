# bluegreen
blue green deployment using terraform


how to run this app?

terraform apply -var 'traffic_distribution=blue-90' -var 'enable_green_env=true' -auto-approve

The above command runs 90% traffic to blue & 10% to green.



How to check the traffic?

for i in `seq 1 1000`; do curl $(terraform output -raw lb_dns_name); done
