# ■ AzureStack-Scripts

※TP3対応版から DevKit版へ差し替え中です。

構成ファイルをもとに Azure Stack Tools のスクリプトを呼び出すらっぱーぽい何か。

公開予定のなかったものなのでかなりのやっつけ仕事  
現状の中身的に出せないところも多いので整理が終わったものから少しづつ  

VM構成変更などにより、ホストで実行する前提で実装しています。

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

展開は'asdk-installer.ps1'を利用するようになったのでいったん削除

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
