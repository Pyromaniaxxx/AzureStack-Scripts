# ■ AzureStack-Scripts/Deploy

構成ファイルをもとに Azure Stack Tools のスクリプトを呼び出すらっぱーぽい何か。

PaaS Service TP3 展開  
mySQL DB・SQL DB・ AppService 証明書発行 まで  
AppService 部分は作成中

# ■ Get started

Script download

```download-script
$path = 'D:\work';
New-Item $path -ItemType Directory -Force;
invoke-webrequest https://github.com/Pyromaniaxxx/AzureStack-Scripts/archive/master.zip -OutFile $path\master.zip;
expand-archive $path\master.zip -DestinationPath $path -Force;
```

# ■ MASConfig.xml

ここら辺が対象

```Config
    <ResourceProvider>
        <mySQL>
            <DLURI>https://aka.ms/azurestackmysqlrptp3</DLURI>
            <ResourceGroupName>System.MySql</ResourceGroupName>
            <VMName>SystemMySqlRP</VMName>
            <VMAccount>mySQLAdmin</VMAccount>
            <VMPass>Password1!Password1!</VMPass>
            <AcceptLicense>True</AcceptLicense>
            <SilentInstall>True</SilentInstall>
        </mySQL>
        <MSSQL>
            <DLURI>https://aka.ms/azurestacksqlrptp3</DLURI>
            <ResourceGroupName>System.Sql</ResourceGroupName>
            <VMName>SQLVM</VMName>
            <VMAccount>SQLAdmin</VMAccount>
            <VMPass>Password1!Password1!</VMPass>
        </MSSQL>
        <AppService>
            <DLURIInstaller>http://aka.ms/appsvconmastp3installer</DLURIInstaller>
            <DLURIHelper>http://aka.ms/appsvconmastp3helper</DLURIHelper>
            <pfxPassword>Password1!</pfxPassword>
        </AppService>
    </ResourceProvider>
```


# ■ Script

**Add-mySQLRP.ps1**  
- mySQL Resource Provider を追加

**Add-SQLRP.ps1**  
- SQL Resource Provider を追加

**Add-AppService.ps1**  
- AppService Resource Provider 証明書発行
