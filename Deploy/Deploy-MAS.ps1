#Requires -RunAsAdministrator
<#
.Synopsis
   set host config
.DESCRIPTION
   Script to configure host 
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
    $NatVMNetworkStatic = ($ConfigXml.AzureStackConfig.NatVM.Network.Type -eq 'Static');

    switch ($DeployType)
    {
        'ADFS'
        {
            $Password = $ConfigXml.AzureStackConfig.deploy.AdminPassword;
        }
        'AAD'
        {
            $Password = $ConfigXml.AzureStackConfig.deploy.AdminPassword;
            $AADAccount = $ConfigXml.AzureStackConfig.deploy.AADAccount;
            $AADPassword = $ConfigXml.AzureStackConfig.deploy.AADPassword;
            $AADTenantName = $ConfigXml.AzureStackConfig.deploy.AADTenantName;
        }
        Default
        {
            Write-Warning -Message "Deploy Type Error : $DeployType";
            return;
        }
    }

    if($NatVMNetworkStatic)
    {
        $NATIPv4Address = $ConfigXml.AzureStackConfig.NatVM.Network.IPv4Address;
        $NATIPv4Subnet = $ConfigXml.AzureStackConfig.NatVM.Network.IPv4Subnet;
        $NATIPv4DefaultGateway = $ConfigXml.AzureStackConfig.NatVM.Network.IPv4DefaultGateway;              
    }
}

# create param
$param = @{
    'AdminPassword' = ConvertTo-SecureString $Password -AsPlainText -Force;
}

## Deploy Type
Write-Host "Deploy Type : $DeployType" -ForegroundColor Green;
switch ($DeployType)
{
    'ADFS'
    {
        $param.Add('UseADFS',$True);
    }
    'AAD'
    {
        # aad cred
        $aadpass = ConvertTo-SecureString $AADPassword -AsPlainText -Force;
        $aadcred = New-Object System.Management.Automation.PSCredential ($AADAccount, $aadpass);

        $param.Add('InfraAzureDirectoryTenantAdminCredential',$aadcred);
        $param.Add('InfraAzureDirectoryTenantName',$AADTenantName);
    }
    Default
    {
        Write-Warning -Message "Deploy Type Error : $DeployType";
        return;
    }
}

if ($NatVMNetworkStatic)
{
    $param.Add('NATIPv4Address',$NATIPv4Address);
    $param.Add('NATIPv4Subnet',$NATIPv4Subnet);
    $param.Add('NATIPv4DefaultGateway',$NATIPv4DefaultGateway);
}

$param
C:\CloudDeployment\Setup\InstallAzureStackPOC.ps1 @param -Verbose;
