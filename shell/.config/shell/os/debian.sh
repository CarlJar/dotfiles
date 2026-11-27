# Debian / Raspberry Pi OS

# Debian ships these tools under different names
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'
command -v batcat >/dev/null 2>&1 && alias bat='batcat'

alias update='sudo apt update && sudo apt upgrade'
