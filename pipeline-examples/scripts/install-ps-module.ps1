<#
=========================================================================
AUTHOR: Tao Yang
DATE: 01/09/2022
NAME: install-ps-module.ps1
VERSION: 1.0.0
COMMENT: Install PS module from Azure Artifact feed
=========================================================================
#>
[CmdletBinding()]
param (
  [parameter(Mandatory = $false)]
  [string]$repoName = 'PSModules',

  [parameter( Mandatory = $true)]
  [string]$sourceLocation,

  [parameter( Mandatory = $true)]
  [string]$accessToken,

  [parameter( Mandatory = $true)]
  [string[]]$modules
)

#register PS repo
Write-output "Create credential for PS Repository '$repoName'."
$pw = New-Object SecureString
foreach ($char in $accessToken.ToCharArray()) {
  $pw.AppendChar($char)
}

$cred = New-Object System.Management.Automation.PSCredential 'abc', $pw

Write-Output "Register PS Repository '$repoName' with source location '$sourceLocation'."
Register-PackageSource -ProviderName 'PowerShellGet' -Name $repoName -Location $sourceLocation -Credential $cred

#install module
Foreach ($module in $modules) {
  Write-Output "Find module '$module' from '$repoName'"
  $moduleFromRepo = Find-Module -Repository $repoName -Name $module -Credential $cred
  If (!$moduleFromRepo) {
    Write-Error "Unable to find module '$module' from repo '$repoName'. Unable to continue."
    Exit -1
  } else {
    Write-output "Module '$module' found from repo '$repoName'. Latest version: '$($moduleFromrepo.version)'."
    Write-output "Installing module '$module' from repo '$repoName'..."
    Install-module -Name $module -Repository $repoName -Scope CurrentUser -force  -Credential $cred
  }

}

Write-Output "Done"