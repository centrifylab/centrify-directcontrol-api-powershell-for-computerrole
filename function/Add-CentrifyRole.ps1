<#
.NAME
add-computerrole.ps1
   
.AUTHOR
Oguz Kalfaoglu, RebuiltArchitect© and CentrifyLab©

.DATE 
10/09/2020
   
.SYNOPSIS
The script create a role defination on the Access Manager / Access Manager üzerinde role defination oluşturur.

.DESCRIPTION
The script create a role defination on the Access Manager / Access Manager üzerinde role defination oluşturur.

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

Add-CentrifyRole  $global:zoneName $global:serviceName $global:serviceRoleName 


.OUTPUTS
Description of objects that are output by the script.

Role-[ZoneName]-[ServiceName]-[ServiceRoleName]
    
.KEYWORDS
Centrify, Add Centrify Role Defination

#>

function Add-CentrifyRole {
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
    $strRole = "Role-$strZoneName-$strServiceName-$strServiceRoleName";
    $strZoneOU = $global:zoneOU
    $strdcservername = $global:dcServerName

    if ($null -eq $strZoneName) {
        Write-Host("Zone OU name cannot be empty.");
        exit -1;
    }
    elseif ($null -eq $strServiceName) {
        Write-Host("Zone name cannot be empty.");
        exit -1;
    }
    elseif ($null -eq $strServiceRoleName) {
        Write-Host("Service role name cannot be empty.");
        exit -1;
    }

    $api = "Centrify.DirectControl.API.{0}";
    $cims = New-Object ($api -f "Cims");

    $objRootDse = Get-DirectoryEntry("LDAP://$strdcservername/rootDSE");
    $strNc = $objRootDse.psbase.Properties["defaultNamingContext"].Value;
    $strZoneDN = "cn={0},{1},{2}" -f $strZoneName, $strZoneOU, $strNc;

    $objZone = $cims.GetZoneByPath($strZoneDN);


    if ($null -eq $objZone) {
        Write-Host("Zone {0} does not exist " -f $strZoneDN);
        exit -1;
    }
    else {
        $objRole = $objZone.GetRole($strRole);
        if ($null -ne $objRole) {
            Write-Host("Role {0} already exist in zone {1}" -f $strRole, $strZoneName);
            exit -1;
        }
    else {
            $objRole = $objZone.CreateRole($strRole);
            $objRole.Description = "optional description";
            $objRole.Commit();      
            Write-Host("Role {0} has been added to zone successfully" -f $strRole);      
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
    return $objRole
}