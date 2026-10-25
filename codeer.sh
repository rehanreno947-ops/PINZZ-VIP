#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# CODEER v2.5 - WiFi Speed Update
# Created by: Pinztok
# ==========================================

# ==== PALET WARNA NEON ====
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'; B='\033[1;34m'
M='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'; D='\033[0;90m'; N='\033[0m'
BG_M='\033[45m'

# ==== FUNGSI ANIMASI ====
spin() {
  local msg="$1" dur="${2:-1}"
  local frames=('◰' '◳' '◲' '◱')
  local end=$((SECONDS + dur))
  while [ $SECONDS -lt $end ]; do
    for f in "${frames[@]}"; do
      printf "\r${C}  [${f}] ${D}%s${N}" "$f" "$msg"
      sleep 0.06
    done
  done
  printf "\r${G}  [✓] ${W}%s${N}          \n" "$msg"
}

type_out() {
  local text="$1" color="${2:-$W}"
  printf "  ${color}"
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep 0.005
  done
  printf "${N}\n"
}

# ==== HEADER & FOOTER MODUL ====
header() {
  clear
  printf "${M}  ╔════════════════════════════════════════╗${N}\n"
  printf "${M}  ║${BG_M}${W}  %-36s  ${N}${M}║${N}\n" "$1"
  printf "${M}  ╚════════════════════════════════════════╝${N}\n\n"
}

footer() {
  echo ""
  printf "${D}  ──────────────────────────────────────────${N}\n"
  printf "${R}   [0]${W} EXIT (Kembali ke Menu Utama)${N}\n"
  printf "${D}  ──────────────────────────────────────────${N}\n\n"
  printf "${Y}  ➤ ${W}Pilih (0) > ${N}"
}

# ==========================================
# 01 - 06 : SISTEM
# ==========================================

mod_info() {
  while true; do
    header "01. DEVICE INFO"
    spin "Membaca sistem" 1
    printf "${C}  ┌──────────────────────────────────────┐${N}\n"
    printf "${C}  │${N} ${D}Model   :${N} ${W}%-26s${N} ${C}│${N}\n" "$(getprop ro.product.model | cut -c1-26)"
    printf "${C}  │${N} ${D}Android :${N} ${W}%-26s${N} ${C}│${N}\n" "$(getprop ro.build.version.release)"
    printf "${C}  │${N} ${D}Kernel  :${N} ${W}%-26s${N} ${C}│${N}\n" "$(uname -r | cut -c1-26)"
    printf "${C}  │${N} ${D}Uptime  :${N} ${W}%-26s${N} ${C}│${N}\n" "$(uptime -p 2>/dev/null | cut -c1-26)"
    printf "${C}  └──────────────────────────────────────┘${N}\n"
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_mem() {
  while true; do
    header "02. MEMORY RAM"
    spin "Menghitung RAM" 1
    free -h 2>/dev/null | while IFS= read -r l; do printf "${C}  %s${N}\n" "$l"; done
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_cpu() {
  while true; do
    header "03. CPU & TEMP"
    spin "Membaca CPU" 1
    type_out "Core CPU : $(nproc)" "$C"
    type_out "Load Avg : $(cat /proc/loadavg 2>/dev/null | awk '{print $1" "$2" "$3}')" "$C"
    echo ""
    type_out "Top 5 Proses:" "$D"
    ps -eo pid,pcpu,comm --sort=-pcpu 2>/dev/null | head -6 | while IFS= read -r l; do printf "${D}  %s${N}\n" "$l"; done
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_disk() {
  while true; do
    header "04. STORAGE"
    spin "Menghitung storage" 1
    df -h 2>/dev/null | head -5 | while IFS= read -r l; do printf "${C}  %s${N}\n" "$l"; done
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_battery_status() {
  while true; do
    header "05. BATTERY STATUS"
    spin "Membaca baterai" 1
    if command -v termux-battery-status >/dev/null 2>&1; then
      B=$(timeout 2 termux-battery-status 2>/dev/null)
      if [ -n "$B" ]; then echo "$B" | while IFS= read -r l; do printf "${C}  %s${N}\n" "$l"; done
      else printf "${Y}  [!] Aplikasi Termux:API belum terinstall.${N}\n"; fi
    else printf "${Y}  [!] Paket termux-api belum ada.${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_app() {
  while true; do
    header "06. LIST APP"
    spin "Membaca aplikasi" 1
    if command -v pm >/dev/null 2>&1; then
      pm list packages 2>/dev/null | sed 's/package://' | head -15 | while IFS= read -r l; do printf "${C}  ▸ %s${N}\n" "$l"; done
    else printf "${Y}  [!] pm nggak tersedia di Termux biasa.${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

# ==========================================
# 07 - 12 : JARINGAN
# ==========================================

mod_net() {
  while true; do
    header "07. LOCAL NETWORK"
    spin "Membaca jaringan" 1
    type_out "IP Lokal:" "$W"
    ifconfig 2>/dev/null | grep 'inet ' | grep -v 127.0.0.1 | awk '{print "  "$2}' | while IFS= read -r l; do printf "${G}%s${N}\n" "$l"; done
    echo ""
    type_out "DNS Server:" "$W"
    cat /etc/resolv.conf 2>/dev/null | grep nameserver | awk '{print "  "$2}' | while IFS= read -r l; do printf "${G}%s${N}\n" "$l"; done
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_sensor() {
  while true; do
    header "08. SENSOR HP"
    spin "Mendeteksi sensor" 1
    if command -v termux-sensor >/dev/null 2>&1; then
      S=$(timeout 2 termux-sensor -l 2>/dev/null)
      if [ -n "$S" ]; then echo "$S" | while IFS= read -r l; do printf "${C}  ▸ %s${N}\n" "$l"; done
      else printf "${Y}  [!] Gagal membaca sensor.${N}\n"; fi
    else printf "${Y}  [!] Paket termux-api belum ada.${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_ip() {
  while true; do
    header "09. PUBLIC IP"
    spin "Mengecek IP Publik" 1
    IP=$(timeout 3 curl -s ifconfig.me 2>/dev/null)
    if [ -n "$IP" ]; then type_out "IP Publik : $IP" "$G"
    else printf "${R}  [!] Gagal ambil IP (Offline).${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_bigfiles() {
  while true; do
    header "10. TOP BIG FILES"
    spin "Mencari file" 2
    find $HOME -type f -exec du -h {} + 2>/dev/null | sort -rh | head -8 | while IFS= read -r l; do printf "${D}  %s${N}\n" "$l"; done
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_uptime_load() {
  while true; do
    header "11. UPTIME & LOAD"
    spin "Membaca Uptime" 1
    type_out "Uptime   : $(uptime -p 2>/dev/null)" "$C"
    type_out "Load Avg : $(cat /proc/loadavg 2>/dev/null | awk '{print $1" "$2" "$3}')" "$C"
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_speedtest() {
  while true; do
    header "12. SPEEDTEST"
    spin "Menguji koneksi" 2
    RESULT=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 5 http://speedtest.tele2.net/10MB.zip)
    SPEED=$(awk "BEGIN {print $RESULT/1024/1024}")
    if [ -n "$SPEED" ]; then
      printf "${C}  ┌──────────────────────────────────────┐${N}\n"
      printf "${C}  │${N} ${D}Kecepatan :${N} ${G}%-23s${N} ${C}│${N}\n" "$(printf "%.2f" $SPEED) MB/s"
      printf "${C}  └──────────────────────────────────────┘${N}\n"
    else printf "${R}  [!] Gagal tes (Offline).${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

# ==========================================
# 13 - 15 : UTILITAS
# ==========================================

mod_battery_health() {
  while true; do
    header "13. BATTERY HEALTH"
    spin "Membaca hardware" 1
    CAP=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    TEMP=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
    VOLT=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)
    if [ -n "$CAP" ]; then
      printf "${C}  ┌──────────────────────────────────────┐${N}\n"
      printf "${C}  │${N} ${D}Kapasitas :${N} ${G}%-23s${N} ${C}│${N}\n" "$CAP%"
      printf "${C}  │${N} ${D}Suhu      :${N} ${Y}%-23s${N} ${C}│${N}\n" "$(awk "BEGIN {print $TEMP/10}") °C"
      printf "${C}  │${N} ${D}Voltase   :${N} ${C}%-23s${N} ${C}│${N}\n" "$(awk "BEGIN {print $VOLT/1000000}") V"
      printf "${C}  └──────────────────────────────────────┘${N}\n"
    else printf "${Y}  [!] Akses dibatasi sistem Android.${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_clean_cache() {
  while true; do
    header "14. CLEAN CACHE"
    spin "Menghitung cache" 1
    BEFORE=$(du -sh $HOME/.cache 2>/dev/null | awk '{print $1}')
    [ -z "$BEFORE" ] && BEFORE="0B"
    type_out "Cache Termux : $BEFORE" "$Y"
    printf "\n${Y}  ➤ Hapus cache Termux? (y/n) > ${N}"
    read -r ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
      spin "Membersihkan" 1
      rm -rf $HOME/.cache/* 2>/dev/null
      type_out "Selesai dibersihkan!" "$G"
    else printf "${R}  [!] Dibatalkan.${N}\n"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_find_file() {
  while true; do
    header "15. FIND FILE"
    printf "${Y}  ➤ Nama file (contoh: .jpg) > ${N}"
    read -r fname
    if [ -z "$fname" ]; then
      printf "${R}  [!] Nama file kosong.${N}\n"
    else
      spin "Mencari" 1
      FOUND=$(find $HOME -type f -iname "*$fname*" 2>/dev/null | head -8)
      if [ -n "$FOUND" ]; then
        echo "$FOUND" | while IFS= read -r l; do printf "${C}  ▸ %s${N}\n" "$l"; done
      else printf "${R}  [!] Tidak ditemukan.${N}\n"; fi
    fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

# ==========================================
# 16 : HTML FORGE (KUSTOM MENU)
# ==========================================
mod_html_forge() {
  while true; do
    header "16. HTML FORGE"
    echo -e "${W}  Selamat datang di HTML Forge.${N}"
    echo -e "${D}  Di sini lo bisa membuat file HTML secara otomatis.${N}\n"
    
    printf "${D}  ──────────────────────────────────────────${N}\n"
    printf "${G}   [9]${W} STAR (Mulai Buat File HTML)${N}\n"
    printf "${R}   [0]${W} EXIT (Kembali ke Menu Utama)${N}\n"
    printf "${D}  ──────────────────────────────────────────${N}\n\n"
    
    printf "${Y}  ➤ ${W}Pilih (9/0) > ${N}"
    read -r opt
    
    if [ "$opt" = "0" ]; then
      break
    elif [ "$opt" = "9" ]; then
      echo ""
      type_out "Ketik perintah lo (cth: landing page kopi / login / portofolio)." "$D"
      printf "${Y}  ➤ Prompt > ${N}"
      read -r prompt
      
      if [ -z "$prompt" ]; then
        printf "${R}  [!] Prompt kosong. Dibatalkan.${N}\n"
      else
        spin "Menyusun layout HTML" 2
        local html="<!DOCTYPE html>\n<html lang=\"id\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>CODEER FORGE</title>\n<style>\n* { margin: 0; padding: 0; box-sizing: border-box; font-family: sans-serif; }\nbody { background: #0f172a; color: #e2e8f0; min-height: 100vh; display: flex; justify-content: center; align-items: center; }\n.container { background: rgba(30, 41, 59, 0.7); padding: 40px; border-radius: 15px; border: 1px solid #38bdf8; max-width: 800px; width: 90%; text-align: center; box-shadow: 0 0 20px rgba(56, 189, 248, 0.2); }\nh1 { color: #38bdf8; margin-bottom: 20px; text-transform: uppercase; }\np { margin-bottom: 30px; color: #94a3b8; }\n.btn { padding: 12px 30px; background: #0ea5e9; color: #0f172a; border-radius: 8px; font-weight: bold; text-decoration: none; }\n</style>\n</head>\n<body>\n"
        
        if [[ "$prompt" == *"kopi"* ]] || [[ "$prompt" == *"cafe"* ]]; then
          html+="<div class=\"container\"><h1>☕ Kopi Senja</h1><p>Nikmati kopi hangat dari biji pilihan.</p><a href=\"#\" class=\"btn\">Pesan</a></div>\n"
        elif [[ "$prompt" == *"login"* ]] || [[ "$prompt" == *"masuk"* ]]; then
          html+="<div class=\"container\"><h1>🔐 Secure Login</h1><p>Silakan masuk ke sistem.</p><input type=\"text\" style=\"width:100%; padding:10px; margin-bottom:15px; border-radius:5px; border:1px solid #38bdf8; background:transparent; color:white;\"><button class=\"btn\">MASUK</button></div>\n"
        else
          html+="<div class=\"container\"><h1>🚀 Welcome</h1><p>Dibuat otomatis oleh CODEER.<br><b>\"$prompt\"</b></p><a href=\"#\" class=\"btn\">Explore</a></div>\n"
        fi
        html+="</body>\n</html>"
        
        echo -e "$html" > $HOME/codeer_forge.html
        echo ""
        printf "${G}  [✓] Berhasil dibuat!${N}\n"
        type_out "File: ~/codeer_forge.html" "$C"
        echo ""
        printf "${Y}  Cara buka di HP:${N}\n"
        printf "${D}  1. Buka File Manager -> folder Termux -> home.${N}\n"
        printf "${D}  2. Buka 'codeer_forge.html' pakai Chrome.${N}\n"
      fi
    else
      printf "${R}  [!] Pilihan tidak valid. Masukkan 9 atau 0.${N}\n"
      sleep 1
    fi
    
    echo ""
    printf "${D}  Tekan ${W}Enter${D} untuk melanjutkan...${N}"
    read
  done
}


# ==========================================
# 17 - 18 : KEAMANAN
# ==========================================

mod_audit() {
  while true; do
    header "17. SECURITY AUDIT"
    echo -e "${Y}  [*] Memulai pemindaian...${N}\n"
    spin "Cek Spyware (Aksesibilitas)" 2
    if command -v settings >/dev/null 2>&1; then
      ACC=$(settings get secure enabled_accessibility_services 2>/dev/null)
      if [ -z "$ACC" ] || [ "$ACC" = "null" ]; then
        echo -e "${G}  [✓] Aksesibilitas: Aman${N}"
      else
        echo -e "${R}  [!] Ada akses Aksesibilitas!${N}"
        if command -v pm >/dev/null 2>&1; then
          local pkgs=$(echo "$ACC" | tr ':' '\n')
          for pkg in $pkgs; do
            if [ -n "$pkg" ]; then
              local appname=$(pm dump "$pkg" 2>/dev/null | grep -m 1 "application-label:" | cut -d ':' -f 2 | sed 's/^[ \t]*//')
              [ -n "$appname" ] && echo -e "${C}      -> ${W}$appname${N}" || echo -e "${C}      -> ${D}Unknown${N}"
            fi
          done
        fi
      fi
    else echo -e "${D}  [-] Cek Aksesibilitas: Dilewati${N}"; fi
    echo ""
    spin "Cek File Asing" 1
    BAD_FILES=$(find $HOME -type f \( -name "*.exe" -o -name "*.bat" -o -name "*.vbs" \) 2>/dev/null | wc -l)
    if [ "$BAD_FILES" -eq 0 ]; then
      echo -e "${G}  [✓] File Termux: Bersih${N}"
    else echo -e "${Y}  [!] Ada $BAD_FILES file asing.${N}"; fi
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

mod_password() {
  while true; do
    header "18. PASS GENERATOR"
    spin "Menyiapkan" 1
    printf "${Y}  Panjang (8-64) > ${N}"
    read -r len
    if ! [[ "$len" =~ ^[0-9]+$ ]] || [ "$len" -lt 8 ] || [ "$len" -gt 64 ]; then
      printf "${R}  [!] Pakai default 16.${N}\n"; len=16
    fi
    spin "Membuat" 1
    local pass=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c "$len")
    printf "${C}  ┌──────────────────────────────────────┐${N}\n"
    printf "${C}  │${G}  %-34s  ${C}│${N}\n" "$pass"
    printf "${C}  └──────────────────────────────────────┘${N}\n"
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}

# ==========================================
# 19 : WIFI ANALYZER (SPEED TEST UPDATE)
# ==========================================
mod_wifi() {
  while true; do
    header "19. WIFI ANALYZER"
    
    spin "Memindai jaringan lokal" 1
    local ip_addr=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    
    echo -e "${G}  [*] Menguji kecepatan (harap tunggu)...${N}"
    # Tes kecepatan download (diubah ke Mbps)
    local result=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 5 http://speedtest.tele2.net/10MB.zip)
    # Konversi byte/s ke Megabit/s (x8 / 1000000)
    local speed_mbps=$(awk "BEGIN {print ($result * 8) / 1000000}")
    
    echo ""
    printf "${C}  ┌──────────────────────────────────────┐${N}\n"
    printf "${C}  │${N} ${D}IP Lokal  :${N} ${G}%-23s${N} ${C}│${N}\n" "$ip_addr"
    
    if [ -n "$speed_mbps" ] && [ "$speed_mbps" != "0" ]; then
      printf "${C}  │${N} ${D}Kecepatan :${N} ${Y}%-19s${N} ${C}│${N}\n" "$(printf "%.2f" $speed_mbps) Mbps"
      printf "${C}  │${N} ${D}Status    :${N} ${G}%-23s${N} ${C}│${N}\n" "Terhubung (Online)"
    else
      printf "${C}  │${N} ${D}Kecepatan :${N} ${R}%-19s${N} ${C}│${N}\n" "Gagal / Offline"
      printf "${C}  │${N} ${D}Status    :${N} ${R}%-23s${N} ${C}│${N}\n" "Tidak ada koneksi"
    fi
    printf "${C}  └──────────────────────────────────────┘${N}\n"
    
    footer
    read -r opt
    [ "$opt" = "0" ] && break
  done
}


# ==== DASHBOARD UTAMA ====
menu() {
while true; do
  clear
  echo -e "${C}  ╔════════════════════════════════════════╗"
  echo -e "${C}  ║${M}   ██████╗ ██████╗ ██████╗ ███████╗   ${C}║"
  echo -e "${C}  ║${B}  ██╔════╝██╔═══██╗██╔══██╗██╔════╝   ${C}║"
  echo -e "${C}  ║${G}  ██║     ██║   ██║██║  ██║█████╗     ${C}║"
  echo -e "${C}  ║${Y}  ██║     ██║   ██║██║  ██║██╔══╝     ${C}║"
  echo -e "${C}  ║${R}  ╚██████╗╚██████╔╝██████╔╝███████╗   ${C}║"
  echo -e "${C}  ║${D}   ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝   ${C}║"
  echo -e "${C}  ╠════════════════════════════════════════╣"
  echo -e "${C}  ║${W}            Cyberpunk Edition           ${C}║"
  echo -e "${C}  ╚════════════════════════════════════════╝${N}"
  echo ""

  printf "${M}  ╔════════════════════════════════════════╗${N}\n"
  printf "${M}  ║${C}  [ SISTEM ]                            ${M}║${N}\n"
  printf "${M}  ║${N}  ${C}01.${W} Device Info    ${C}02.${W} RAM            ${M}║${N}\n"
  printf "${M}  ║${N}  ${C}03.${W} CPU & Temp     ${C}04.${W} Storage        ${M}║${N}\n"
  printf "${M}  ║${N}  ${C}05.${W} Battery Status ${C}06.${W} List App       ${M}║${N}\n"
  printf "${M}  ╠════════════════════════════════════════╣${N}\n"
  printf "${M}  ║${Y}  [ JARINGAN ]                          ${M}║${N}\n"
  printf "${M}  ║${N}  ${Y}07.${W} Local Network  ${Y}08.${W} Sensor HP      ${M}║${N}\n"
  printf "${M}  ║${N}  ${Y}09.${W} Public IP      ${Y}10.${W} Top Big Files  ${M}║${N}\n"
  printf "${M}  ║${N}  ${Y}11.${W} Uptime & Load  ${Y}12.${W} Speedtest      ${M}║${N}\n"
  printf "${M}  ╠════════════════════════════════════════╣${N}\n"
  printf "${M}  ║${G}  [ UTILITAS & KEAMANAN ]               ${M}║${N}\n"
  printf "${M}  ║${N}  ${G}13.${W} Battery Health ${G}14.${W} Clean Cache    ${M}║${N}\n"
  printf "${M}  ║${N}  ${G}15.${W} Find File      ${G}16.${W} HTML Forge     ${M}║${N}\n"
  printf "${M}  ║${N}  ${R}17.${W} Security Audit ${G}18.${W} Pass Generator ${M}║${N}\n"
  printf "${M}  ║${N}  ${G}19.${W} WiFi Analyzer                         ${M}║${N}\n"
  printf "${M}  ╠════════════════════════════════════════╣${N}\n"
  printf "${M}  ║${N}  ${R}00.${W} EXIT SYSTEM                        ${M}║${N}\n"
  printf "${M}  ╚════════════════════════════════════════╝${N}\n\n"

  printf "${D}       ─── System Coded by Pinztok ───${N}\n\n"
  printf "${Y}  ➤ ${W}root@codeer:~# ${N}"
  read -r o
  echo ""

  case $o in
    1|01) mod_info;;
    2|02) mod_mem;;
    3|03) mod_cpu;;
    4|04) mod_disk;;
    5|05) mod_battery_status;;
    6|06) mod_app;;
    7|07) mod_net;;
    8|08) mod_sensor;;
    9|09) mod_ip;;
    10) mod_bigfiles;;
    11) mod_uptime_load;;
    12) mod_speedtest;;
    13) mod_battery_health;;
    14) mod_clean_cache;;
    15) mod_find_file;;
    16) mod_html_forge;;
    17) mod_audit;;
    18) mod_password;;
    19) mod_wifi;;
    0|00) clear; printf "${R}  System Terminated. Bye XO! 👋${N}\n"; exit 0;;
    *) printf "${R}  [!] Command not found.${N}\n"; sleep 1;;
  esac
done
}

# ==== BOOT SEQUENCE ====
clear
spin "Memuat protokol keamanan" 1
spin "Menyiapkan Dashboard CODEER" 1
printf "\n${M}  ╔════════════════════════════════════════╗${N}\n"
printf "${M}  ║${C}          SYSTEM INITIALIZED            ${M}║${N}\n"
printf "${M}  ║${D}              by Pinztok                ${M}║${N}\n"
printf "${M}  ╚════════════════════════════════════════╝${N}\n"
sleep 1.5
menu
