#Requires -RunAsAdministrator
<#
.Synopsis
   add mySQL Resource Provider
.DESCRIPTION
   add mySQL Resource Provider
.EXAMPLE
    .\Add-mySQLRP.ps1 -ConfigFile "C:\work\Config.xml"
.EXAMPLE
    .\Add-mySQLRP.ps1 ?
.NOTES
   Auther : S.Hiro
   version: 0.5
#>
[CmdletBinding(DefaultParametersetName="File")]
Param
(
    # Config XML file path
    [Parameter(Mandatory=$True,ParameterSetName='File')]
    [string]$ConfigFile
)
$Error.Clear();
$ErrorActionPreference = 'Stop';

# Variables
#$TEST = "C:\work\Paas\mysql\Prerequisites\BlobStorage\Container"

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
    $WorkFolder = $ConfigXml.AzureStackConfig.WorkPath;
    $AdminPassword = $ConfigXml.AzureStackConfig.deploy.AdminPassword;

    $DLURI = $ConfigXml.AzureStackConfig.ResourceProvider.mySQL.DLURI;
    $ResourceGroupName = $ConfigXml.AzureStackConfig.ResourceProvider.mySQL.ResourceGroupName;
    $VMName = $ConfigXml.AzureStackConfig.ResourceProvider.mySQL.VMName;
    $VMAccount = $ConfigXml.AzureStackConfig.ResourceProvider.mySQL.VMAccount;
    $VMPass = $ConfigXml.AzureStackConfig.ResourceProvider.mySQL.VMPass;

    switch ($DeployType)
    {
        'ADFS'
        {
            $Account = $ConfigXml.AzureStackConfig.deploy.ADAccount;
            $Password = $ConfigXml.AzureStackConfig.deploy.AdminPassword;
        }
        'AAD'
        {
            $AADTenantName = $ConfigXml.AzureStackConfig.deploy.AADTenantName;
            $Account = $ConfigXml.AzureStackConfig.deploy.AADAccount;
            $Password = $ConfigXml.AzureStackConfig.deploy.AADPassword;
        }
        Default
        {
            Write-Warning -Message "Deploy Type Error : $DeployType";
            return;
        }
    }
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
Remove-Module *Azure* 
Install-Module -Name AzureRm.BootStrapper -Force -Confirm:$false;
Use-AzureRmProfile -Profile 2017-03-09-profile -Confirm:$false;
Install-Module -Name AzureStack -RequiredVersion 1.2.9 -AllowClobber -Force -Confirm:$false;

## Download Azure Stack tools
Write-Host "Download Azure Stack tools" -ForegroundColor Green;
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile "$workPath\master.zip" ;
expand-archive "$workPath\master.zip" -DestinationPath $workPath -Force;

## import module
Write-Host "import module" -ForegroundColor Green;
Import-Module $workPath\AzureStack-Tools-master\Connect\AzureStack.Connect.psm1 ;

## Get Tenant GUID
Write-Host "Get AAD Tenant GUID" -ForegroundColor Green;
switch ($DeployType)
{
    'ADFS'
    {
        $HostPass = ConvertTo-SecureString $AdminPassword -AsPlainText -Force;
        $AadTenant = Get-AzureStackAadTenant -HostComputer localhost -Password $HostPass;
    }
    'AAD'
    {
        $aadTenant = Get-AADTenantGUID -AADTenantName $AADTenantName;
    }
}

## Downloading and Expand the mysql package
Write-Host "Downloading and Expand the mysql package" -ForegroundColor Green;
New-Item -Path "$workPath\rps\mysqlrp" -ItemType Directory -Force | Out-Null;
Invoke-WebRequest -Uri $DLURI -OutFile "$workPath\rps\mysqlrp\AzureStack.MySql.zip";
expand-archive "$workPath\rps\mysqlrp\AzureStack.MySql.zip" -DestinationPath "$workPath\rps\mysqlrp\" -Force;

## Create Credential
Write-Host "Create Credential" -ForegroundColor Green;
$Pass = ConvertTo-SecureString $Password -AsPlainText -Force;
$cred = New-Object System.Management.Automation.PSCredential($Account, $Pass);
$VMPass = ConvertTo-SecureString $VMPass -AsPlainText -Force;
$VMcred = New-Object System.Management.Automation.PSCredential($VMAccount, $VMPass);

$param = @{
    'DirectoryTenantID' = $aadTenant;
    'VMLocalCredential' = $VMcred;
    'ResourceGroupName' = $ResourceGroupName;
    'VmName' = $VMName;
    'ArmEndpoint' = "https://adminmanagement.local.azurestack.external";
    'TenantArmEndpoint' = "https://management.local.azurestack.external";
    'AcceptLicense' = $true;
    'SilentInstall' = $true;
}

$param
## DeploySQLProvider
Write-Host "DeploySQLProvider" -ForegroundColor Green;
Set-Location "$workPath\rps\sqlrp"
.\DeployMySQLProvider.ps1 @param -Verbose;
