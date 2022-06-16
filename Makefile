include .env
export 

TFLAGS=-var-file="prod.tfvars"

apply:
	terraform apply ${TFLAGS}

plan:
	terraform plan ${TFLAGS}

destroy:
	terraform destroy ${TFLAGS}

