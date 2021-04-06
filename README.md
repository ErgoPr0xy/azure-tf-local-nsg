# azure-tf-local-nsg 
Terraform - Create Azure cluster with native NSG! Add more rules if needed

# HOW TO: 

Open az cloudshell \
Create new dir \
cd to new dir \
copy files to dir \
terraform init \
if successful run: terraform plan -out "mycluster" \
if successful run: terraform apply "mycluster" \
wait a few minutes - voila - your new auto-scaling cluster is ready to go with rules applied to the native NSG

This will create a scalable cluster with a native nsg + rules

Tested in Azure - working on Terraform AzureRM Provider 2.49.0

All the names are examples. Change to what you need 

# ISSUES:
 
You may get a "ServicePrincipal Not Found" error, if so just run terraform apply again
If the SP issue pops up on builds then check out the local-exec discussion here: https://github.com/hashicorp/terraform-provider-azuread/issues/4

# TO DO:

I have not tested outputs.tf yet. If it breaks something just remove it. 

