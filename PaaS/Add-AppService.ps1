#Requires -RunAsAdministrator
<#
.Synopsis
   add AppService Resource Provider
.DESCRIPTION
   add AppService Resource Provider
.EXAMPLE
    .\Add-AppService.ps1 -ConfigFile "C:\work\Config.xml"
.EXAMPLE
    .\Add-AppService.ps1 ?
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

    $DLURIInstaller = $ConfigXml.AzureStackConfig.ResourceProvider.AppService.DLURIInstaller;
    $DLURIHelper = $ConfigXml.AzureStackConfig.ResourceProvider.AppService.DLURIHelper;
    $pfxPassword = $ConfigXml.AzureStackConfig.ResourceProvider.AppService.pfxPassword;
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
#Remove-Module *Azure* 
#Install-Module -Name AzureRm.BootStrapper -Force -Confirm:$false;
#Use-AzureRmProfile -Profile 2017-03-09-profile -Confirm:$false ;
#Install-Module -Name AzureStack -RequiredVersion 1.2.9 -AllowClobber -Force -Confirm:$false;

## Download Azure Stack tools
Write-Host "Download Azure Stack tools" -ForegroundColor Green;
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile "$workPath\master.zip" ;
expand-archive "$workPath\master.zip" -DestinationPath $workPath -Force;

## import module
Write-Host "import module" -ForegroundColor Green;
#Import-Module $workPath\AzureStack-Tools-master\Connect\AzureStack.Connect.psm1 ;

## Downloading and Expand the AppService package
Write-Host "Downloading and Expand the AppService package" -ForegroundColor Green;
New-Item -Path "$workPath\rps\appservice" -ItemType Directory -Force | Out-Null
Invoke-WebRequest -Uri $DLURIInstaller -OutFile "$workPath\rps\appservice\AppService.exe";
Invoke-WebRequest -Uri $DLURIHelper -OutFile "$workPath\rps\appservice\AppServiceHelperScripts.zip";
expand-archive "$workPath\rps\appservice\AppServiceHelperScripts.zip" -DestinationPath "$workPath\rps\appservice\" -Force;

## Create Credential
Write-Host "Create Credential" -ForegroundColor Green;
#$Pass = ConvertTo-SecureString $Password -AsPlainText -Force;
#$cred = New-Object System.Management.Automation.PSCredential($Account, $Pass);
#$VMPass = ConvertTo-SecureString $VMPass -AsPlainText -Force;
#$VMcred = New-Object System.Management.Automation.PSCredential($VMAccount, $VMPass);

Set-Location "$workPath\rps\appservice"
.\Create-AppServiceCerts.ps1 -pfxPassword ( ConvertTo-SecureString $pfxPassword -AsPlainText -Force) -Verbose;


