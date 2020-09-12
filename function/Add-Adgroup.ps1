<#
.NAME
add-adgroup.ps1
   
.AUTHOR
Oguz Kalfaoglu, RebuiltArchitect© and CentrifyLab©

.DATE 
10/09/2020
   
.SYNOPSIS
The script create security groups in the Active Directory / Active Directory'de Security Grup Oluşturur.

.DESCRIPTION
Bu script Computer Role ve Role tanımlarının eşleştirilmesinde kullanılacak security grupları active directoryde oluşturur.

.INPUTS
Description of objects that can be piped to the script.

.PARAMETER ZoneName
Centrify Zone Name (for example: Windows) / Centrify Zone Adı (Örn: Windows)

.PARAMETER ServiceName
Centrify'a eklenecek servis adı veya uygulama adı (Örn: SAP)

.PARAMETER ServiceRoleName
Servis veya uygulamanın rolü adıdır. (Örn: HR modülü)

.SAMPLE
Example of how to run the script.

Add-Adgroup  $global:zoneName $global:serviceName $global:serviceRoleName


.OUTPUTS
Description of objects that are output by the script.

Computer Group Rule for AD Group: 
cfyC-[ZoneName]-[ServiceName]-[ServiceRoleName]

Login Role Rule for AD Group:
cfyU-[ZoneName]-[ServiceName]-[ServiceRoleName]-Login

Service Role Rule for AD Group:
cfyU-[ZoneName]-[ServiceName]-[ServiceRoleName]
    
.KEYWORDS
Centrify, Add Security Group

#>

function Add-Adgroup () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$strZoneName,
        [Parameter(Mandatory = $true)]
        [string]$strServiceName,
        [Parameter(Mandatory = $true)]
        [string]$strServiceRoleName
    )

    try {   
        $strZoneName = $global:zoneName
        $strServiceName = $global:serviceName
        $strServiceRoleName = $global:serviceRoleName
        $strComputerRolesOU = $global:computerRolesOU
        $strUserRoleOU1 = $global:userRolesOU
        $strUserRoleOU2 = $global:userRolesOU

        $strComputerRoleGroupName = "cfyC-$strZoneName-$strServiceName-$strServiceRoleName"
        $strLoginGroupName = "cfyU-$strZoneName-$strServiceName-$strServiceRoleName-Login"
        $strServiceRoleGroupName = "cfyU-$strZoneName-$strServiceName-$strServiceRoleName"  

        $objGroupName = @("$strComputerRoleGroupName", "$strLoginGroupName", "$strServiceRoleGroupName")
        $objOrganizationalUnitDN = @("$strComputerRolesOU", "$strUserRoleOU1", "$strUserRoleOU2")

        For ($i = 0; $i -lt $objGroupName.Length -eq $objOrganizationalUnitDN.Length; $i++ ) {
            $strGroupName = $objGroupName[$i]
            $strOrganizationalUnitDN = $objOrganizationalUnitDN[$i]
            New-Group $strGroupName $strOrganizationalUnitDN
            Write-Output "Group $strGroupName did not exist it has now been been created under the $strOrganizationalUnitDN OU."
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "The error message was $ErrorMessage"
    }
    finally {
        # Always remove the Centrify.Cloud.Powershell module, makes development iteration on the module itself easier    
    }
}