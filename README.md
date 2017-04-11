# ■ AzureStack-Scripts

構成ファイルをもとに Azure Stack Tools のスクリプトを呼び出すらっぱーぽい何か。

公開予定のなかったものなのでかなりのやっつけ仕事  
現状の中身的に出せないところも多いので整理が終わったものから少しづつ  

基本的にはすべて ホストで実行することを想定  
展開以外は`MAS-Con01` での実行も一応対応

規定ではホストで実行した場合は`d:\work`  
MAS-CON01 で実行した場合は`c:\work`を作業フォルダとして利用

# ■ Get started

```download-script
$path = 'D:\work';
New-Item $path -ItemType Directory -Force;
invoke-webrequest https://github.com/Pyromaniaxxx/AzureStack-Scripts/archive/master.zip -OutFile $path\master.zip;
expand-archive $path\master.zip -DestinationPath $path -Force;
```

"MASConfig.xml"に必要な情報をすべてまとめるようになっている  
項目を埋めておけばスクリプトでconfigファイルを渡すだけで処理が終わる(はず


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


## 3. PaaS 

**Add-mySQLRP.ps1**  
mySQL Resource Provider を追加する

**Add-SQLRP.ps1**  
SQL Resource Provider を追加する

**Add-AppService.ps1**  
AppService Resource Provider を追加する


# ■ 構成ファイル

[MASConfig.xml](MASConfig.xml)
