# tf_az_k8s_create_nsg
Terraform - Create Azure cluster with NSG and NSG rule

HOW TO: 

Open az cloudshell \
Create new dir \
cd to new dir \
copy files to dir \
terraform init \
if successful terraform plan -out "mycluster" \
if successful terraform apply "mycluster" \
wait a few minutes - voila - your new auto-scaling cluster is ready to go

This will create a scalable cluster with a few extras. 

Tested in Azure - working on Terraform AzureRM Provider 2.49.0

All the names are examples. Change to what you need 

TO DO:

Have not tested the outputs.tf yet. IF it gives issues just remove it. 
Weird index error I still need to look into - this does not affect the cluster though
