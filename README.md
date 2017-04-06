## ■ AzureStack-Scripts

公開予定のなかったものなのでかなりのやっつけ仕事  
中身的に出せないところも多いので中身の整理が終わったものから


## ■ Get started

```download-script
set-location D:\work
Install-Module -Name AzureRM -RequiredVersion 1.2.8 -Scope CurrentUser
Install-Module -Name AzureStack  
invoke-webrequest https://github.com/Pyromaniaxxx/AzureStack-Scripts/archive/master.zip -OutFile master.zip 
expand-archive master.zip -DestinationPath . -Force;
```

"MASConfig.xml"に必要な情報をすべてまとめるようになっているので、項目を埋めておけばスクリプトでconfigファイルを渡すだけで処理が終わるようになってます。


## ■ 概要

### 1. Deploy 

**Set-VHDBoot.ps1**  
`Cloudbuilder.vhdx` を上書きコピーし、VHD boot設定をする

**Set-HostConfig.ps1**  
ホスト名を変更して、NICをMAC Address 順にリネーム`Eth01`以外を無効化

**Deploy-MAS.ps1**  
`InstallAzureStackPOC.ps1` を呼び出して Azure Stack の展開を開始

### 2. AddVMImage 

**Add-WS2016VMImage.ps1**  
Windows Server 2016 の VMイメージを追加する