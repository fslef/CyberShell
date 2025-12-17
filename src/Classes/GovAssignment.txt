class GovAssignment {
    # Class properties
    [string] $CsEnvironment = ""
    [string] $SourceType = ""
    [string] $AssessmentName = ""
    [string] $AssessmentDisplayName = ""
    [string] $AssignedResourceId = ""
    [string] $ContainerId = ""
    [string] $AssignmentKey = ""
    [datetime] $RemediationDueDate
    [bool] $IsGracePeriod = $false
    [string] $Owner = ""
    [bool] $OwnerEmailNotification = $false
    [bool] $ManagerEmailNotification = $false
    [string] $NotificationDayOfWeek = ""

    # Input Validation
    static [void] Validate(
        [string]$CsEnvironment, [string]$SourceType, [string]$AssessmentName, [string]$AssignedResourceId,
        [string]$ContainerId, [string]$AssignmentKey, [datetime]$RemediationDueDate, [bool]$IsGracePeriod,
        [string]$Owner, [bool]$OwnerEmailNotification, [bool]$ManagerEmailNotification, [string]$NotificationDayOfWeek) {
        $errors = @()
        if ([string]::IsNullOrEmpty($CsEnvironment)) { $errors += "CsEnvironment cannot be null or empty" }
        if ([string]::IsNullOrEmpty($SourceType)) { $errors += "SourceType cannot be null or empty" }
        if ([string]::IsNullOrEmpty($AssessmentName)) { $errors += "AssessmentName cannot be null or empty" }
        if ([string]::IsNullOrEmpty($AssignedResourceId)) { $errors += "AssignedResourceId cannot be null or empty" }
        if ([string]::IsNullOrEmpty($ContainerId)) { $errors += "ContainerId cannot be null or empty" }
        if ([string]::IsNullOrEmpty($AssignmentKey)) { $errors += "AssignmentKey cannot be null or empty" }


        if ($errors.Count -gt 0) {
            throw ($errors -join "`n")
        }
    }

    # Constructors

    # Default constructor
    GovAssignment() {
        # Logic for initializing the object, if necessary, beyond the default property values.
    }

    # Convenience constructor from hashtable
    GovAssignment([hashtable]$Properties) {
        [GovAssignment]::Validate($Properties.CsEnvironment, $Properties.SourceType, $Properties.AssessmentName,
        $Properties.AssignedResourceId, $Properties.ContainerId, $Properties.AssignmentKey, $Properties.RemediationDueDate,
        $Properties.IsGracePeriod, $Properties.Owner, $Properties.OwnerEmailNotification, $Properties.ManagerEmailNotification,
        $Properties.NotificationDayOfWeek)

        $this.Init($Properties)
        $this.GetAssignmentDetails()
    }

    # Common constructor for separate properties
    GovAssignment([string]$CsEnvironment, [string]$SourceType, [string]$AssessmentName, [string]$AssignedResourceId,
    [string]$ContainerId, [string]$AssignmentKey, [datetime]$RemediationDueDate, [bool]$IsGracePeriod, [string]$Owner,
    [bool]$OwnerEmailNotification, [bool]$ManagerEmailNotification, [string]$NotificationDayOfWeek) {
        [GovAssignment]::Validate($CsEnvironment, $SourceType, $AssignedResourceId, $ContainerId, $AssignmentKey)
        $this.CsEnvironment = $CsEnvironment
        $this.SourceType = $SourceType
        $this.AssignedResourceId = $AssignedResourceId
        $this.ContainerId = $ContainerId
        $this.AssignmentKey = $AssignmentKey
        $this.GetAssignmentDetails()
    }

    # Methods

    [void] Init([hashtable]$Properties) {
        foreach ($key in $Properties.Keys) {
            if ($this.psobject.properties.Match($key).Count -gt 0) {
                $this.$key = $Properties[$key]
            }
        }
    }


    [string] ToString() {
        return "Assessment: $($this.AssessmentDisplayName) with Key: $($this.AssignmentKey) for Resource: $($this.AssignedResourceId) in Environment: $($this.CsEnvironment)"
    }
}
