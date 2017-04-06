#Requires -RunAsAdministrator
<#
.Synopsis
   set host config
.DESCRIPTION
   Script to configure host 
.EXAMPLE
    .\Set-HostConfig.ps1 -ConfigFile "C:\work\Config.xml"
.EXAMPLE
    .\Set-HostConfig.ps1 -HostName "MASHost"
.NOTES
   Auther : S.Hiro
   version: 0.5
#>
[CmdletBinding(DefaultParametersetName="Manual")]
Param
(
    # Config XML file path
    [Parameter(Mandatory=$True,ParameterSetName='File')]
    [string]$ConfigFile,
    # HostName
    [Parameter(Mandatory=$True,Position=0,ParameterSetName='Manual')]
    [string]$HostName,
    # NIC1
    [Parameter(Mandatory=$false,Position=1,ParameterSetName='Manual')]
    [string]$NIC1 = "eth",
    # NIC2
    [Parameter(Mandatory=$false,Position=2,ParameterSetName='Manual')]
    [string]$NIC10 = "Chelsio"
)
$Error.Clear();
$ErrorActionPreference = 'Stop';

if ($PsCmdlet.ParameterSetName -eq "File")
{
    if (!(Test-Path $ConfigFile))
    {
        Write-Warning -Message "file not found : $ConfigFile";
        return;
    }

    ## load config file
    Write-Host "load config file : $ConfigFile" -ForegroundColor Green;
    [xml]$ConfigXml = Get-Content -Path $ConfigFile -Encoding UTF8;
    $HostName = $ConfigXml.AzureStackConfig.Host.Hostname;
    $NIC1 = $ConfigXml.AzureStackConfig.Host.NIC1;
    $NIC10 = $ConfigXml.AzureStackConfig.Host.NIC10;
}


## Set nic name
Write-Host "Set nic name" -ForegroundColor Green;
$AdapterList1G = @(Get-NetAdapter | Where-Object {$_.InterfaceDescription -match $NIC1 } | Select-Object MacAddress,Name,InterfaceDescription|Sort-Object MacAddress);
for ($i = 0; $i -lt $AdapterList1G.Count; $i++)
{ 
    $AdapterList1G[$i] | Rename-NetAdapter -NewName ("Eth0{0}" -f ($i+1));
    Write-Verbose -Message (" Change network adapoter Name : {0}" -f ("Eth0{0}" -f ($i+1)));
    
}
$AdapterList10G = @(Get-NetAdapter | Where-Object {$_.InterfaceDescription -match $NIC10 } | Select-Object MacAddress,Name,InterfaceDescription|Sort-Object MacAddress);
for ($i = 0; $i -lt $AdapterList10G.Count; $i++)
{ 
    $AdapterList10G[$i] | Rename-NetAdapter -NewName ("Eth1{0}" -f ($i+1));
    Write-Verbose -Message (" Change network adapoter Name : {0}" -f ("Eth1{0}" -f ($i+1)));
}
## Disable nic
Write-Host "Disable nic" -ForegroundColor Green;
Get-NetAdapter | Where-Object {$_.Name -notmatch 'Eth01' } | Disable-NetAdapter -Confirm:$false
#Get-NetAdapter | Select-Object Name,Status,MacAddress,InterfaceDescription|Sort-Object Name

## Add windows feature
Write-Host "Add windows feature" -ForegroundColor Green;
Get-WindowsFeature "SNMP-Service" | Add-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools

## rename computer
Write-Host "rename computer" -ForegroundColor Green;
Rename-Computer -NewName $HostName -Restart

