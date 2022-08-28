# PowerShell module for Cloud Naming Standard

This folder contains the CloudNaming PowerShell module and the pipeline to deploy it to a NuGet feed hosted on Contoso's internal ADO server.

| Version | Date | Author | Note |
| :-----: | :--: | :----- | :--- |
| 0.1.0 | 01/08/2022 | Tao Yang | Initial release |


## Running locally

When the module is not installed from a module registry or not placed in one of the default PowerShell module directories, you will need to manually import the module first:

```Powershell
Import-Module <path to CloudNaming.psm1>
```

## Documentation

The CloudNaming module contains 2 functions that can be used in generating Cloud resource names for Contoso. The documentation for these 2 functions are located in the [docs](./docs) folder:

* [GetCloudNamingSuportedTypes](./docs/GetCloudNamingSupportedTypes.md)
* [GetCloudResourceName.md](./docs/GetCloudResourceName.md)

A PowerShell help file is also generated from above listed markdown files. it can be accessed within PowerShell:

```PowerShell
#Help for GetCloudNamingSuportedTypes
Get-Help GetCloudNamingSuportedTypes -full

#Help for GetCloudResourceName
Get-Help GetCloudResourceName -full
```

## Instructions

* [**How To Use CloudNaming Module**](./how-to-use.md)
* [**How To Update CloudNaming Json Configuration File**](./Update-Json-Config-File.md)
