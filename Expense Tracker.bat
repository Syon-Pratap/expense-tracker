@echo off
rem Opens the expense tracker in its own clean window (no tabs, no address bar).
rem Falls back to your default browser if Chrome/Edge aren't found.
setlocal
set "HTML=%~dp0index.html"
set "URL=file:///%HTML:\=/%"

for %%B in (
  "%LocalAppData%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
) do (
  if exist %%~B (
    start "" %%B --app="%URL%" --window-size=1150,900
    exit /b
  )
)

start "" "%HTML%"
