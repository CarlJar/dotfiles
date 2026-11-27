# Laptop (ThinkPad) — RENAME this file to your laptop's hostname: run `uname -n` there
# e.g.  git mv shell/.config/shell/host/LAPTOP.sh shell/.config/shell/host/<hostname>.sh

# --- Masterarbeit ---
alias master='cd ~/projects/SHiP-Masterthesis'
alias doc='cd ~/projects/SHiP-Masterthesis/documentation/'
alias notes='cd ~/projects/mkdocs-playground'
alias sync-readme='master && ./sync-readme.sh'

# --- network ---
alias pi-home='ssh carl@192.168.178.158'
alias vpn='nmcli connection up wg_config'
alias vpn-off='nmcli connection down wg_config'
