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
GetCloudNamingSupportedTypes [[-searchString] <String>] [<CommonParameters>]
```

## DESCRIPTION

List or search supported Azure resource types from the CloudNaming module

## EXAMPLES

### Example 1

```powershell
PS C:\> GetCloudNamingSupportedTypes
```

Get all supported resource types from the CloudNaming module

### Example 2

```powershell
PS C:\> GetCloudNamingSupportedTypes -searchString '^virtual machine$' | ConvertFrom-Json
```

Search supported resource types from the Azure Naming module using a regular expression and convert the output to an array of objects.

## PARAMETERS

### -searchString

OPTIONAL: Resource type search string.
RegEx is supported.
i.e.
'^virtual machine$'

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
