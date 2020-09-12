<#
.NAME
Add-CentrifyRoleAsgtoComputerRole.ps1
   
.AUTHOR
Oguz Kalfaoglu, RebuiltArchitect© and CentrifyLab©

.DATE 
10/09/2020
   
.SYNOPSIS
The script assign  a role to a Computer Role / Bir servis için oluşturulan rolleri ilgili computer role atar.

.DESCRIPTION
The script assign  a role to a Computer Role / Bir servis için oluşturulan rolleri ilgili computer role atar.

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

Add-CentrifyRoleAsgtoComputerRole  $global:zoneName $global:serviceName $global:serviceRoleName
    
.KEYWORDS
Centrify, Asign role to computer role

#>

function Add-CentrifyRoleAsgtoComputerRole {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$strZone,
        [Parameter(Mandatory = $true)]
        [string]$strServiceName,
        [Parameter(Mandatory = $true)]
        [string]$strServiceRoleName)
    
    try {
        
Import-Module $global:mainFolder\module\Centrify.API.Access.Global.psm1 3>$null

        $strZoneName = $global:zoneName
        $strServiceName = $global:serviceName
        $strServiceRoleName = $global:serviceRoleName

        $strComputerRole = "$strZoneName-$strServiceName-$strServiceRoleName"
        $strServiceGroupName = "cfyU-$strZoneName-$strServiceName-$strServiceRoleName"
        $strLoginGroupName = "cfyU-$strZoneName-$strServiceName-$strServiceRoleName-Login"
        $strServiceGroupNameDN = Get-GroupDN($strServiceGroupName)
        $strLoginGroupNameDN = Get-GroupDN($strLoginGroupName)
        $strServiceRole = "Role-$strZoneName-$strServiceName-$strServiceRoleName"
        $strLoginRole = "Windows Login"

        # Location of the DLLs. By default they are installed at
        # - C:\Program Files\Centrify\Access API for Windows\
        # Please update the path if they are installed somewhere else
        #
        $dllPath = $global:dllPath;

        [System.Reflection.Assembly]::LoadFrom($dllPath + "centrifydc.api.dll");
        [System.Reflection.Assembly]::LoadFrom($dllPath + "util.dll");

        $api = "Centrify.DirectControl.API.{0}";
        $cims = New-Object ($api -f "Cims");


        $strZoneOU = $global:zoneOU
        $strdcservername = $global:dcServerName
        
        $objRootDse = Get-DirectoryEntry("LDAP://$strdcservername/rootDSE");
        $strNc = $objRootDse.psbase.Properties["defaultNamingContext"].Value;
        $strZoneDN = "cn={0},{1},{2}" -f $strZoneName, $strZoneOU, $strNc;

        $objZone = $cims.GetZoneByPath($strZoneDN);

        if ($null -eq $strZoneName) {
            Write-Host("Zone name cannot be empty");
            exit -1;
        }
        if ($null -eq $strComputerRole) {
            Write-Host("Computer role name cannot be empty.");
            exit -1;
        }
        if ($null -eq $objZone) {
            Write-Host("Zone {0} does not exist" -f $strZone);
            exit -1;
        }

        $objComputerRole = $objZone.GetComputerRole($strComputerRole);
        if ($null -eq $objComputerRole) {
            Write-Host("ComputerRole {0} does not exist in zone " -f $strComputerRole);
            exit -1;
        }

        $strGroupsDN = @("$strServiceGroupNameDN", "$strLoginGroupNameDN")
        $strRoles = @("$strServiceRole", "$strLoginRole")

        For ($i = 0; $i -lt $strGroupsDN.Length -eq $strRoles.Length; $i++ ) {

            $strGroupDN = $strGroupsDN[$i]
            $strRole = $strRoles[$i]

            $objRole = $objZone.GetRole($strRole);
            if ($null -eq $objRole) {
                Write-Host("Role {0} does not exist in zone " -f $strRole);
                exit -1;
            }

           # $objAsg = $objComputerRole.GetAccessGroup($strGroupDN);
            $objAsg = $objComputerRole.GetAccessGroup($objRole, $strGroupDN);

            if ($null -eq $objAsg) {

                $objAsg = $objComputerRole.AddAccessGroup($strGroupDN);
                $objAsg.Role = $objRole;
                $objAsg.Commit();
                Write-Host("Role {0} has been assigned to group {1} successfully" -f $strRole, $strGroup);
                # no problem at all

              #  $objAsg = $objComputerRole.AddRoleAssignment();
              #  $objAsg.Role = $objRole;	
              #  $objAsg.AddAccessGroup = $strGroupDN;
              #  $objAsg.TrusteeType = [enum]::parse([type]($api -f "TrusteeDn"), "Group");
               #$objAsg.Commit(); 

                Write-Host("Role {0} is assigned to $strComputerRole ComputerRole successfully." -f $strRole);
            }
            else {
                Write-Host("Role assignment already exist.");
                exit -1;
            }
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "The error message was $ErrorMessage"
    }
     Write-Host "Finished Add-CentrifyRoleAsgtoComputerRole function"
    return $objComputerRole
}