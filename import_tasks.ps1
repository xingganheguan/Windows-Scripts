$ImportPath= "E:\Tasks";

$Credential = Get-Credential -UserName "WINDOWS\Administrator" -Message "输入密码"

# 获取所有 XML 任务文件
$TaskFiles = Get-ChildItem -Path $ImportPath -Filter "*.xml"
#Write-Output $TaskFiles

Start-Sleep  -s 1

foreach ($TaskFile in $TaskFiles) {
    $XmlFileName = $TaskFile.fullname
    
    $TaskName = (Get-Item $XmlFileName).BaseName  # 任务名称
    Write-Output $TaskName
    Register-ScheduledTask -Xml (get-content $XmlFileName | out-string) -TaskName $TaskName -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password
    Start-Sleep  -s 1
}