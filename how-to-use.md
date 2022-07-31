# How To Use CloudNaming PowerShell Module

## Introduction

THe **CloudNaming** PowerShell module is designed to be used as a standalone tool or a component that can be called within an Azure DevOps pipeline to automatically generate resource names for the new sources to be created in Azure.

It supports all the resources listed in Contoso's Azure Naming standard document.

This document explains how it can be used to generate Azure resource names.

## Instruction

### Installing the Module

The module code is located in the [**CloudNaming**](./CloudNaming) folder in this repository. To obtain the module, you can simply clone this repository.

To have the module permanently available, you will need to copy the **CloudNaming** folder to a folder defined in the `$env:PSModulePath` environment variable.

To use the module without copying, manually import the module use the command below:

```PowerShell
Import-Module <path CloudNaming/CloudNaming.psd1>
```

### Using the Module

Once the module is installed by copying to a folder listed in `$env:PSModulePath` or manually imported, you can start using the module.

#### To list available commands

```PowerShell
Get-Command -Module CloudNaming
```

#### To access the help file for each command

```PowerShell
#GetCloudResourceName
Get-Help GetCloudResourceName -Full

#GetCloudNamingSupportedTypes
Get-Help GetCloudNamingSupportedTypes -Full
```

### To find all supported resource types and details or each naming pattern

```powershell
GetCloudNamingSupportedTypes | convertFrom-Json | format-table
```

### To search all supported resource types with the "Virtual Machine" phrase

```powershell
#This will return both Virtual Machine and Virtual Machine Scale Set
GetCloudNamingSupportedTypes -searchString "virtual machine" | convertFrom-Json | format-table
```

### To find all naming standard for Virtual Machines by using regular expression in search string

```powershell
#This will only return Virtual Machine
GetCloudNamingSupportedTypes -searchString "^virtual machine$" | convertFrom-Json | format-table
```

### To generate names for a particular resource type

Once you have identified the resource type abbreviation and the required parameter that makes up the name for this particular type, you can generate the name:

i.e. for storage account, the abbreviation is `st` and the pattern is `{company}{resourceType}{environment}{appIdentifier}{instance}`

```powershell
#Generate 2 names for Storage Account with starting sequence number of 1 (default value, no need to specify)
GetCloudResourceName -type "st" -company "contoso" -environment P01 -appIdentifier "bizapp" -instanceCount 2 | convertFrom-Json
```

Output:

```
type description     names
---- -----------     -----
st   Storage Account {contosostp01bizapp01, contosostp01bizapp02}
```

### To generate names for multiple resource types

ie. an application requires 1 VM, 1 Storage Account and 1 Key Vault, to generate all required names in 1 command:

```powershell
# for storage account, the abbreviation is `st` and the pattern is `{company}{resourceType}{environment}{appIdentifier}{instance}`
# for VM, the abbreviation is "vm" and the pattern is {workloadType}{environment}{appIdentifier}-{instance}
# for Key Vault, the abbreviation is "kv" and the pattern is {company}-{resourceType}-{environment}-{appIdentifier}-{instance}
# to combine the requirements, "type", "company", "environment", "appIdentifier" and "workloadType" need to be specified

GetCloudResourceName -type "st", "kv", "vm" -company "contoso" -environment "P01" -appIdentifier "bizapp" -workloadType "App" | ConvertFrom-Json
```

Output:

```
type description     names
---- -----------     -----
st   Storage Account {contosostp01bizapp01}
kv   Key Vault       {contoso-kv-p01-bizapp-01}
vm   Virtual Machine {appp01bizapp-01}
```
