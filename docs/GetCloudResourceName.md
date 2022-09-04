---
external help file: CloudNaming-help.xml
Module Name: CloudNaming
online version:
schema: 2.0.0
---

# GetCloudResourceName

## SYNOPSIS
Generate cloud resource names based on pre-defined naming standard.

## SYNTAX

### AllSupportedTypes
```PowerShell
GetCloudResourceName [-configFilePath <String>] -cloud <String[]> [-company <String>] [-environment <String>]
 [-location <String>] -appIdentifier <String> [-associatedResourceType <String>]
 [-associatedResourceName <String>] [-workloadType <String>] [-startInstanceNumber <Int32>]
 [-instanceCount <Int32>] [<CommonParameters>]
```

### ByTypeNames
```PowerShell
GetCloudResourceName [-configFilePath <String>] -cloud <String[]> -type <String[]> [-company <String>]
 [-environment <String>] [-location <String>] -appIdentifier <String> [-associatedResourceType <String>]
 [-associatedResourceName <String>] [-workloadType <String>] [-startInstanceNumber <Int32>]
 [-instanceCount <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Generate cloud resource names based on pre-defined naming standard. Output is a deserialized Json payload. You can use ConvertFrom-Json cmdlet to convert the output into an object or an array of objects

## EXAMPLES

## EXAMPLES

### Example 1

```powershell
PS C:\> GetCloudResourceName -cloud 'azure' -company 'abc' -environment 'p01' -location 'aue' -appIdentifier 'test' -startInstanceNumber 1 -instanceCount 2
```

Generate 2 names for each supported resource types with starting sequence number of 1 and the following additional parameters:

-Cloud: Azure

-Company: abc

-environment: p01

-appIdentifier: test

### Example 2

```powershell
PS C:\> GetCloudResourceName -cloud 'azure' -type 'sa' -company 'abc' -environment 'p01' -appIdentifier 'test'
```

Generate 1 name for Azure storage account with default starting sequence number of 1 and the following additional parameters:

-Company: abc

-environment: p01

-location: aue

-appIdentifier: test

### Example 3

```powershell
PS C:\> GetCloudResourceName -cloud 'azure' -type 'sa', 'kv' -company 'abc' -environment 'p01' -location aue -appIdentifier 'test' -startInstanceNumber 2 -instanceCount 3 | ConvertFrom-Json
```

Generate 3 names for Storage Account and Key Vault for Azure with starting sequence number of 2 and the following additional parameters, and convert output to an array of objects:

-Company: abc

-environment: p01

-location: aue

-appIdentifier: test

### Example 4

```powershell
PS C:\> GetCloudResourceName -cloud 'azure' -type 'sub' -company 'abc' -workloadType 'pl' -environment 'p01' -appIdentifier 'corp' | ConvertFrom-Json
```

Generate 1 name for an Azure subscription with the following parameters, and convert output to an array of objects:

-Company: abc

-workloadType lz

-environment: p01

-appIdentifier: corp

### Example 5

```powershell
PS C:\> GetCloudResourceName -cloud 'aws' -type 'ec2' -workloadType 'db' -location 'aue' -environment 'p01' -appIdentifier 'bizapp' | ConvertFrom-Json
```

Generate 1 name for an AWS EC2 instance with the following parameters, and convert output to an array of objects:

-workloadType: db

-location: aue

-environment: p01

-appIdentifier: bizapp

### Example 6

```powershell
PS C:\> GetCloudResourceName -cloud 'gcp' -type 'proj' -environment 'p01' -appIdentifier 'bizapp' | ConvertFrom-Json
```

Generate 1 name for a GCP project, and convert output to an array of objects:

-environment: p01

-appIdentifier: bizapp

### Example 7

```powershell
PS C:\> GetCloudResourceName -cloud 'azure' -configFilePath 'C:\Temp\config.json' -type 'sub' -company 'IT' -workloadType 'pl' -environment 'p01' -appIdentifier 'corp' | ConvertFrom-Json
```

Generate 1 name for an Azure subscription using a custom configuration file with the following parameters, and convert output to an array of objects:

-ConfigFilePath: C:\\temp\\config.json

-Company or BusinessUnit: IT

-workloadType pl

-environment: p01

-appIdentifier: corp
## PARAMETERS

### -appIdentifier
Specify the application identifier

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -associatedResourceName
Associated resource name.
Used for resource types such as managed disks and NICs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -associatedResourceType
Associated resource type.
Used for resource types such as private endpoints and public IPs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -cloud
Cloud Provider

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -company
OPTIONAL: Company or Business Unit name.
If not specified, the first value defined in the allowedValue section in the configuration file is the default value.

```yaml
Type: String
Parameter Sets: (All)
Aliases: businessUnit

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -configFilePath
OPTIONAL: The custom configuration file to use.
If not specified, the default configuration file 'CloudNaming.json' from the module directory will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -environment
OPTIONAL: Specify the environment

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -instanceCount
OPTIONAL: Specify the instance count.
Default value is 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -location
OPTIONAL: Specify the location or region of the cloud provider

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -startInstanceNumber
OPTIONAL: Specify the starting instance number.
Default value is 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -type
OPTIONAL: Cloud resource type.
If not specified, all supported types will be returned.

```yaml
Type: String[]
Parameter Sets: ByTypeNames
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -workloadType
Workload Type.
Used for resource types such as Virtual Machines.
i.e.
'db', 'app', 'web', 'etc'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
