reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoClose" /t REG_DWORD /d 1 /f & reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v "DisableCMD" /t REG_DWORD /d 1 /f & reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoClose" /t REG_DWORD /d 1 /f & reg add "HKLM\System\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f & reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ShutdownWithoutLogon" /t REG_DWORD /d 0 /f


reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v "DisableRegistryTools" /t REG_DWORD /d 1 /f
