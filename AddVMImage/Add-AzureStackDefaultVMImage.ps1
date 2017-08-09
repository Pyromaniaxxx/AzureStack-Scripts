#Requires -RunAsAdministrator
#Requires -version 5
<#
.Synopsis
   add WS2016 VM image to marketplace
.DESCRIPTION
   Add the Windows Server 2016 VM image to the Azure Stack marketplace
.EXAMPLE
    .\Add-AzureStackDefaultVMImage.ps1 -ConfigFile "D:\work\Config.xml"
.NOTES
   Auther : S.Hiro
#>
[CmdletBinding()]
Param
(
    # Config XML file path
    [Parameter(Mandatory=$True)]
    [string]$ConfigFile
)
$Error.Clear();
$ErrorActionPreference = 'Stop';
$ScriptName = $MyInvocation.MyCommand.Name;

# Import module
Import-Module ..\Common\common.psm1 -Force ;

# Get Config XML File
$ConfigXml = Get-ConfigXML -Path $ConfigFile;
$workPath = Join-Path "D:\" $ConfigXml.AzureStackConfig.WorkPath ;
$ISOPath = $ConfigXml.AzureStackConfig.PIR.WS2016DC.ISOPath;

## check ISO file path
Write-Log -ScriptName $ScriptName -Message "check ISO file path : $ISOPath" -Type Infomation ;  
if (!(Test-Path $ISOPath))
{
    Write-Log -ScriptName $ScriptName -Message "ISOPath of the not exists. $ISOPath" -Type Error ;
    return;
}

## install Azure Stack PowerShell
Install-AzureStackPowerShell ;

## Download Azure Stack tools
Get-AzureStackTools -DLPath $workPath -Verbose ;

## import module
Write-Log -ScriptName $ScriptName -Message "import module" -Type Infomation ;  
Import-Module $workPath\AzureStack-Tools-master\Connect\AzureStack.Connect.psm1 -Force -Verbose;
Import-Module $workPath\AzureStack-Tools-master\ComputeAdmin\AzureStack.ComputeAdmin.psm1 -Force -Verbose;

## Get Tenant GUID
Write-Log -ScriptName $ScriptName -Message "Get AAD Tenant GUID" -Type Infomation ;  
switch ($ConfigXml.AzureStackConfig.deploy.deployType)
{
    'ADFS'
    {
        # Credential
        $MASAccount = "azurestack\azurestackadmin";
        $MASPassword = $ConfigXml.AzureStackConfig.deploy.AdminPassword;
        # Tenant ID
        Add-AzureRMEnvironment -Name 'AzureStackAdmin' -ArmEndpoint "https://adminmanagement.local.azurestack.external" ;
        $tenantID = Get-AzsDirectoryTenantID -ADFS -EnvironmentName AzureStackAdmin ;
    }
    'AAD'
    {
        # Credential
        $AADTenantName = $ConfigXml.AzureStackConfig.deploy.AADTenantName;
        $MASAccount = $ConfigXml.AzureStackConfig.deploy.AADAccount;
        $MASPassword = $ConfigXml.AzureStackConfig.deploy.AADPassword;
        # Tenant ID
        Add-AzureRMEnvironment -Name 'AzureStackAdmin' -ArmEndpoint "https://adminmanagement.local.azurestack.external" ;
        $TenantID = Get-AzsDirectoryTenantId -AADTenantName $AADTenantName -EnvironmentName 'AzureStackAdmin' ;
    }
}

## Connect AzureStack
Write-Log -ScriptName $ScriptName -Message "Connect AzureStack" -Type Infomation ;  
Add-AzureRMEnvironment -Name 'AzureStackAdmin' -ArmEndpoint "https://adminmanagement.local.azurestack.external" ;
#$TenantID = Get-AzsDirectoryTenantId -AADTenantName $AADTenantName -EnvironmentName 'AzureStackAdmin' ;
#sConnect-AzureStack -AADAccount $AADAccount -AADPassword (ConvertTo-SecureString $AADPassword -AsPlainText -Force) -TenantID $TenantID -PortalType AzureStackAdmin -Verbose ;
Connect-AzureStack -AADAccount $MASAccount -AADPassword (ConvertTo-SecureString $MASPassword -AsPlainText -Force) -TenantID $TenantID -PortalType AzureStackAdmin -Verbose ;

## New-Server2016VMImage
Write-Log -ScriptName $ScriptName -Message "exec New-Server2016VMImage" -Type Infomation ;  
New-AzsServer2016VMImage -ISOPath $ISOPath -Verbose;

Write-Log -ScriptName $ScriptName -Message "Process complete !" -Type Infomation ;  
