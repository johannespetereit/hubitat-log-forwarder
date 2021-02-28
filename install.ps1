param(
  [Parameter(Position = 1, ParameterSetName = 'Release')]
  [switch]$CreateRelease,
  # if not given, defaults to latest pushed tag + 0.1
  [Parameter(Position = 2, ParameterSetName = 'Release')]
  [string]$Version,

  [Parameter(Position = 3, ParameterSetName = 'Release')]
  [string]$KubernetesContextName = 'pi',
  [Parameter(Position = 4, ParameterSetName = 'Release')]
  [string]$SubscriptionName = 'Visual Studio Enterprise Subscription'

)
function Get-KeyVaultSecret{
  param([string]$Name)
  return (az keyvault secret show --vault-name petereit -n "hubitat-$name" --query 'value' -otsv).trim()
}

function Create-Release{
  param(
    [Parameter()][string]$Version,
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$KubernetesContextName
  )
  if ([string]::IsNullOrEmpty($version)){
    $tags = curl https://registry.hub.docker.com/v2/repositories/jpetereit/hubitat-log-forwarder/tags | convertfrom-json | select -expand results
    $latest = $tags | ? {$_.name -eq 'latest'} | %{$_.images.digest}
    $latestTypedTag = $tags | ? {$_.images.digest -eq $latest -and $_.Name -match "^[a-z0-9]{40}$"} | sort last_updated -Descending | select -first 1 -Expand name

    if ([string]::IsNullOrEmpty($latestTypedTag)){
      throw "Version is not given and could not be read from docker"
    }
  }
  az account set -s "Visual Studio Premium mit MSDN"
  $instrumentationKey =  az monitor app-insights component show  --app appi-hubitat --resource-group hubitat | convertfrom-json | select -expand instrumentationKey
  
  az account set -s $SubscriptionName
  kubectl config use-context $KubernetesContextName
  
  helm upgrade --install log-forwarder  --namespace hubitat `
      --create-namespace `
      --set secrets.hubitat.username="$(Get-KeyVaultSecret username)" `
      --set secrets.hubitat.password="$(Get-KeyVaultSecret password)" `
      --set secrets.makerApi.token="$(Get-KeyVaultSecret 'maker-api-key')" `
      --set secrets.applicationInsights.instrumentationKey="$instrumentationKey" `
      --set image.tag=$latestTypedTag `
      charts\hubitat-log-forwarder
}

if ($CreateRelease.IsPresent){
  Create-Release -Version $Version -SubscriptionName $SubscriptionName -KubernetesContextName $KubernetesContextName
}
