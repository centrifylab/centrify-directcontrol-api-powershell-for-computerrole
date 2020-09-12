<#
.NAME
Add-ComputerToComputerrolegroup.ps1
   
.AUTHOR
Oguz Kalfaoglu, RebuiltArchitect© and CentrifyLab©

.DATE 
10/09/2020
   
.SYNOPSIS
The computer object assign  a member of Computer Role / Bir computer objesi computer role üye olarak eklenir.

.DESCRIPTION
The computer object assign  a member of Computer Role / Bir computer objesi computer role üye olarak eklenir.

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
Centrify, Asign computer object to member of computer role

#>

function Add-ComputerToComputerRole () {
    [CmdletBinding()]
    param (
	    [Parameter(Mandatory = $true)]
        [string]$strZoneName,
        [Parameter(Mandatory = $true)]
        [string]$strServiceName,
        [Parameter(Mandatory = $true)]
        [string]$strServiceRoleName,
        [Parameter(Mandatory = $true)]
        [string]$computerName
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


	    $strZoneName = $global:zoneName
        $strServiceName = $global:serviceName
        $strServiceRoleName = $global:serviceRoleName
        $strComputerRoleGroupName = "cfyC-$strZoneName-$strServiceName-$strServiceRoleName"
        $strParent = $global:zoneOU
        $strdcservername = $global:dcServerName
        $groupdn = Get-GroupDN ($strComputerRoleGroupName)

       
        $isMember = new-object DirectoryServices.DirectorySearcher([ADSI]"")
        $ismember.filter = "(&(objectClass=computer)(sAMAccountName=$computerName$)(memberof=$groupdn))"
        $isMemberResult = $isMember.FindOne()



            if ($null -ne $isMemberResult) {
     Write-Host("Computer {0} already exist in zone {1}" -f $isMemberResult, $groupdn);
            exit -1;
    }

        else {
            $searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
            $searcher.filter = "(&(objectClass=computer)(sAMAccountName= $computerName$))"
            $FoundComputer = $searcher.FindOne()
            $P = $FoundComputer | Select-Object path
            $ComputerPath = $p.path
            $GroupPath = "LDAP://$groupdn"
            $Group = [ADSI]"$GroupPath"
            $Group.Add("$ComputerPath")
            $Group.SetInfo()

            }
       
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "The error message was $ErrorMessage"
    }
    finally {
        # Always remove the Centrify.Cloud.Powershell module, makes development iteration on the module itself easier    
    }
 return $Group
}