# setup:
# 	$(eval ADMIN_IP=$(shell curl http://ipv4.icanhazip.com |  xargs))

apply: 
	terraform apply -var="admin_ip=103.150.68.166" -var-file="env.tfvars"
