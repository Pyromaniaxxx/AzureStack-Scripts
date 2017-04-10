#Requires -RunAsAdministrator
<#
.Synopsis
   add WS2016 VM image to marketplace
.DESCRIPTION
   Add the Windows Server 2016 VM image to the Azure Stack marketplace
.EXAMPLE
    .\Deploy-MAS.ps1 -ConfigFile "C:\work\Config.xml"
.EXAMPLE
    .\Deploy-MAS.ps1 -DeployType "AAD"
.NOTES
   Auther : S.Hiro
   version: 0.5
#>
[CmdletBinding(DefaultParametersetName="File")]
Param
(
    # Config XML file path
    [Parameter(Mandatory=$True,ParameterSetName='File')]
    [string]$ConfigFile,

    # deploy dype
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='ADFS')]
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='AAD')]
    [ValidateSet('ADFS','AAD')]
    [string]$DeployType = 'ADFS',

    # iso path
    [Parameter(Mandatory=$true,ParameterSetName='ADFS')]
    [Parameter(Mandatory=$true,ParameterSetName='AAD')]
    [string]$ISOPath ,

    # password
    [Parameter(Mandatory=$true,ParameterSetName='ADFS')]
    [Parameter(Mandatory=$true,ParameterSetName='AAD')]
    [string]$Password ,

    # ADAccount | MASAdmin@%AADTenant%.onmicrosoft.com
    [Parameter(Mandatory=$true,ParameterSetName='AAD')]
    [string]$AADAccount ,

    # AADTenant | %AADTenant%.onmicrosoft.com
    [Parameter(Mandatory=$true,ParameterSetName='AAD')]
    [string]$AADTenantName ,

    # AADTenant
    [Parameter(Mandatory=$false,ParameterSetName='ADFS')]
    [string]$ADAccount = "azurestack\azurestackadmin",
    # work folder
    [Parameter(Mandatory=$true,ParameterSetName='ADFS')]
    [Parameter(Mandatory=$true,ParameterSetName='AAD')]
    [string]$WorkFolder = 'work'
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
    $DeployType = $ConfigXml.AzureStackConfig.deploy.deployType;
    $ISOPath = $ConfigXml.AzureStackConfig.PIR.WS2016DC.ISOPath;
    $Password = $ConfigXml.AzureStackConfig.deploy.AdminPassword;

    $WorkFolder = $ConfigXml.AzureStackConfig.WorkPath;

    $AADTenantName = $ConfigXml.AzureStackConfig.deploy.AADTenantName;
    $AADAccount = $ConfigXml.AzureStackConfig.deploy.AADAccount;
    $AADPassword = $ConfigXml.AzureStackConfig.deploy.AADPassword;
}

## inisialize

## check ISO file path
Write-Host "check ISO file path : $ISOPath" -ForegroundColor Green;
if (!(Test-Path $ISOPath))
{
    Write-Warning -Message "ISOPath of the not exists. $ISOPath";
    return;
}


if(Test-Path "C:\CloudDeployment")
{
    $workPath = Join-Path "D:\" $WorkFolder;
}
else
{
    $workPath = Join-Path "C:\" $WorkFolder;
}


## install Azure Stack PowerShell
Write-Host "install Azure Stack PowerShell" -ForegroundColor Green;
#Get-PSRepository
Install-Module -Name AzureRm.BootStrapper -Force -Confirm:$false;
Use-AzureRmProfile -Profile 2017-03-09-profile;
Install-Module -Name AzureStack -RequiredVersion 1.2.9 -Force -Confirm:$false;
Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Format-Table;


## Download Azure Stack tools
Write-Host "Download Azure Stack tools" -ForegroundColor Green;
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile "$workPath\master.zip" ;
expand-archive "$workPath\master.zip" -DestinationPath $workPath -Force;

## import module
Write-Host "import module" -ForegroundColor Green;
Import-Module $workPath\AzureStack-Tools-master\Connect\AzureStack.Connect.psm1 -Force ;
Import-Module $workPath\AzureStack-Tools-master\ComputeAdmin\AzureStack.ComputeAdmin.psm1 -Force;

## create param
Write-Host "create param" -ForegroundColor Green;
switch ($DeployType)
{
    'ADFS' 
    {
        $Pass = ConvertTo-SecureString $Password -AsPlainText -Force;
        $aadcred = New-Object System.Management.Automation.PSCredential ($ADAccount, $Pass);
        $AadTenant = Get-AzureStackAadTenant -HostComputer localhost -Password $Pass;
    }
    'AAD' 
    {
        $aadTenant = Get-AADTenantGUID -AADTenantName $AADTenantName;
        $aadpass = ConvertTo-SecureString $AADPassword -AsPlainText -Force;
        $aadcred = New-Object System.Management.Automation.PSCredential ($AADAccount, $aadpass);
    }
    Default 
    {
        Write-Warning -Message "param error : $DeployType";
    }
}
## New-Server2016VMImage
Write-Host "New-Server2016VMImage" -ForegroundColor Green;
Add-AzureStackAzureRmEnvironment -Name "AzureStackAdmin" -ArmEndpoint "https://adminmanagement.local.azurestack.external" 
New-Server2016VMImage -ISOPath $ISOPath -TenantId $aadTenant -AzureStackCredentials $aadcred -EnvironmentName "AzureStackAdmin"; 
