# Updating CloudNaming Json Configuration File

## Introduction

The **CloudNaming** PowerShell module comes with a configuration file [`CloudNaming.json`](./CloudNaming/CloudNaming.json). This file is used to store configuration for the CloudNaming module. The following information is stored in `CloudNaming.json`:

* Supported input parameters for the `CloudNaming` PowerShell module and the validation methods for each input.
* Allowed values for certain input parameters

The `CloudNaming` PowerShell module is designed in a way that all business rules are stored in the `CloudNaming.json` configuration file so it can be updated and maintained by people who are not PowerShell savvy.

## Instructions

The `CloudNaming.json` file is constructed as below:

```json
{
    "controls": {
    //defines how a valid value should be for each input parameter when executing the commands within CloudNaming module.
    },
    "allowedValues": {
        "company": [
        //defines all the allowed values for the "company" parameter.
        ],
        "resourceTypes": [
        //defines all the resource types that are supported by the CloudNaming module, and the naming pattern for each type.
        ]
    }
}
```

### Update Input Parameter Controls

The command `GetCloudResourceName` from the `CloudNaming` module takes the following (optional) parameters to generate names:

* company (string)
* type (string)
* environment (string)
* appIdentifier (string)
* associatedResourceType (string)
* associatedResourceName (string)
* workloadType (string)
* startInstanceNumber (integer)
* instanceCount (integer)

Depending on the parameter, they are being validated using a combination of Minimum / Maximum Length, Minimum / Maximum Value and Regular Expression (Regex)
The following values are defined in the `control` section of the `CloudNaming.json` file. They can be updated accordingly.

| Name | Description | Type | MinLength Support | MaxLength Support | MinValue Support | MaxValue Support | Regex Support |
|------|-------------|:----:|:-----------------:|:-----------------:|:----------------:|:----------------:|:-------------:|
| company | company abbreviation | string | Yes | Yes | No | No | No |
| resourceType | related to the `type` parameter, representing the Azure resource type | string | Yes | Yes | No | No | No |
| environment | related to the `environment` parameter. representing Contoso's Azure environment code | string | Yes | Yes | No | No | Yes |
| appIdentifier | related to the 'appIdentifier' parameter. | string | Yes | Yes | No | No | No |
| associatedResourceType | representing the `associatedResourceType` parameter | string | Yes | Yes | No | No | No |
| associatedResourceName | representing the `associatedResourceName` parameter | string | Yes | Yes | No | No | Yes |
| workloadType | representing the `workloadType` parameter | string | Yes | Yes | No | No | No |
| instance | the instance number. it's calculated from the `startInstanceNumber` and `instanceCount` parameter | integer | No | No | Yes | Yes | No |

### Updating Allowed Values

#### Updating Allowed Values for the Company

This `company` array represents all the possible business unit / company abbreviations within Contoso that can be used to construct some of the Azure resource names. this array can be update accordingly.

>**NOTE**: the value **contoso** is also defined as the default value for the `-company` input parameter. when this value is changed, please also update the default value for the `-company` parameter of the `GetCloudResourceName` command in the [`CloudNaming.psm1`](./CloudNaming/CloudNaming.psm1) file.

#### Updating Allowed values for Resource Types

the `resourceType` section defines each supported Azure resource types by the `CloudNaming module`. each block contains the following attributes:

* **value**: the short name of the resource type defined by the Contoso Azure Naming Standard.
* **description**: the common name for the resource type.
* **minLength**: Azure's minimum supported length of the name for this resource type
* **maxLength**: Azure's maximum supported length of the name for this resource type
* **case**: the `lower` or `upper` case for the name generated for this resource type
* **leadingZeros**: Boolean, specify if the instance number should contain leading zeros. i.e. if the maximum instance count (specified in the `maxValue` for the `instance` in the `control` section) is `99`, the instance numbers would be `01...99`. If the maximum instance count is `999`, the instance numbers would be `001...099...999`.
* **pattern**: the naming pattern for the resource type. it is formed with some (or all) parameters defined in the `control` section. Each parameter is wrapped using curly brackets `{}`.

Resource types can be added, deleted and updated in the `resourceType` section. When updating this section, please make sure:

* No duplicate value in the "value" attributes (meaning no resource types sharing the same abbreviation)
* No duplicate value in the "description" attribute. This attribute is used by the `GetCloudNamingSupportedTypes` command, which is used to search for supported resource types.
* Make sure the `minLength` and `maxLength` for the particular resource type is clearly defined according to Microsoft Azure's naming requirements. Each generated name are validated against these values to ensure it can be indeed used in Azure.
* Make sure the correct case is defined. Some Azure resource types have such requirements i.e. Names for Azure Storage Account can only be in lower case.
* Make sure the pattern you specified complies with the requirements in Azure. i.e. some resource names cannot start with a number, no consecutive dashes `-`, etc.

### Validation

After the `CloudNaming.json` configuration file is updated, make sure the following tasks are performed:

#### Schema validation

Validate the updated json file against it's Json Schema [`CloudNaming.schema.json`](./schema/CloudNaming.schema.json)

In **PowerShell Core** (PowerShell v7.x), **NOT** Windows PowerShell (v5.x):

```powershell
$json = get-content -path <path to CloudNaming.json> -raw
$schema = get-content -path .<path to CloudNaming.schema.json> -raw
test-json -json $Json -schema $schema
```

#### Increase Module Version Number

Increase the `CloudNaming` PowerShell module version in [`CloudNaming.psd1`](./CloudNaming/CloudNaming.psd1) by updating the `ModuleVersion` attribute. the version must be updated otherwise the pipeline will not be able to publish the NuGet package to the Azure Artifacts NuGet feed due to version conflict.

>**IMPORTANT**: Generally, the [Semantic Versioning format](https://semver.org/) `MAJOR.MINOR.PATCH` are widely used for PowerShell modules. Make sure the guideline is followed when updating the version number:
>
>1. MAJOR version when you make incompatible API changes,
>2. MINOR version when you add functionality in a backwards compatible manner, and
>3. PATCH version when you make backwards compatible bug fixes.
