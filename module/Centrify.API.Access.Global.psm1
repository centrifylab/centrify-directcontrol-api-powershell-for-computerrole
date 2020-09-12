# Centrify DirectControl SDK Sample Code
# Use of this example permitted only with
# current Centrify DirectControl SDK license
# Copyright 2019 Centrify Corporation www.centrify.com
# ------------------

function Get-DirectoryEntry
{
    Param(
    [Parameter(Position=0, Mandatory=$true)]
    [String]$Path
    )

    $usrname = $global:usrname;
    $passwd =  $global:passwd;
    $authType = [System.DirectoryServices.AuthenticationTypes]::Secure -bor [System.DirectoryServices.AuthenticationTypes]::Sealing;

    $entry = New-Object System.DirectoryServices.DirectoryEntry $Path, $usrname, $passwd, $authType;
    return $entry;
}

Function New-Group {
    param(
        [Parameter(mandatory = $true)]
        [string]$Name,
        [Parameter(mandatory = $true)]
        [string]$ParentContainer,   
        [ValidateSet("Universal", "Global", "DomainLocal")]
        [string]$GroupScope = "Global",
        [ValidateSet("Security", "Distribution")]
        [string]$GroupType = "Security",
        [string]$Description
    )    
    switch ($GroupScope) {
        "Global"
        { $GroupTypeAttr = 2 }
        "DomainLocal"
        { $GroupTypeAttr = 4 }
        "Universal"
        { $GroupTypeAttr = 8 }
    }

    # modify group type attribute if the group is security enabled
    if ($GroupType -eq "Security")
    { $GroupTypeAttr = $GroupTypeAttr -bor 0x80000000 }
    $strdcservername = $global:dcServerName
    $Parent = [adsi]"LDAP://$strdcservername/$ParentContainer"
    $group = $Parent.Create("group", "CN=$Name")
    $null = $group.put("sAMAccountname", $Name)
    $null = $group.put("grouptype", $GroupTypeAttr)
    
    if ($Description)
    { $null = $group.put("description", $Description) } 
    
    $null = $group.SetInfo()   
}

function Get-GroupDN {
    param(
        [string]$Name
    )
    try {
        $DomainDN = ([adsi]'').distinguishedName
        $objDomain = New-Object System.DirectoryServices.DirectoryEntry
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.SearchRoot = $objDomain
        $objSearcher.Filter = "(&(objectcategory=group)(cn=$Name))"
        $objSearcher.SearchScope = "SubTree"
        $colResults = $objSearcher.Findall()

        foreach ($objResult in $colResults) {
            # $objItem = $objResult.Properties
            $distinguishedName = $objResult.Properties.Item("distinguishedName")
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "The error message was $ErrorMessage"
    }
    finally {
        # Always remove the Centrify.Cloud.Powershell module, makes development iteration on the module itself easier    
    }
    return $distinguishedName

}

function Get-FQDN () {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )
    
    try {
        $FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName
    }
    catch {
        $FQDN = "$ComputerName not found"
    }
    return $FQDN
}

Function Get-ADInfo {
    $ADDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    $ADDomainName = $ADDomain.Name
    $Results = New-Object Psobject
    $Results | Add-Member Noteproperty Domain $ADDomainName
    return $ADDomainName
}

Export-ModuleMember -function  New-Group
Export-ModuleMember -function  Get-ADInfo
Export-ModuleMember -function  Get-FQDN
Export-ModuleMember -function  Get-GroupDN