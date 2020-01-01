@echo off
if not exist "%1.png"  goto :noexist
@echo on
powershell -executionpolicy Bypass -File ConvertTo-Icon.ps1 -File "%1.png" -OutputFile "%1.ico"
@goto :eof

:noexist
echo/error: file "%1.png" does not exist
