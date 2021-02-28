az account set -s "Visual Studio Premium mit MSDN"
$account = az account show | convertfrom-json
tf init -backend-config appi-tf/azure.backend appi-tf
tf plan -var subscription_id=$($account.id) -var tenant_id=$($account.tenant_id) -out tf-plan.tar.gz -var-file appi-tf/terraform.tfvars appi-tf
tf apply tf-plan.tar.gz