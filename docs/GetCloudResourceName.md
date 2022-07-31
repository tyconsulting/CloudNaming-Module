---
external help file: CloudNaming-help.xml
Module Name: CloudNaming
online version:
schema: 2.0.0
---

# GetCloudResourceName

## SYNOPSIS

Generate Azure resource names based on pre-defined naming standard.

## SYNTAX

### ByTypeNames

```PowerShell
GetCloudResourceName -type <String[]> [-company <String>] -environment <String> -location <String>
 -appIdentifier <String> [-startInstanceNumber <Int32>] [-instanceCount <Int32>] [<CommonParameters>]
```

### AllSupportedTypes

```
GetCloudResourceName [-company <String>] -environment <String> -location <String> -appIdentifier <String>
 [-startInstanceNumber <Int32>] [-instanceCount <Int32>] [<CommonParameters>]
```

## DESCRIPTION

Generate Azure resource names based on pre-defined naming standard. Output is a deserialized Json payload. You can use ConvertFrom-Json cmdlet to convert the output into an object or an array of objects

## EXAMPLES

### Example 1

```powershell
PS C:\> GetCloudResourceName -company 'contoso' -environment 'p01' -appIdentifier 'test' -startInstanceNumber 1 -instanceCount 2
```

Generate 2 names for each supported resource types with starting sequence number of 1 and the following additional parameters:

-Company: contoso

-environment: p01

-appIdentifier: test

### Example 2

```powershell
PS C:\> GetCloudResourceName -type 'st' -company 'contoso' -environment 'p01' -appIdentifier 'test'
```

Generate 1 name for storage account with default starting sequence number of 1 and the following additional parameters:

-Company: contoso

-environment: p01

-location: aue

-appIdentifier: test

### Example 3

```powershell
PS C:\> GetCloudResourceName -type 'st', 'kv' -company 'contoso' -environment 'p01' -location aue -appIdentifier 'test' -startInstanceNumber 2 -instanceCount 3 | ConvertFrom-Json
```

Generate 3 names for Storage Account and Key Vault with starting sequence number of 2 and the following additional parameters, and convert output to an array of objects:

-Company: contoso

-environment: p01

-location: aue

-appIdentifier: test

### Example 4

```powershell
PS C:\> GetCloudResourceName -type 'sub' -company 'contoso' -workloadType 'pl' -environment 'p01' -appIdentifier 'corp' | ConvertFrom-Json
```

Generate 1 name for an Azure subscription (contoso-lz-corp-p01) with the following parameters, and convert output to an array of objects:

-Company: contoso

-workloadType lz

-environment: p01

-appIdentifier: corp

### Example 5

```powershell
PS C:\> GetCloudResourceName -type 'vm' -workloadType 'db' -environment 'p01' -appIdentifier 'bizapp' | ConvertFrom-Json
```

Generate 1 name for a Virtual Machine (dbp01bizapp-01) with the following parameters, and convert output to an array of objects:

-workloadType db

-environment: p01

-appIdentifier: bizapp

## PARAMETERS

### -appIdentifier

Specify the application identifier

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -associatedResourceType

OPTIONAL: Associated resource type. Used for resource types such as private endpoints and public IPs.

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

OPTIONAL: Associated resource name. Used for resource types such as managed disks and NICs.

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

### -workloadType

OPTIONAL: Workload Type. Used for resource types such as Virtual Machines. i.e. 'db', 'app', 'web', 'etc'.

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

### -company

OPTIONAL: Company name.
If not specified, default value 'contoso' will be used.

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
Default value: 1
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
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -type

OPTIONAL: Azure resource type.
If not specified, all supported types will be processed.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
