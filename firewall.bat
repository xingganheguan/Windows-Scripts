@echo off
:: 读取 Cloudflare IP 地址文件
setlocal enabledelayedexpansion
set CF_IPS=

:: 读取 cf_ips.txt 并拼接成逗号分隔的 IP 列表
for /f "tokens=*" %%i in (cf_ips.txt) do (
    if defined CF_IPS (
        set CF_IPS=!CF_IPS!,%%i
    ) else (
        set CF_IPS=%%i
    )
)

:: 清除旧规则（避免重复添加）
netsh advfirewall firewall delete rule name="Allow Cloudflare Web"
netsh advfirewall firewall delete rule name="Block All Web"

:: 允许 Cloudflare 访问 80 和 443 端口
netsh advfirewall firewall add rule name="Allow Cloudflare Web" dir=in action=allow protocol=TCP localport=80,443 remoteip=%CF_IPS%

:: 阻止所有其他 IP 访问 80 和 443 端口
netsh advfirewall firewall add rule name="Block All Web" dir=in action=block protocol=TCP localport=80,443

echo Firewall rules updated successfully.
pause