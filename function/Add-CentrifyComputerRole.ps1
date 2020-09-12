<#
.NAME
add-computerrole.ps1
   
.AUTHOR
Oguz Kalfaoglu, RebuiltArchitect© and CentrifyLab©

.DATE 
10/09/2020
   
.SYNOPSIS
Bu function computer role oluşturur.

.DESCRIPTION
Bu function computer role oluşturur.

.PARAMETER ZoneName
Centrify Zone Name (for example: Windows) / Centrify Zone Adı (Örn: Windows)

.PARAMETER ServiceName
Centrify'a eklenecek servis adı veya uygulama adı (Örn: SAP)

.PARAMETER ServiceRoleName
Servis veya uygulamanın rolü adıdır. (Örn: HR modülü)


.INPUTS
Description of objects that can be piped to the script.

.SAMPLES
Example of how to run the script.

Add-CentrifyComputerRole  $global:zoneName $global:serviceName $global:serviceRoleName

.OUTPUTS

Description of objects that are output by the script.

Computer Group Rule for AD Group: 
cfyC-[ZoneName]-[ServiceName]-[ServiceRoleName]

    
.KEYWORDS
Centrify, Add Centrify Computer Role

#>

function Add-CentrifyComputerRole {
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
Import-Module $global:mainFolder\module\Centrify.API.Access.Global.psm1 3>$null
        # Location of the DLLs. By default they are installed at
        # - C:\Program Files\Centrify\Access API for Windows\
        # Please update the path if they are installed somewhere else
        #
        $dllPath = $global:dllPath;

        [System.Reflection.Assembly]::LoadFrom($dllPath + "centrifydc.api.dll");
        [System.Reflection.Assembly]::LoadFrom($dllPath + "util.dll");

        $strZoneName = $global:zoneName
        $strServiceName = $global:serviceName
        $strServiceRoleName = $global:serviceRoleName
        $strComputerRole = "$strZoneName-$strServiceName-$strServiceRoleName"
        $strParent = $global:zoneOU
        $strdcservername = $global:dcServerName

    
        $api = "Centrify.DirectControl.API.{0}";
        $cims = New-Object ($api -f "Cims");

        $objRootDse = Get-DirectoryEntry("LDAP://$strdcservername/rootDSE");
        $strNc = $objRootDse.psbase.Properties["defaultNamingContext"].Value;
        $strZoneDN = "cn={0},{1},{2}" -f $strZoneName, $strParent, $strNc;

        $objZone = $cims.GetZoneByPath($strZoneDN);

        if ($null -eq $objZone) {
            Write-Host("Zone {0} does not exist " -f $strZoneDN);
            exit -1;
        }
        else {
            $objComputerRole = $objZone.GetComputerRole($strComputerRole);
            if ($null -ne $objComputerRole) {
                Write-Host("ComputerRole {0} does not exist in zone " -f $strComputerRole);
            }
        else {
                $ADDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
                $strGroup = "cfyC-$strComputerRole@$ADDomain"

                $objComputerRole = $objzone.AddComputerRole($strComputerRole);
                $objComputerRole.Group = $strGroup;
                $objComputerRole.Validate();
                $objComputerRole.Commit();
                Write-Output ("Computer role  $strComputerRole is created successfully.");     
            }
        }
 }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "The error message was $ErrorMessage"
    }
    finally {
        # Always remove the Centrify.Cloud.Powershell module, makes development iteration on the module itself easier    
    }
    return $objComputerRole
}