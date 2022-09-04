# Copyright (c) TY Consulting.
# Licensed under the MIT License.

function ReadConfigFile {
  [CmdletBinding()]
  [OutputType([Object])]
  Param
  (
    [Parameter(Mandatory = $true)][string]$configFilePath
  )

  #Config File schema validation
  Write-Verbose "JSON schema validation for configuration file '$ConfigFilePath'"
  if (ValidateConfigFileSchema -configFilePath $configFilePath) {
    Write-Verbose "the configuration file '$ConfigFilePath' is valid against the schema."
  } else {
    Throw "The configuration file '$ConfigFilePath' is not valid against the schema."
    Exit -1
  }

  $config = Get-Content $configFilePath | ConvertFrom-Json
  $config
}

function ValidateConfigFileSchema {
  [CmdletBinding()]
  [OutputType([Object])]
  Param
  (
    [Parameter(Mandatory = $true)][string]$configFilePath
  )

  $schemaPath = Join-Path $PSScriptRoot 'CloudNaming.schema.json'
  $schema = get-content -Path $schemaPath -Raw
  $configFileContent = Get-Content -Path $configFilePath -Raw
  Test-Json -Json $configFileContent -Schema $schema
}
function ValidateInput {
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  Param
  (
    [Parameter(Mandatory = $true)][object]$config,
    [Parameter(Mandatory = $true)][object]$cloud,
    [Parameter(Mandatory = $false)][String[]]$type,
    [Parameter(Mandatory = $true)][String]$company,
    [Parameter(Mandatory = $false)][string]$environment,
    [Parameter(Mandatory = $false)][string]$location,
    [Parameter(Mandatory = $false)][string]$appIdentifier,
    [Parameter(Mandatory = $false)][string]$workloadType,
    [Parameter(Mandatory = $false)][string]$associatedResourceType,
    [Parameter(Mandatory = $false)][string]$associatedResourceName,
    [Parameter(Mandatory = $true)][int]$startInstanceNumber,
    [Parameter(Mandatory = $true)][int]$InstanceCount
  )

  #validate cloud proivder
  $bValidCloud = $false
  if ($config.allowedValues.cloud | Where-Object { $_.name -ieq $cloud }) {
    $bValidCloud = $true
  }
  #Validate type
  $bValidType = $true
  if ($PSBoundParameters.ContainsKey('type')) {
    foreach ($item in $type) {
      if (!($config.allowedValues.resourceType | Where-Object { $_.value -ieq $item -and $_.cloud -ieq $cloud })) {
        $bValidType = $false
      }
    }
  }

  #Validate company
  $bValidCompany = $false
  if ($config.allowedValues.company | Where-Object { $_.value -ieq $company }) {
    $bValidCompany = $true
  }

  #Validate environment
  $bValidEnvironment = $false
  if ($PSBoundParameters.ContainsKey('environment')) {
    if ($($environment.Length) -ge $config.control.environment.minLength -and $($environment.Length) -le $config.control.environment.maxLength -and $environment -match $config.control.environment.regex) {
      $bValidEnvironment = $true
    }
  }

  #Validate location
  $bValidLocation = $false
  if ($PSBoundParameters.ContainsKey('location')) {
    if ($($environment.Length) -ge $config.control.environment.minLength -and $($environment.Length) -le $config.control.environment.maxLength) {
      $bValidLocation = $true
    }
  }

  #Validate appIdentifier
  $bValidAppIdentifier = $false
  if ($PSBoundParameters.ContainsKey('appIdentifier')) {
    if ($($appIdentifier.Length) -ge $config.control.appIdentifier.minLength -and $($appIdentifier.Length) -le $config.control.appIdentifier.maxLength) {
      $bValidAppIdentifier = $true
    }
  }

  #validate workloadType
  $bValidWorkloadType = $true
  if ($PSBoundParameters.ContainsKey('workloadType')) {
    if ($($workloadType.Length) -lt $config.control.workloadType.minLength -or $($workloadType.Length) -gt $config.control.workloadType.maxLength) {
      $bValidWorkloadType = $false
    }
  }

  #validate associatedResourceType
  $bValidateAssociatedResourceType = $true
  if ($PSBoundParameters.ContainsKey('associatedResourceType')) {
    if (!($config.allowedValues.resourceType | Where-Object { $_.value -ieq $associatedResourceType })) {
      $bValidateAssociatedResourceType = $false
    }
  }

  #validate associatedResourceName
  $bValidateAssociatedResourceName = $true
  if ($PSBoundParameters.ContainsKey('associatedResourceName')) {
    if ($($associatedResourceName.Length) -ge $config.control.associatedResourceName.minLength -and $($associatedResourceName.Length) -le $config.control.associatedResourceName.maxLength -and $associatedResourceName -match $config.control.associatedResourceName.regex) {
      $bValidateAssociatedResourceName = $true
    }
  }

  #Validate instance number
  $bValidInstanceNumber = $false
  if ($startInstanceNumber -ge $config.control.instance.minValue -and $startInstanceNumber -le $config.control.instance.maxValue) {
    if (($startInstanceNumber + $InstanceCount - 1) -le $config.control.instance.maxValue) {
      $bValidInstanceNumber = $true
    }
  }
  #Generate result
  $result = @{
    'cloud'          = $bValidCloud
    'type'           = $bValidType
    'company'        = $bValidCompany
    'instanceNumber' = $bValidInstanceNumber
  }

  if ($PSBoundParameters.ContainsKey('appIdentifier')) {
    $result.add('appIdentifier', $bValidAppIdentifier)
  }
  if ($PSBoundParameters.ContainsKey('environment')) {
    $result.add('environment', $bValidEnvironment)
  }
  if ($PSBoundParameters.ContainsKey('location')) {
    $result.add('location', $bValidLocation)
  }
  if ($PSBoundParameters.ContainsKey('workloadType')) {
    $result.add('workloadType', $bValidWorkloadType)
  }
  if ($PSBoundParameters.ContainsKey('associatedResourceType')) {
    $result.add('associatedResourceType', $bValidateAssociatedResourceType)
  }
  if ($PSBoundParameters.ContainsKey('associatedResourceName')) {
    $result.add('associatedResourceName', $bValidateAssociatedResourceName)
  }
  $result
}

function GenerateResourceName {
  [CmdletBinding()]
  [OutputType([Object])]
  Param
  (
    [Parameter(Mandatory = $true)][String]$type,
    [Parameter(Mandatory = $true)][String]$company,
    [Parameter(Mandatory = $false)][string]$environment,
    [Parameter(Mandatory = $false)][string]$location,
    [Parameter(Mandatory = $false)][string]$appIdentifier,
    [Parameter(Mandatory = $false)][string]$workloadType,
    [Parameter(Mandatory = $false)][string]$associatedResourceType,
    [Parameter(Mandatory = $false)][string]$associatedResourceName,
    [Parameter(Mandatory = $true)][int]$instanceNumber,
    [Parameter(Mandatory = $true)][object]$resourcePattern,
    [Parameter(Mandatory = $true)][int]$leadingZeros
  )
  $pattern = $resourcePattern.pattern.tolower()
  if ($resourcePattern.leadingZeros) {
    $strInstanceNumber = "{0:d$leadingZeros}" -f $instanceNumber
  } else {
    $strInstanceNumber = $instanceNumber.tostring()
  }
  write-verbose "name pattern for $type`: $pattern. Instance Number: $strInstanceNumber"

  #insert type into name
  $name = $pattern -replace '{resourcetype}', $type
  #insert company into name
  $name = $name -replace '{company}', $company
  #insert environment into name
  if ($PSBoundParameters.ContainsKey('environment')) {
    $name = $name -replace '{environment}', $environment
  }
  #insert location into name
  if ($PSBoundParameters.ContainsKey('location')) {
    $name = $name -replace '{location}', $location
  }
  #insert appIdentifier into name
  if ($PSBoundParameters.ContainsKey('appIdentifier')) {
    $name = $name -replace '{appIdentifier}', $appIdentifier
  }

  #insert workloadType into name
  if ($PSBoundParameters.ContainsKey('workloadType')) {
    $name = $name -replace '{workloadType}', $workloadType
  }
  #insert associatedResourceType into name
  if ($PSBoundParameters.ContainsKey('associatedResourceType')) {
    $name = $name -replace '{associatedResourceType}', $associatedResourceType
  }
  #insert associatedResourceName into name
  if ($PSBoundParameters.ContainsKey('associatedResourceName')) {
    $name = $name -replace '{associatedResourceName}', $associatedResourceName
  }
  #insert instance number into name
  $name = $name -replace '{instance}', $strInstanceNumber

  #convert case
  if ($resourcePattern.case -ieq 'lower') {
    $name = $name.tolower()
  } elseif ($resourcePattern.case -ieq 'upper') {
    $name = $name.toupper()
  } else {
    throw "invalid case '$($resourcePattern.case)' for $($resourcePattern.description). Valid values are 'lower' and 'upper'"
    exit -1
  }
  Write-verbose "Name generated for $($resourcePattern.description): $($name)"
  #validate the generated name before returning the result
  #make sure all the fields from the pattern are processed
  $bValidName = $true
  if ($name -match '{[^}]*}') {
    Write-Verbose "invalid pattern '$($pattern)' for $($resourcePattern.description). Pattern contains unprocessed fields. The name will be ignored."
    $bValidName = $false
  }
  #length validation
  if ($bValidName) {
    if ($name.length -lt $resourcePattern.minLength -or $name.length -gt $resourcePattern.maxLength) {
      Write-Warning "invalid length for tne name generated for $($resourcePattern.description) - $name. Valid length is between $($resourcePattern.minLength) and $($resourcePattern.maxLength) and the actual length is $($name.length). The name will be ignored."
      $bValidName = $false
    }
  }

  if ($bValidName) {
    $name
  } else {
    $null
  }
}

# .EXTERNALHELP en-US/CloudNaming-Help.xml
function GetCloudResourceName {
  [CmdletBinding()]
  [OutputType([string])]
  Param
  (
    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: The custom configuration file to use. If not specified, the default configuration file 'CloudNaming.json' from the module directory will be used.")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: The custom configuration file to use. If not specified, the default configuration file 'CloudNaming.json' from the module directory will be used.")]
    [ValidateScript({ $(test-Path -Path $_ -PathType Leaf) -and $($(Get-ItemProperty -Path $_).Extension -ieq '.json') })]
    [String]$configFilePath,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $true, HelpMessage = "Cloud Provider")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $true, HelpMessage = "Cloud Provider")]
    [String[]]$cloud,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $true, HelpMessage = "OPTIONAL: Cloud resource type. If not specified, all supported types will be returned.")]
    [String[]]$type,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Company or Business Unit name. If not specified, the first value defined in the allowedValue section in the configuration file is the default value.")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Company or Business Unit name. If not specified, the first value defined in the allowedValue section in the configuration file is the default value.")]
    [Alias('businessUnit')]
    [ValidateNotNullOrEmpty()][String]$company,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the environment")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the environment")]
    [string]$environment,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the location or region of the cloud provider")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the location or region of the cloud provider")]
    [string]$location,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "Specify the application identifier")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "Specify the application identifier")]
    [string]$appIdentifier,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Associated resource type. Used for resource types such as private endpoints and public IPs.")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "Associated resource type. Used for resource types such as private endpoints and public IPs.")]
    [string]$associatedResourceType,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Associated resource name. Used for resource types such as managed disks and NICs.")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "Associated resource name. Used for resource types such as managed disks and NICs.")]
    [string]$associatedResourceName,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Workload Type. Used for resource types such as Virtual Machines. i.e. 'db', 'app', 'web', 'etc'.")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "Workload Type. Used for resource types such as Virtual Machines. i.e. 'db', 'app', 'web', 'etc'")]
    [string]$workloadType,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the starting instance number. Default value is 1")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the starting instance number. Default value is 1")]
    [int]$startInstanceNumber = 1,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the instance count. Default value is 1")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the instance count. Default value is 1")]
    [int]$instanceCount = 1
  )

  #Read configuration file
  if ($PSBoundParameters.ContainsKey('configFilePath')) {
    Write-Verbose "Custom configuration file specified: '$configFilePath'"
  } else {
    $configFilePath = Join-Path $PSScriptRoot 'CloudNaming.json' -Resolve
    Write-Verbose "No custom configuration file specified. Using default configuration file from the CloudNaming module directory: '$configFilePath'"
  }
  Write-verbose "Read Cloud Naming configuration file '$configFilePath'"

  try {
    $config = ReadConfigFile -configFilePath $configFilePath
  } catch {
    #throw "Unable to read configuration file"
    throw $_
    exit -1
  }

  #Get company value
  if (!($PSBoundParameters.ContainsKey('company'))) {
    $company = $config.allowedValues.company[0].value
    if (!$company) {
      Throw "No company value defined in the configuration file. Please define at least one company value in the configuration file."
      Exit -1
    } else {
      Write-verbose "The 'Company' parameter is not specified. Using the first Allowed Value '$company' from the configuration file instead."
    }
  }
  #input validation
  Write-verbose "Input validation"
  $validateParams = @{
    'config'              = $config
    'cloud'               = $cloud
    'company'             = $company
    'startInstanceNumber' = $startInstanceNumber
    'instanceCount'       = $instanceCount
  }

  if ($PSBoundParameters.ContainsKey('appIdentifier')) {
    $validateParams.Add('appIdentifier', $appIdentifier)
  }
  if ($PSBoundParameters.ContainsKey('type')) {
    $validateParams.Add('type', $type)
  }
  if ($PSBoundParameters.ContainsKey('environment')) {
    $validateParams.Add('environment', $environment)
  }
  if ($PSBoundParameters.ContainsKey('location')) {
    $validateParams.Add('location', $location)
  }
  if ($PSBoundParameters.ContainsKey('associatedResourceType')) {
    $validateParams.Add('associatedResourceType', $associatedResourceType)
  }
  if ($PSBoundParameters.ContainsKey('associatedResourceName')) {
    $validateParams.Add('associatedResourceName', $associatedResourceType)
  }
  if ($PSBoundParameters.ContainsKey('workloadType')) {
    $validateParams.Add('workloadType', $workloadType)
  }
  $validationResult = ValidateInput @validateParams

  $bAllValid = $true
  foreach ($property in  $validationResult.getEnumerator()) {
    if ($($property.value) -eq $false) {
      Write-Error "Invalid value specified for $($property.name)"
      $bAllValid = $false
    } else {
      Write-verbose "Valid value specified for $($property.name)."
    }
  }
  If (!$bAllValid) {
    throw "One or more input parameters are invalid."
    exit -1
  }
  #Get all allowed values for the specified cloud provider
  $availableResourcesForCloud = $config.allowedValues.resourceType | Where-Object { $_.cloud -ieq $cloud }

  #determine resource types in scope
  Write-verbose "Determine resource types in scope"
  if (!$PSBoundParameters.ContainsKey('type')) {
    $type = $availableResourcesForCloud.value
  }
  Write-verbose "type: $($type)"
  #determine leading zeros for the instance number
  write-verbose "Determine leading zeros for the instance number"
  $leadingZeros = $config.control.instance.maxValue.tostring().length

  #Generate resource names
  Write-verbose "Generate resource names"
  $arrNames = @()
  foreach ($item in $type) {
    Write-verbose "Generate resource names for type '$item' in cloud $cloud. Instance Count: $instanceCount"
    $resourcePattern = $availableResourcesForCloud | Where-Object { $_.value -ieq $item }
    $objNames = @{
      'type'        = $item
      'description' = $resourcePattern.description
      'names'       = @()
    }
    for ($i = 0; $i -lt $instanceCount; $i++) {
      $instanceNumber = $startInstanceNumber + $i
      Write-verbose "Generate resource names for type '$item' and instance number '$instanceNumber'"
      $generateNameParam = @{
        'type'            = $item
        'company'         = $company
        'instanceNumber'  = $instanceNumber
        'resourcePattern' = $resourcePattern
        'leadingZeros'    = $leadingZeros
      }
      if ($PSBoundParameters.ContainsKey('appIdentifier')) {
        $generateNameParam.Add('appIdentifier', $appIdentifier)
      }
      if ($PSBoundParameters.ContainsKey('environment')) {
        $generateNameParam.Add('environment', $environment)
      }
      if ($PSBoundParameters.ContainsKey('location')) {
        $generateNameParam.Add('location', $location)
      }
      if ($PSBoundParameters.ContainsKey('workloadType')) {
        $generateNameParam.Add('workloadType', $workloadType)
      }
      if ($PSBoundParameters.ContainsKey('associatedResourceType')) {
        $generateNameParam.Add('associatedResourceType', $associatedResourceType)
      }
      if ($PSBoundParameters.ContainsKey('associatedResourceName')) {
        $generateNameParam.Add('associatedResourceName', $associatedResourceName)
      }
      $name = GenerateResourceName @generateNameParam
      if ($name) {
        #deduplicate names
        if (!($objNames.names -contains $name)) {
          $objNames.names += $name
        } else {
          write-verbose "Duplicate name for $type found: $name. Skipping."
        }
        #$objNames.names += $name
      }
    }
    if ($objNames.names.count -gt 0) {
      $arrNames += $objNames
    }
  }

  #deserialize the result
  Write-Verbose "Deserialize the result"
  $output = $arrNames | sort-object -Property 'type' | ConvertTo-Json -Compress -Depth 3
  $output
}

# .EXTERNALHELP en-US/CloudNaming-Help.xml
function GetCloudNamingSupportedTypes {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $false, HelpMessage = "OPTIONAL: The custom configuration file to use. If not specified, the default configuration file 'CloudNaming.json' from the module directory will be used.")]
    [ValidateScript({ $(test-Path -Path $_ -PathType Leaf) -and $($(Get-ItemProperty -Path $_).Extension -ieq '.json') })]
    [String]$configFilePath,

    [Parameter(Mandatory = $false, HelpMessage = "OPTIONAL: Resource type search string. RegEx is supported. i.e. '^virtual machine$'")]
    [String]$searchString,

    [Parameter(Mandatory = $false, HelpMessage = "OPTIONAL: Cloud Provider to search for. i.e. 'Azure'")]
    [String]$cloud
  )
  #Read configuration file
  if ($configFilePath) {
    Write-Verbose "Custom configuration file specified: '$configFilePath'"
    $config = ReadConfigFile -configFilePath $configFilePath
  } else {
    Write-Verbose "No custom configuration file specified. Using default configuration file from the CloudNaming module directory"
    $config = ReadConfigFile -configFilePath $(Join-Path $PSScriptRoot 'CloudNaming.json' -Resolve)
  }

  try {

  } catch {
    #throw "Unable to read configuration file"
    throw $_
    exit -1
  }

  #get supported types
  if ($PSBoundParameters.ContainsKey('searchString')) {
    $SupportedTypes = $config.allowedValues.resourceType | Where-Object { $_.description -imatch $searchString }
  } else {
    $SupportedTypes = $config.allowedValues.resourceType
  }

  if ($PSBoundParameters.ContainsKey('cloud')) {
    $SupportedTypes = $SupportedTypes | where-object { $_.cloud -imatch $cloud }
  }
  $SupportedTypes | ConvertTo-Json -Compress -Depth 3
}