---
external help file: CloudNaming-help.xml
Module Name: CloudNaming
online version: https://github.com/tyconsulting/CloudNaming-Module/wiki/NewCloudNamingConfigFile-Command
schema: 2.0.0
---

# NewCloudNamingConfigFile

## SYNOPSIS

Create a new custom configuration file for the CloudNaming module to use.

## SYNTAX

```powershell
NewCloudNamingConfigFile [-configFilePath] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION

Create a new custom configuration file from the default configuration file. This is useful if you want to use a custom configuration file for the CloudNaming module.

## EXAMPLES

### Example 1

```powershell
PS C:\> NewCloudNamingConfigFile -configFilePath C:\Temp\CustomCloudNamingConfig.json
```

Create a custom configuration file for the CloudNaming module at C:\Temp\CustomCloudNamingConfig.json

### Example 2

```powershell
PS C:\> NewCloudNamingConfigFile -configFilePath C:\Temp\CustomCloudNamingConfig.json -force
```

Create a custom configuration file for the CloudNaming module at C:\Temp\CustomCloudNamingConfig.json and overwrite existing file if it exists.

## PARAMETERS

### -configFilePath

The path to the custom configuration file to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -force

Overwrite existing file if exists.

```yaml
Type: SwitchParameter
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
