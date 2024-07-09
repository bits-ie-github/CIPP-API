function Invoke-CIPPStandardintuneRequireMFA {
    <#
    .FUNCTIONALITY
    Internal
    .APINAME
    intuneRequireMFA
    .CAT
    Intune Standards
    .TAG
    "mediumimpact"
    .HELPTEXT
    Requires MFA for all users to register devices with Intune. This is useful when not using Conditional Access.
    .LABEL
    Require Multifactor Authentication to register or join devices with Microsoft Entra
    .IMPACT
    Medium Impact
    .POWERSHELLEQUIVALENT
    Update-MgBetaPolicyDeviceRegistrationPolicy
    .RECOMMENDEDBY
    .DOCSDESCRIPTION
    Requires MFA for all users to register devices with Intune. This is useful when not using Conditional Access.
    .UPDATECOMMENTBLOCK
    Run the Tools\Update-StandardsComments.ps1 script to update this comment block
    #>




    param($Tenant, $Settings)
    $PreviousSetting = New-GraphGetRequest -uri 'https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy' -tenantid $Tenant

    If ($Settings.remediate -eq $true) {
        if ($PreviousSetting.multiFactorAuthConfiguration -eq 'required') {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Require to use MFA when joining/registering Entra Devices is already enabled.' -sev Info
        } else {
            try {
                $NewSetting = $PreviousSetting
                $NewSetting.multiFactorAuthConfiguration = 'required'
                $Newbody = ConvertTo-Json -Compress -InputObject $NewSetting
                New-GraphPostRequest -tenantid $tenant -Uri 'https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy' -Type PUT -Body $NewBody -ContentType 'application/json'
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Set required to use MFA when joining/registering Entra Devices' -sev Info
            } catch {
                $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
                Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to set require to use MFA when joining/registering Entra Devices: $ErrorMessage" -sev Error
            }
        }
    }

    if ($Settings.alert -eq $true) {

        if ($PreviousSetting.multiFactorAuthConfiguration -eq 'required') {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Require to use MFA when joining/registering Entra Devices is enabled.' -sev Info
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Require to use MFA when joining/registering Entra Devices is not enabled.' -sev Alert
        }
    }

    if ($Settings.report -eq $true) {
        $RequireMFA = if ($PreviousSetting.multiFactorAuthConfiguration -eq 'required') { $true } else { $false }
        Add-CIPPBPAField -FieldName 'intuneRequireMFA' -FieldValue $RequireMFA -StoreAs bool -Tenant $tenant
    }
}




