@echo off
rem One-time: puts an "Expense Tracker" shortcut on your Desktop.
setlocal
set "TARGET=%~dp0Expense Tracker.bat"
powershell -NoProfile -Command ^
  "$s = (New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Expense Tracker.lnk');" ^
  "$s.TargetPath = '%TARGET%';" ^
  "$s.WorkingDirectory = '%~dp0';" ^
  "$s.IconLocation = 'shell32.dll,116';" ^
  "$s.WindowStyle = 7;" ^
  "$s.Description = 'Open the expense tracker';" ^
  "$s.Save()"
echo.
echo Done - "Expense Tracker" is on your Desktop.
echo You can drag it onto your taskbar to pin it.
echo.
pause
