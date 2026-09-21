# rokit (Roblox toolchain manager) appends this env file on install. Used for
# Roblox experience development, which happens on personal machines too, so it
# lives in the universal package. Guarded so a machine without rokit installed
# still starts cleanly.
[[ -r "$HOME/.rokit/env" ]] && . "$HOME/.rokit/env"
