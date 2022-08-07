function ReadConfigFile {
  [CmdletBinding()]
  [OutputType([Object])]
  $configFilePath = Join-Path $PSScriptRoot 'CloudNaming.json'
  $config = Get-Content $configFilePath | ConvertFrom-Json
  $config
}

function ValidateInput {
  [CmdletBinding()]
  [OutputType([Object])]
  Param
  (
    [Parameter(Mandatory = $true)][object]$config,
    [Parameter(Mandatory = $true)][object]$cloud,
    [Parameter(Mandatory = $false)][String[]]$type,
    [Parameter(Mandatory = $true)][String]$company,
    [Parameter(Mandatory = $false)][string]$environment,
    [Parameter(Mandatory = $false)][string]$location,
    [Parameter(Mandatory = $true)][string]$appIdentifier,
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
      if (!($config.allowedValues.resourceType | Where-Object { $_.value -ieq $item })) {
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

  #Validate appIdentifier
  $bValidAppIdentifier = $false
  if ($($appIdentifier.Length) -ge $config.control.appIdentifier.minLength -and $($appIdentifier.Length) -le $config.control.appIdentifier.maxLength) {
    $bValidAppIdentifier = $true
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
    'appIdentifier'  = $bValidAppIdentifier
    'instanceNumber' = $bValidInstanceNumber
  }

  if ($PSBoundParameters.ContainsKey('environment')) {
    $result.add('environment', $bValidEnvironment)
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
    [Parameter(Mandatory = $true)][string]$appIdentifier,
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
    $name = $name -replace '{location}', $environment
  }
  #insert appIdentifier into name
  $name = $name -replace '{appIdentifier}', $appIdentifier
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
  if ($name.length -lt $resourcePattern.minLength -or $name.length -gt $resourcePattern.maxLength) {
    Write-Warning "invalid length for tne name generated for $($resourcePattern.description) - $name. Valid length is between $($resourcePattern.minLength) and $($resourcePattern.maxLength) and the actual length is $($name.length). The name will be ignored."
    $bValidName = $false
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
    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $true, HelpMessage = "Cloud Provider")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $true, HelpMessage = "Cloud Provider")]
    [String[]]$cloud,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $true, HelpMessage = "OPTIONAL: Azure resource type. If not specified, all supported types will be returned.")]
    [String[]]$type,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Company name. If not specified, default value 'contoso' will be used.")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Company name. If not specified, default value 'contoso' will be used.")]
    [ValidateNotNullOrEmpty()][String]$company = 'contoso',

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the environment")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the environment")]
    [string]$environment,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the location or region of the cloud provider")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $false, HelpMessage = "OPTIONAL: Specify the location or region of the cloud provider")]
    [string]$location,

    [Parameter(ParameterSetName = 'ByTypeNames', Mandatory = $true, HelpMessage = "Specify the application identifier")]
    [Parameter(ParameterSetName = 'AllSupportedTypes', Mandatory = $true, HelpMessage = "Specify the application identifier")]
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
  Write-verbose "Read Azure Naming configuration file"
  try {
    $config = ReadConfigFile
  } catch {
    throw "Unable to read configuration file"
    exit -1
  }

  #input validation
  Write-verbose "Input validation"
  $validateParams = @{
    'config'              = $config
    'cloud'               = $cloud
    'company'             = $company
    'startInstanceNumber' = $startInstanceNumber
    'appIdentifier'       = $appIdentifier
    'instanceCount'       = $instanceCount
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

  #determine resource types in scope
  Write-verbose "Determine resource types in scope"
  if (!$PSBoundParameters.ContainsKey('type')) {
    $type = $config.allowedValues.resourceType.value
  }
  Write-verbose "type: $($type)"
  #determine leading zeros for the instance number
  write-verbose "Determine leading zeros for the instance number"
  $leadingZeros = $config.control.instance.maxValue.tostring().length

  #Generate resource names
  Write-verbose "Generate resource names"
  $arrNames = @()
  foreach ($item in $type) {
    Write-verbose "Generate resource names for type '$item'. Instance Count: $instanceCount"
    $resourcePattern = $config.allowedValues.resourceType | Where-Object { $_.value -ieq $item }
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
        'appIdentifier'   = $appIdentifier
        'instanceNumber'  = $instanceNumber
        'resourcePattern' = $resourcePattern
        'leadingZeros'    = $leadingZeros
      }
      if ($PSBoundParameters.ContainsKey('environment')) {
        $generateNameParam.Add('environment', $environment)
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
  $output = $arrNames | ConvertTo-Json -Compress -Depth 3
  $output
}

# .EXTERNALHELP en-US/CloudNaming-Help.xml
function GetCloudNamingSupportedTypes {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $false, HelpMessage = "OPTIONAL: Resource type search string. RegEx is supported. i.e. '^virtual machine$'")]
    [String]$searchString
  )
  #Read configuration file
  Write-verbose "Read Azure Naming configuration file"
  try {
    $config = ReadConfigFile
  } catch {
    throw "Unable to read configuration file"
    exit -1
  }
  #get supported types
  if ($PSBoundParameters.ContainsKey('searchString')) {
    $SupportedTypes = $config.allowedValues.resourceType | Where-Object { $_.description -imatch $searchString }
  } else {
    $SupportedTypes = $config.allowedValues.resourceType
  }
  $SupportedTypes | ConvertTo-Json -Compress -Depth 3
}