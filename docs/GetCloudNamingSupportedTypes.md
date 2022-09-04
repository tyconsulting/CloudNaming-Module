---
external help file: CloudNaming-help.xml
Module Name: CloudNaming
online version:
schema: 2.0.0
---

# GetCloudNamingSupportedTypes

## SYNOPSIS
Get supported Azure resource types from the CloudNaming module

## SYNTAX

```PowerShell
GetCloudNamingSupportedTypes [[-configFilePath] <String>] [[-searchString] <String>] [[-cloud] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
List or search supported cloud resource types from the CloudNaming module.

## EXAMPLES

### Example 1

```powershell
PS C:\> GetCloudNamingSupportedTypes | convertfrom-json | format-table
```

Get all supported resource types from the CloudNaming module

### Example 2

```powershell
PS C:\> GetCloudNamingSupportedTypes -searchString '^virtual' | ConvertFrom-Json
```

Search supported resource types from all supported Cloud providers using a regular expression and convert the output to an array of objects.

### Example 3

```powershell
PS C:\> GetCloudNamingSupportedTypes -cloud 'azure' -searchString '^virtual machine' | ConvertFrom-Json
```

Search supported resource types for Azure using a regular expression and convert the output to an array of objects.

### Example 4

```powershell
PS C:\> GetCloudNamingSupportedTypes -cloud 'azure' -configFilePath 'c:\temp\config.json' | ConvertFrom-Json
```

Search supported resource types for Azure from a custom configuration file and convert the output to an array of objects.

## PARAMETERS

### -cloud
OPTIONAL: Cloud Provider to search for.
i.e.
'Azure'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -searchString
OPTIONAL: Resource type search string.
Regular Expression is supported.
i.e.
'^virtual machine$'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
