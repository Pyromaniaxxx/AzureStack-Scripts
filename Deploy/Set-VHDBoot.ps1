#Requires -RunAsAdministrator
<#
.Synopsis
   set vhd boot
.DESCRIPTION
   Script to set VHD boot of Cloudbuilder.vhdx
.EXAMPLE
    .\Set-VHDBoot.ps1 -ConfigFile "C:\work\Config.xml"
.EXAMPLE
    .\Set-VHDBoot.ps1 -HostPassword "password1!" -VHDXFullPath "C:\mas\CloudBuilder.vhdx" -MasterVHDXFullPath "\\fileserver\AzureStack170225\CloudBuilder.vhdx"
.EXAMPLE
    .\Set-VHDBoot.ps1 -HostPassword "password1!" -VHDXFullPath "C:\mas3\CloudBuilder.vhdx" -MasterVHDXFullPath "\\fileserver\AzureStack170225\CloudBuilder.vhdx" -VHDXPath "c:\mas3"
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
    # Host Password
    [Parameter(Mandatory=$True,Position=0,ParameterSetName='Manual')]
    [string]$HostPassword,
    # cloudbuilder.vhdx path
    [Parameter(Mandatory=$True,Position=1,ParameterSetName='Manual')]
    [string]$VHDXFullPath,
    # cloudbuilder.vhdx folder
    [Parameter(Mandatory=$false,Position=2,ParameterSetName='Manual')]
    [string]$MasterVHDXFullPath = "none",
    # cloudbuilder.vhdx folder
    [Parameter(Mandatory=$false,Position=3,ParameterSetName='Manual')]
    [string]$VHDXPath = 'C:\mas'
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
    $HostPassword = $ConfigXml.AzureStackConfig.Host.Password;
    $VHDXFullPath = (Join-Path $ConfigXml.AzureStackConfig.VHDXPath $ConfigXml.AzureStackConfig.VHDXFileName);
    $VHDXPath = $ConfigXml.AzureStackConfig.VHDXPath;
    $MasterVHDXFullPath = $ConfigXml.AzureStackConfig.MasterVHDXFullPath;
}

# Create folder
if (Test-Path -Path $VHDXPath)
{
    Write-Host "skip Create folder : $VHDXPath" -ForegroundColor Green;
}
else
{
    Write-Host "Create folder : $VHDXPath" -ForegroundColor Green;
    New-Item $VHDXPath -Type directory -Force | Out-Null;
}

# Download files
Write-Host "Download files" -ForegroundColor Green;
$Uri = 'https://raw.githubusercontent.com/Azure/AzureStack-Tools/master/Deployment/';
'BootMenuNoKVM.ps1', 'PrepareBootFromVHD.ps1', 'unattend_NoKVM.xml' | ForEach-Object { Invoke-WebRequest ($uri + $_) -OutFile ($VHDXPath + '\' + $_) } ;

if ($MasterVHDXFullPath -ne "none")
{
    if (Test-Path $MasterVHDXFullPath)
    {
        # copy CloudBuilder
        Write-Host "Copy vhdx" -ForegroundColor Green;
        Write-Verbose " Source Path : $MasterVHDXFullPath";
        Write-Verbose " Destination Path : $VHDXPath";
        Copy-Item -Path $MasterVHDXFullPath -Destination $VHDXPath -Force;        
    }
    else
    {
        Write-Error " file not found ";
        return ;        
    }
}
else
{
    Write-Host "skip Copy vhdx" -ForegroundColor Green;
}

# Set vhd boot
Write-Host "Set vhd boot" -ForegroundColor Green;
& "$VHDXPath\PrepareBootFromVHD.ps1" -CloudBuilderDiskPath $VHDXFullPath -ApplyUnattend -AdminPassword $HostPassword -Verbose
