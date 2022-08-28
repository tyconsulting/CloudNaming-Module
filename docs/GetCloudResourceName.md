---
external help file: CloudNaming-help.xml
Module Name: CloudNaming
online version:
schema: 2.0.0
---

# GetCloudResourceName

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### AllSupportedTypes
```
GetCloudResourceName [-configFilePath <String>] -cloud <String[]> [-company <String>] [-environment <String>]
 [-location <String>] -appIdentifier <String> [-associatedResourceType <String>]
 [-associatedResourceName <String>] [-workloadType <String>] [-startInstanceNumber <Int32>]
 [-instanceCount <Int32>] [<CommonParameters>]
```

### ByTypeNames
```
GetCloudResourceName [-configFilePath <String>] -cloud <String[]> -type <String[]> [-company <String>]
 [-environment <String>] [-location <String>] -appIdentifier <String> [-associatedResourceType <String>]
 [-associatedResourceName <String>] [-workloadType <String>] [-startInstanceNumber <Int32>]
 [-instanceCount <Int32>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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
