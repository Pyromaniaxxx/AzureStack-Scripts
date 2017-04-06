### AzureStack-Scripts

公開予定のなかったものなのでかなりのやっつけ仕事  
中身的に出せないところも多いので中身の整理が終わったものから


### Get started

```download-script
set-location D:\work
Install-Module -Name AzureRM -RequiredVersion 1.2.8 -Scope CurrentUser
Install-Module -Name AzureStack  
invoke-webrequest https://github.com/Pyromaniaxxx/AzureStack-Scripts/archive/master.zip -OutFile master.zip 
expand-archive master.zip -DestinationPath . -Force;

```
