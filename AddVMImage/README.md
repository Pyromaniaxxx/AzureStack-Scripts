# ■ AzureStack-Scripts/AddVMImage

構成ファイルをもとに Azure Stack Tools のスクリプトを呼び出すらっぱーぽい何か。

Windows Server 2016 VM イメージ追加


# ■ MASConfig.xml

ここら辺が対象

```Config
    <PIR>
        <WS2016DC>
            <ISOPath>D:\work\en_windows_server_2016_x64_dvd.iso</ISOPath>          
        </WS2016DC>
        <WS2012DC>none</WS2012DC>
    </PIR>
```


# ■ Script

**Add-WS2016VMImage.ps1**  
- Windows Server 2016 DC のVMイメージを追加

日本語版ISOファイルでの作成もできるが、SQLRPの展開で失敗するため英語版ISOを使うことが望ましい
