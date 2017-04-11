# ■ AzureStack-Scripts/Deploy

構成ファイルをもとに Azure Stack Tools のスクリプトを呼び出すらっぱーぽい何か。

VHD boot の設定から `InstallAzureStackPOC.ps1` の実行まで。

# ■ Get started

Script download

```download-script
$path = 'c:\work';
New-Item $path -ItemType Directory -Force;
invoke-webrequest https://github.com/Pyromaniaxxx/AzureStack-Scripts/archive/master.zip -OutFile $path\master.zip;
expand-archive $path\master.zip -DestinationPath $path -Force;
```

# ■ MASConfig.xml

ここら辺が対象

```Config
    <WorkPath>work</WorkPath>
    <VHDXPath>c:\mas</VHDXPath>
    <VHDXFileName>CloudBuilder.vhdx</VHDXFileName>
    <MasterVHDXFullPath>\\FileServerShare\CloudBuilder.vhdx</MasterVHDXFullPath>
    <deploy>
        <deployType>AAD</deployType>
        <AdminPassword>Password1!</AdminPassword>
        <AADTenantName>Tenant.onmicrosoft.com</AADTenantName>
        <AADAccount>MASAdmin@Tenant.onmicrosoft.com</AADAccount>
        <AADPassword>Password1!</AADPassword>
    </deploy>
    <Host>
        <Hostname>MASHost01</Hostname>
        <Password>Password1!</Password>
        <NIC1>Eth</NIC1>
        <NIC10>Chelsio</NIC10>
        <Network>
            <Type>DHCP</Type>
        </Network>
    </Host>
    <NatVM>
        <Network>
            <Type>Static</Type>
            <IPv4Address>192.168.0.2</IPv4Address>
            <IPv4Subnet>192.168.0.0/24</IPv4Subnet>
            <IPv4DefaultGateway>192.168.0.250</IPv4DefaultGateway>
        </Network>
    </NatVM>
```


# ■ Script

**Set-VHDBoot.ps1**  
- `Cloudbuilder.vhdx` を上書きコピー
- VHD boot設定
- VHDXからブートするために再起動

`<MasterVHDXFullPath>none/MasterVHDXFullPath>` の場合は VHDX をコピーしない。
※`Host.Network.Type`はまだ未実装(結局使わなかったので実装するか未定

**Set-HostConfig.ps1**  
- NICをMAC Address 順にリネーム
- `Eth01`以外を無効化
- ホスト名を変更
- 再起動

**Deploy-MAS.ps1**  
- `InstallAzureStackPOC.ps1` を呼び出して Azure Stack の展開を開始
