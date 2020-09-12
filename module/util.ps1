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

    $usrname =  $global:usrname;
    $passwd =   $global:passwd;
    $authType = [System.DirectoryServices.AuthenticationTypes]::Secure -bor [System.DirectoryServices.AuthenticationTypes]::Sealing;

    $entry = New-Object System.DirectoryServices.DirectoryEntry $Path, $usrname, $passwd, $authType;
    return $entry;
}
