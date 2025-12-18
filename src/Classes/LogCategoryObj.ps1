class LogCategoryObj {
    # Class properties
    [string] $SourceType = ""
    [string] $ContainerId = ""
    [string] $ResourceTypeName = ""
    [array] $LogCategory = @()
    [array] $MetricCategory = @()


    # ------------------------------
    # Input Validation
    # ------------------------------

    # Static method to validate the input parameters
    static [void] Validate([string]$ContainerId, [string]$ResourceTypeName, [string]$SourceType) {
        $errors = @()
        # Basic validation for null or empty strings
        if ([string]::IsNullOrEmpty($SourceType)) {
            $errors += "SourceType cannot be null or empty"
        }
        if ([string]::IsNullOrEmpty($ContainerId)) {
            $errors += "ContainerId cannot be null or empty"
        }
        if ([string]::IsNullOrEmpty($ResourceTypeName)) {
            $errors += "ResourceTypeName cannot be null or empty"
        }

        # Additional validation for SourceType 'Az'
        # to ensure that ContainerId is a valid GUID
        if ($SourceType -eq 'Az') {
            $guid = New-Object Guid
            if (-not [Guid]::TryParse($ContainerId, [ref]$guid)) {
                $errors += "ContainerId must be a valid GUID when SourceType is 'Az'"
            }
        }

        # Throw an exception if there are any errors
        if ($errors.Count -gt 0) {
            throw ($errors -join "`n")
        }
    }

    # ------------------------------
    # Constructors
    # ------------------------------

    # Default constructor
    LogCategoryObj() {
        # There's no need to reinitialize LogCategory and MetricCategory in this constructor
        # as they are already initialized when the class properties are declared.
        # Typically, a constructor is used for any logic that needs to be executed during object creation.
        # However, for these properties, such logic is not applicable.
    }

    # Convenience constructor from hashtable
    LogCategoryObj([hashtable]$Properties) {
        [LogCategoryObj]::Validate($Properties.ContainerId, $Properties.ResourceTypeName, $Properties.SourceType)
        $this.Init($Properties)
        $this.GetDiagnosticSettings()
    }

    # Common constructor for separate properties
    LogCategoryObj([string]$ContainerId, [string]$ResourceTypeName, [string]$SourceType) {
        [LogCategoryObj]::Validate($ContainerId, $ResourceTypeName, $SourceType)
        $this.ContainerId = $ContainerId
        $this.ResourceTypeName = $ResourceTypeName
        $this.SourceType = $SourceType
        $this.GetDiagnosticSettings()
    }

    # ------------------------------
    # Methods
    # ------------------------------

    # Hashtable parser that initializes matching object properties
    [void] Init([hashtable]$Properties) {
        foreach ($key in $Properties.Keys) {
            if ($this.psobject.properties.Match($key).Count -gt 0) {
                $this.$key = $Properties[$key]
            }
        }
    }

    # Method to get diagnostic settings
    [void] GetDiagnosticSettings() {
        $resource = Get-AzResource -ResourceType $this.ResourceTypeName | Select-Object -First 1

        $diagnosticSettings = $null

        try {
            $diagnosticSettings = (Get-AzDiagnosticSettingCategory -ResourceId $resource.ResourceId -ErrorAction SilentlyContinue) | Select-Object Name, CategoryType
        }
        catch {
            $diagnosticSettings = $null
        }

        if ($diagnosticSettings) {

            $diagnosticSettings | ForEach-Object {
                if ($_.CategoryType -eq 'Logs') {
                    $this.LogCategory += $_.Name
                }
                elseif ($_.CategoryType -eq 'Metrics') {
                    $this.MetricCategory += $_.Name
                }
            }
        }
        else {
            $this.LogCategory = @()
            $this.MetricCategory = @()
        }
    }

    # Method to return a string representation of the resource
    [string] ToString() {
        return "Resource Type: $($this.ResourceTypeName) in ContainerId: $($this.ContainerId) from Source: $($this.SourceType)"
    }
}