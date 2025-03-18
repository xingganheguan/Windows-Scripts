# 如果想按日期归档备份，例如每天创建一个新的备份文件夹 D:\Data\Tasks_YYYYMMDD，可以使用：
# $DateSuffix = Get-Date -Format "yyyyMMdd"
# $BackupPath = "D:\Data\Tasks_$DateSuffix"

# 日志文件路径
$LogFile = "E:\Logging\ExportScheduledTasks.log"
# 备份目录路径
$BackupPath = "E:\Tasks"
# 要排除的任务列表
$ExcludedTasks = @("User_Feed_Synchronization", "Optimize Start Menu Cache Files")

# 开始记录日志
Start-Transcript -Path $LogFile
Write-Output "开始导出计划任务..."

# 如果备份路径存在，则删除旧的备份目录
If (Test-Path -Path $BackupPath) {
    try {
        Remove-Item -Path $BackupPath -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Output "无法删除旧的备份目录: $_"
        Stop-Transcript
        exit
    }
}
# 创建新的备份目录
New-Item -Path $BackupPath -ItemType Directory | Out-Null

# 获取所有任务文件夹，排除 "Microsoft" 和 "OfficeSoftware" 相关任务
$TaskFolders = (Get-ScheduledTask).TaskPath | Where-Object { ($_ -notmatch "Microsoft") -and ($_ -notmatch "OfficeSoftware") -and ($_ -notmatch "Google")} | Select-Object -Unique

# 遍历所有任务文件夹
foreach ($TaskFolder in $TaskFolders) {
    Write-Output "正在处理任务文件夹: $TaskFolder"

    # 处理路径，避免文件夹路径问题
    $FolderPath = Join-Path -Path $BackupPath -ChildPath $TaskFolder.TrimStart("\")
    if ($TaskFolder -ne "\") { New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null }

    # 获取任务，并排除不需要导出的任务
    $Tasks = Get-ScheduledTask -TaskPath $TaskFolder -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -notin $ExcludedTasks }

    # 遍历每个任务并导出
    foreach ($Task in $Tasks) {
        $TaskName = $Task.TaskName
        $FilePath = Join-Path -Path $FolderPath -ChildPath "$TaskName.xml"
        
        try {
            Export-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder | Out-File -FilePath $FilePath -Encoding utf8
            Write-Output "已保存文件: $FilePath"
        } catch {
            Write-Output "导出任务 '$TaskName' 失败: $_"
        }
    }
}

Write-Output "计划任务导出完成."
Stop-Transcript