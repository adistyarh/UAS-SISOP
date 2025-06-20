#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ---------------------
# ASCII Art Via Figlet
# ---------------------
ascii_welcome() {
    if command -v figlet &> /dev/null; then
        echo -e "${GREEN}"
        figlet -c "UAS SISOP"
        echo -e "${NC}"
    else
        echo -e "${GREEN}***SAMPURASUN SADAYANA!***${NC}"
    fi
}

ascii_goodbye() {
    clear
    echo -e "${YELLOW}"
    echo "╔══════════════════════════════╗"
    echo "║ Udah ya, sekian. Bye!║"
    echo "╚══════════════════════════════╝"
    echo -e "${NC}"
    echo -e "\a"  # beep sound
}

# ---------------------
# Progress Bar
# ---------------------
progress_bar() {
    echo -ne "${YELLOW}Proses sedang berjalan: ["
    for ((i=0; i<=20; i++)); do
        echo -ne "#"
        sleep 0.02
    done
    echo -e "]${NC}\n"
}

# ---------------------
# Efek Mengetik
# ---------------------
type_effect() {
    text="$1"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.01
    done
    echo
}

# ---------------------
# Tampilkan Info OS
# ---------------------
show_os_info() {
    progress_bar
    if [ -f /etc/os-release ]; then
        echo -e "${GREEN}Detail Sistem Operasi:${NC}"
        . /etc/os-release
        echo -e "Nama OS     : $NAME"
        echo -e "Versi       : $VERSION"
        echo -e "ID          : $ID"
        echo -e "Keterangan  : $PRETTY_NAME"
        echo -e ""
    else
        echo -e "${RED}File /etc/os-release tidak ditemukan.${NC}"
    fi
    
    echo -e "${GREEN}Informasi Kernel:${NC}"
    uname -r  # Kernel version

    echo -e "${GREEN}Proses CPU Terakhir:${NC}"
    top -bn1 | grep "Cpu(s)"  # Last CPU process

    echo -e "${GREEN}Penggunaan Memori:${NC}"
    free -h  # Memory usage

    echo -e "${GREEN}Penggunaan Disk:${NC}"
    df -h  # Disk usage
}

# ---------------------
# Tampilkan Waktu Install
# ---------------------
show_install_time() {
    progress_bar
    echo -e "${GREEN}Waktu Perkiraan OS Pertama Kali Diinstall:${NC}"
    if [ -d /var/log/installer ]; then
        sudo find /var/log/installer -type f -printf "%TY-%Tm-%Td %TH:%TM:%TS %p\n" | sort | head -n 1
    elif [ -d /lost+found ]; then
        sudo ls -ld --time=ctime /lost+found | awk '{print $6, $7, $8}'
    else
        echo -e "${RED}Tidak dapat menentukan waktu instalasi.${NC}"
    fi
}

# ---------------------
# Menampilkan Waktu dan Pesan Selamat
# ---------------------
show_time_and_greeting() {
    current_hour=$(date +'%H')
    if [ "$current_hour" -ge 5 ] && [ "$current_hour" -lt 12 ]; then
        greeting="Wilujeng Enjing $USER"
    elif [ "$current_hour" -ge 12 ] && [ "$current_hour" -lt 18 ]; then
        greeting="Wilujeng Siang $USER"
    elif [ "$current_hour" -ge 18 ] && [ "$current_hour" -lt 21 ]; then
        greeting="Wilujeng Sonten $USER"
    else
        greeting="Wilujeng Wengi $USER"
    fi
    
    progress_bar
    echo -e "${GREEN}$greeting! Tanggal dan Waktu Saat Ini:${NC}"
    date
}

# ---------------------
# Menampilkan Informasi Penggunaan Disk
# ---------------------
show_disk_usage() {
    progress_bar
    echo -e "${GREEN}Informasi Penggunaan Disk:${NC}"
    df -h --total
}

# ---------------------
# Menampilkan Informasi Jaringan
# ---------------------
show_network_info() {
    progress_bar
    echo -e "${NC}Informasi Jaringan:${NC}"
    
    # Menampilkan alamat IP dan gateway
    ip_addr=$(hostname -I | awk '{print $1}')
    gateway=$(ip route | grep default | awk '{print $3}')
    netmask=$(ip addr show | grep -m 1 "inet $ip_addr" | awk '{print $2}')
    dns_servers=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}' | paste -sd ", " -)

    echo -e "${GREEN}Alamat IP Lokal:${NC} $ip_addr"
    echo -e "${GREEN}Gateway:${NC} $gateway"
    echo -e "${GREEN}Netmask:${NC} $netmask"
    echo -e "${GREEN}DNS Server(s):${NC} $dns_servers"
    
    # Menampilkan status koneksi
    echo -e "\n${NC}Status Koneksi ke Internet:${NC}"
    if ping -c 1 google.com &> /dev/null; then
        echo -e "${GREEN}Tersambung ke internet.${NC}"
    else
        echo -e "${RED}Tidak tersambung ke internet.${NC}"
    fi
    
    # Menampilkan status koneksi LAN/WIFI
    echo -e "\n${NC}Status Koneksi LAN/WIFI:${NC}"
    nmcli device status
    
    # Mengambil IP Publik untuk lokasi
    public_ip=$(curl -s https://ipinfo.io/ip)

    # Menampilkan lokasi IP menggunakan IP geolocation
    location=$(curl -s "https://ipinfo.io/$public_ip/json" | jq -r '.city + ", " + .region + ", " + .country')

    if [ -n "$location" ] && [ "$location" != ", , " ]; then
        echo -e "\n${NC}Lokasi IP:\n${GREEN}$location"
    else
        echo -e "${RED}Tidak dapat menentukan lokasi IP.${NC}"
    fi
}



# ---------------------
# Menampilkan Informasi Pengguna
# ---------------------
show_user_info() {
    progress_bar
    echo -e "${GREEN}Informasi Pengguna Saat Ini:${NC}"
    echo -e "Username      : $USER"
    echo -e "User ID       : $(id -u)"
    echo -e "Group ID      : $(id -g)"
    echo -e "Nama Lengkap  : $(getent passwd $USER | cut -d: -f5)"
    echo -e "Shell         : $SHELL"
    echo -e "Home Directory: $HOME"
    #echo -e "Tanggal Login : $(last -n 1 $USER | head -n 1 | awk '{print $4, $5, $6, $7}')"
}

# ---------------------
# Menu Utama
# ---------------------
menu() {
    clear
    ascii_welcome
    echo -e "${YELLOW}1.${NC} Tampilkan Kehidupan Saat Ini"
    echo -e "${YELLOW}2.${NC} Tampilkan Daftar Direktori"
    echo -e "${YELLOW}3.${NC} Informasi Jaringan"  
    echo -e "${YELLOW}4.${NC} Tampilkan Detail OS"
    echo -e "${YELLOW}5.${NC} Tampilkan Waktu Install Pertama OS"
    echo -e "${YELLOW}6.${NC} Informasi User"
    echo -e "${YELLOW}7.${NC} Keluar"
    echo ""
    echo -ne "${YELLOW}Pilih opsi [1-7]: ${NC}"
    read pilihan

    case $pilihan in
        1)
            show_time_and_greeting
            ;;
        2)
            progress_bar
            echo -e "${GREEN}Isi Direktori: ${NC}"
            ls -lah --color=auto
            ;;
        3)
            show_network_info  # Panggil fungsi baru untuk informasi jaringan
            ;;
        4)
            show_os_info
            ;;
        5)
            show_install_time
            ;;
        6)
            show_user_info
            ;;
        7)
            ascii_goodbye
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            echo -e "\a"  # beep
            ;;
    esac
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
    menu
}

# ---------------------
# Jalankan
# ---------------------
menu

