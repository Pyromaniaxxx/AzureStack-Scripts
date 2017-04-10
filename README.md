# ■ AzureStack-Scripts

公開予定のなかったものなのでかなりのやっつけ仕事  
中身的に出せないところも多いので中身の整理が終わったものからだしつつ  
中身の整理をしていきます…

# ■ Get started

```download-script
$path = 'c:\work';
New-Item $path -ItemType Directory -Force;
invoke-webrequest https://github.com/Pyromaniaxxx/AzureStack-Scripts/archive/master.zip -OutFile $path\master.zip;
expand-archive $path\master.zip -DestinationPath $path -Force;
```

"MASConfig.xml"に必要な情報をすべてまとめるようになっているので、項目を埋めておけばスクリプトでconfigファイルを渡すだけで処理が終わるようになってます。


# ■ 概要

## 1. Deploy 

**Set-VHDBoot.ps1**  
`Cloudbuilder.vhdx` を上書きコピーし、VHD boot設定をする

**Set-HostConfig.ps1**  
ホスト名を変更して、NICをMAC Address 順にリネーム`Eth01`以外を無効化

**Deploy-MAS.ps1**  
`InstallAzureStackPOC.ps1` を呼び出して Azure Stack の展開を開始

## 2. AddVMImage 

**Add-WS2016VMImage.ps1**  
Windows Server 2016 の VMイメージを追加する


# MASConfig.xml

```config
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<AzureStackConfig>
    <WorkPath>%作業フォルダ名%</WorkPath>
    <VHDXPath>%Cloudbuilder を配置するパス%</VHDXPath>
    <VHDXFileName>CloudBuilder.vhdx</VHDXFileName>
    <MasterVHDXFullPath>%マスター VHDX のあるパス%</MasterVHDXFullPath>
    <deploy>
        <deployType>%AAD or ADFS%</deployType>
        <AdminPassword>%AdminPassword%</AdminPassword>
        <AADTenantName>%TenantName.onmicrosoft.com%</AADTenantName>
        <AADAccount>%MASAdmin@TenantName.onmicrosoft.com%</AADAccount>
        <AADPassword>%AzureADPassword%</AADPassword>
    </deploy>
    <Host>
        <Hostname>%HostName%</Hostname>
        <Password>%password%</Password>
        <NIC1>Eth</NIC1>
        <NIC10>Chelsio</NIC10>
        <Network>
            <Type>%DHCP or Static%</Type>
        </Network>
    </Host>
    <NatVM>
        <Network>
            <Type>%DHCP or Static%</Type>
            <IPv4Address>192.168.0.2</IPv4Address>
            <IPv4Subnet>192.168.0.0/24</IPv4Subnet>
            <IPv4DefaultGateway>192.168.0.250</IPv4DefaultGateway>
        </Network>
    </NatVM>
    <PIR>
        <WS2016DC>            
            <ISOPath>%Windows Server 2016 ISO File Path%</ISOPath>
        </WS2016DC>
    </PIR>
    <ResourceProvider>
        <mySQL>
            <DLURI>https://aka.ms/azurestackmysqlrptp3</DLURI>
            <ResourceGroupName>System.MySql</ResourceGroupName>
            <VMName>SystemMySqlRP</VMName>
            <VMAccount>mySQLAdmin</VMAccount>
            <VMPass>%password%</VMPass>
            <AcceptLicense>True</AcceptLicense>
            <SilentInstall>True</SilentInstall>
        </mySQL>
        <MSSQL>
            <DLURI>https://aka.ms/azurestacksqlrptp3</DLURI>
            <ResourceGroupName>System.Sql</ResourceGroupName>
            <VMName>SQLVM</VMName>
            <VMAccount>SQLAdmin</VMAccount>
            <VMPass>%password%</VMPass>
        </MSSQL>
    </ResourceProvider>
    <RegisterAzureSubscription>
        <AADTenantName>%Tenant01.onmicrosoft.com%</AADTenantName>
        <SubscriptionID>%1122d559-9719-49fa-9eae-84b1d7537076%</SubscriptionID>
    </RegisterAzureSubscription>
</AzureStackConfig>
```