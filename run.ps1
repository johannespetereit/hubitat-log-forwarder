
function Get-Secret {
  param(
    [Parameter(Position = 0)][string]$Name,
    [Parameter(Position = 0)][string]$KeyVault
  )
  $kv = az keyvault show -n $KeyVault --query "name" -otsv
  if ($null -eq $kv){
    throw "KeyVault $kv not found! are you sure you are in the correct subscription? Use `az account set -s [subscription_name|subscription_id]` to change it to the correct one."
  }
  $ret = az keyvault secret show -n $Name --vault-name $KeyVault --query "value" -otsv
  Write-Verbose "resolved secret for $Name from $keyvault"
  if ($null -eq $ret) {
    throw "Secret could not be resolved!"
  }
  return $ret
}


az account set -s "Visual Studio Premium mit MSDN"
$key =  az monitor app-insights component show  --app appi-hubitat --resource-group hubitat | convertfrom-json | select -expand instrumentationKey
$env:APPI_KEY = $key

az account set -s "Visual Studio Enterprise Subscription"
$keyVaultName = "petereit"
$env:HUBITAT_USERNAME = Get-Secret -KeyVault $keyVaultName -Name "hubitat-username"
$env:HUBITAT_PASSWORD = Get-Secret -KeyVault $keyVaultName -Name "hubitat-password"
$env:HUBITAT_MAKER_API_TOKEN = Get-Secret -KeyVault $keyVaultName -Name "hubitat-maker-api-key"
node logger.js