Write-Host "run-all is start..."

#Input for Centrify Scipts
$global:zoneName = "Windows"
$global:serviceName= "Canakkalec1c"
$global:serviceRoleName = "Production"
$global:computerName = "AD01W19"

# Config for Centrify Script
$global:usrname = "wuser01";
$global:passwd = "24Qwert12";
$global:mainFolder= "C:\GitHub\centrify-directcontrol-api-powershell-for-computerrole"
$global:dcServerName = "ad01w19.centrify.lab.tr"
$global:dllPath= "C:\Program Files\Centrify\Access API for Windows\"
$global:zoneCn= "centrify.lab.tr/Centrify/Windows/Zones/Windows"
$global:zoneOU= "CN=Zones,OU=Windows,OU=Centrify"
$global:computerRolesOU= "OU=Computer Roles,OU=Windows,OU=Centrify,DC=centrify,DC=lab,DC=tr"
$global:userRolesOU= "OU=User Roles,OU=Windows,OU=Centrify,DC=centrify,DC=lab,DC=tr"



Write-Host "The functions is imported..."

Import-Module $global:mainFolder\module\Centrify.API.Access.Global.psm1 3>$null

# Import function definitions
. .\function\Add-Adgroup.ps1
. .\function\Add-CentrifyComputerRole.ps1
. .\function\Add-CentrifyRole.ps1
. .\function\Add-CentrifyRoleAsgtoComputerRole.ps1
. .\function\Add-ComputerToComputerRole.ps1

try {
     Add-Adgroup  $global:zoneName $global:serviceName $global:serviceRoleName
     Add-CentrifyComputerRole  $global:zoneName $global:serviceName $global:serviceRoleName
     Add-CentrifyRole  $global:zoneName $global:serviceName $global:serviceRoleName 
     Add-CentrifyRoleAsgtoComputerRole  $global:zoneName $global:serviceName $global:serviceRoleName
     Add-ComputerToComputerRole  $global:zoneName $global:serviceName $global:serviceRoleName $global:computerName
}
catch {
      Write-Error "Unexpected error during setup: $($_.Exception)"

}
finally {
      # Always remove the Centrify.Cloud.Powershell module, makes development iteration on the module itself easier
      Remove-Module Centrify.API.Access.Global 4>$null
      Write-Host "run-all script is finish..."
}
