This terraform use a local terraform backend server for the states.
It uses OpenBao to manage and inject secrets in the vm.
We use debian 13 cloud images for initialize the VM

move .env.example to .env

change the variables in terraform.tfvars

and run

terraform init -backend-config="conn_str=$TF_BACKEND_CONN_STR"

then
terraform apply

