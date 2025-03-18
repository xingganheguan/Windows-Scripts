# ����밴���ڹ鵵���ݣ�����ÿ�촴��һ���µı����ļ��� D:\Data\Tasks_YYYYMMDD������ʹ�ã�
# $DateSuffix = Get-Date -Format "yyyyMMdd"
# $BackupPath = "D:\Data\Tasks_$DateSuffix"

# ��־�ļ�·��
$LogFile = "E:\Logging\ExportScheduledTasks.log"
# ����Ŀ¼·��
$BackupPath = "E:\Tasks"
# Ҫ�ų��������б�
$ExcludedTasks = @("User_Feed_Synchronization", "Optimize Start Menu Cache Files")

# ��ʼ��¼��־
Start-Transcript -Path $LogFile
Write-Output "��ʼ�����ƻ�����..."

# �������·�����ڣ���ɾ���ɵı���Ŀ¼
If (Test-Path -Path $BackupPath) {
    try {
        Remove-Item -Path $BackupPath -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Output "�޷�ɾ���ɵı���Ŀ¼: $_"
        Stop-Transcript
        exit
    }
}
# �����µı���Ŀ¼
New-Item -Path $BackupPath -ItemType Directory | Out-Null

# ��ȡ���������ļ��У��ų� "Microsoft" �� "OfficeSoftware" �������
$TaskFolders = (Get-ScheduledTask).TaskPath | Where-Object { ($_ -notmatch "Microsoft") -and ($_ -notmatch "OfficeSoftware") -and ($_ -notmatch "Google")} | Select-Object -Unique

# �������������ļ���
foreach ($TaskFolder in $TaskFolders) {
    Write-Output "���ڴ��������ļ���: $TaskFolder"

    # ����·���������ļ���·������
    $FolderPath = Join-Path -Path $BackupPath -ChildPath $TaskFolder.TrimStart("\")
    if ($TaskFolder -ne "\") { New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null }

    # ��ȡ���񣬲��ų�����Ҫ����������
    $Tasks = Get-ScheduledTask -TaskPath $TaskFolder -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -notin $ExcludedTasks }

    # ����ÿ�����񲢵���
    foreach ($Task in $Tasks) {
        $TaskName = $Task.TaskName
        $FilePath = Join-Path -Path $FolderPath -ChildPath "$TaskName.xml"
        
        try {
            Export-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder | Out-File -FilePath $FilePath -Encoding utf8
            Write-Output "�ѱ����ļ�: $FilePath"
        } catch {
            Write-Output "�������� '$TaskName' ʧ��: $_"
        }
    }
}

Write-Output "�ƻ����񵼳����."
Stop-Transcript