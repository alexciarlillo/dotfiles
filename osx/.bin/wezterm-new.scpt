set appName to "WezTerm"

if application appName is running then
  Do Shell Script "/Applications/WezTerm.app/Contents/MacOS/wezterm-gui"
else
  tell application appName to activate
end if
