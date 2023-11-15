#!/bin/bash

SD_Unlocker_File=/home/deck/SD_Unlocker
Current_Bios_Version=`sudo dmidecode -s bios-version`
apu_name=`sudo dmidecode -s system-family`
processor_version=`sudo dmidecode -s processor-version`
Backup_Bios_File_Name="bios_backup_$Current_Bios_Version.bin".$(date "+%y%m%d%H%M")
Backup_Bios_File=/home/deck/$Backup_Bios_File_Name
Jupiter_bios=/usr/share/jupiter_bios/
Bios_Size=17778888   # 바이오스 파일 사이즈 (byte)
COLOR_1="\033[1;34m"
COLOR_2="\033[1;31m"
COLOR_END="\033[0m"


# 0 - SD_Unlocker, 1 - 110 Bios, 2 - 116 Bios, 3 - 118 Bios, 4 - 119 Bios
# https://gitlab.com/evlaV/jupiter-PKGBUILD#valve-official-steam-deck-jupiter-release-bios-database
Link=("https://github.com/Ma-cchiato/deck_bios_downgrade/raw/main/SD_Unlocker" "https://gitlab.com/evlaV/jupiter-hw-support/-/raw/0660b2a5a9df3bd97751fe79c55859e3b77aec7d/usr/share/jupiter_bios/F7A0110_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/38f7bdc2676421ee11104926609b4cc7a4dbc6a3/usr/share/jupiter_bios/F7A0116_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/f79ccd15f68e915cc02537854c3b37f1a04be9c3/usr/share/jupiter_bios/F7A0118_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/bc5ca4c3fc739d09e766a623efd3d98fac308b3e/usr/share/jupiter_bios/F7A0119_sign.fd")

Bios_List=("F7A0110" "F7A0116" "F7A0118" "F7A0119")

log() {
local log_msg="$1"
if [ "$log_enabled" = true ]; then
	if [ -n "$log_File" ]; then
        echo "$log_msg" >> "$log_File"
    else
        echo "$log_msg" >> /dev/null
    fi
fi
}

log_enable() {

log_enabled=true
#log_File_Name="bios_downgrader.log.$(date "+%y%m%d%H%M")"
log_File_Name="bios_downgrader.log"
log_File="/home/deck/$log_File_Name"
echo "logging start"
echo -e "log file >> $log_File\n"
touch $log_File
#cat /dev/null > $log_File
echo -e "\n===========================================" >> $log_File
echo -e "\nbios downgrader log" >> $log_File
echo -e "Run Time: $(date "+%Y-%m-%d %H:%M:%S")\n" >> $log_File
}


check_model() {
if [ "$apu_name" == "Aerith" ] && [ "$processor_version" == "AMD Custom APU 0405" ]; then
	echo -e "\nYour device is LCD model."
	echo -e "Supported model\n"
 	log "Device is LCD model"
else
	echo -e "\nYour device is NOT LCD model."
 	echo -e "OLED models are not yet supported.\n"
 	log "Device is NOT LCD model"
  	exit 0
fi
}

# Function to perform BIOS backup
perform_bios_backup() {
if [ ! -f $Backup_Bios_File ]; then
# 기존 바이오스 백업, 복구 가이드는 https://gall.dcinside.com/mgallery/board/view/?id=steamdeck&no=91558 참고
# If you're debugging, comment out the following lines (to save testing time)
sudo /usr/share/jupiter_bios_updater/h2offt $Backup_Bios_File -O
	if [ -f $Backup_Bios_File ]; then
		log "Bios Backup File: $Backup_Bios_File"
		echo "바이오스 백업 파일 생성 완료 ===>" $Backup_Bios_File_Name
		echo "바이오스 백업 파일 생성 완료 ===>" $Backup_Bios_File_Name
	else
		log "Failed to create Bios Backup File"
		echo "바이오스 백업 파일 생성 실패"
		echo "바이오스 백업 파일 생성 실패"
	fi
fi
}

# Function to install SD Unlocker
install_sd_unlocker() {
log "Bios Version: $Current_Bios_Version"
echo "Bios Version: $Current_Bios_Version"
if [ $Current_Bios_Version == ${Bios_List[0]} ]||[ $Current_Bios_Version == ${Bios_List[1]} ]; then
	log "Install SD Unlocker"
	sudo $SD_Unlocker_File
	echo "SD_Unlocker is Installed"
else
	log "Not install SD Unlocker (Bios Version is not 110 or 116)"
	echo "SD_Unlocker is Not Installed (Support Bios Version is 110, 116)"
fi
}

help_command(){
echo -e "\nAvailable options\n"
echo -e "Bios Backup: -B, -b"
echo -e "Check Model: -C, -c"
echo -e "Install SD Unlocker: -S, -s"
echo -e "Boot Bios Menu: -M, -m"
}

# Logging is disabled by default
log_enabled=false
log_File=""

# logging enable option is -l
while getopts "lbsmchBSMCH" opt; do
  case $opt in
    l)
      log_enable
      ;;
    b)
      perform_bios_backup
      exit 0
      ;;
    B)
      perform_bios_backup
      exit 0
      ;;
    s)
      install_sd_unlocker
      exit 0
      ;;
    S)
      install_sd_unlocker
      exit 0
      ;;
	M)
      sudo systemctl reboot --firmware-setup
      exit 0
      ;;
	m)
      sudo systemctl reboot --firmware-setup
      exit 0
      ;;
    c)
      check_model
      exit 0
      ;;
    C)
      check_model
      exit 0
      ;;
    h)
      help_command
      exit 0
      ;;
    H)
      help_command
      exit 0
      ;;
	\?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check if it is an LCD model
check_model

echo "           Select Bios Version" 
echo "[1] " ${Bios_List[0]} " [2] " ${Bios_List[1]} " [3] " ${Bios_List[2]} " [4] " ${Bios_List[3]} 
read -p "==> " select
if [ $select == "1" ]; then
	Bios_Version=${Bios_List[0]}
	log "$Bios_Version Bios select" 
elif [ $select == "2" ]; then
	Bios_Version=${Bios_List[1]}
	log "$Bios_Version Bios select" 
elif [ $select == "3" ]; then
	Bios_Version=${Bios_List[2]}
	log "$Bios_Version Bios select" 
elif [ $select == "4" ]; then
	Bios_Version=${Bios_List[3]}
	log "$Bios_Version Bios select"
else
	log "Decline Bios Select: $select" 
	echo "Process terminated"
	echo "No change to bios"
	exit
fi

Bios_File=/home/deck/$Bios_Version"_sign.fd"
log "Destination File is $Bios_File"

echo -e "Your Current Bios Version is ["$COLOR_1 $Current_Bios_Version $COLOR_END"]"
echo -e "Selected Bios Version is     ["$COLOR_2 $Bios_Version $COLOR_END"]"
log "Current Bios is $Current_Bios_Version"
log "Selected Bios is $Bios_Version" 
read -p "Are you Sure? (Enter y to continue) " reply
if [ "$reply" == "y" ] || [ "$reply" == "Y" ]; then
    log "Accept Bios Update: $reply"
else
    log "Decline Bios update: $reply"
    echo "Process terminated"
    echo "No change to bios"
    exit
fi

max_download_try=3  # 최대 시도 횟수
downloaded=false

for ((try = 1; try <= max_download_try; try++)); do
    if [ ! -f "$Bios_File" ] || [ ! $(stat -c %s "$Bios_File") -eq $Bios_Size ]; then
        echo "Unable to verify file. Downloading Bios File... (Try $try)"
        log "Unable to verify file. Bios File is missing or Bios File size is different. (Try $try)"
        rm -rf "$Bios_File"
        rm -rf "$SD_Unlocker_File"
        wget "${Link[0]}" -O "$SD_Unlocker_File"
        if [ "$Bios_Version" == "${Bios_List[0]}" ]; then
            log "Downloading Bios File ==> $Bios_File"
			wget "${Link[1]}" -O "$Bios_File"
        elif [ "$Bios_Version" == "${Bios_List[1]}" ]; then
            log "Downloading Bios File ==> $Bios_File"
			wget "${Link[2]}" -O "$Bios_File"
        elif [ "$Bios_Version" == "${Bios_List[2]}" ]; then
            log "Downloading Bios File ==> $Bios_File"
			wget "${Link[3]}" -O "$Bios_File"
        elif [ "$Bios_Version" == "${Bios_List[3]}" ]; then
            log "Downloading Bios File ==> $Bios_File"
			wget "${Link[4]}" -O "$Bios_File"
        fi
        if [ -f "$Bios_File" ] && [ $(stat -c %s "$Bios_File") -eq $Bios_Size ]; then
            downloaded=true
            echo "Bios File Download Successful"
            log "Bios File Download Successful. $Bios_File, $(stat -c %s $Bios_File)"
            break
        else
            echo "Bios File Download Failed (Try $try)"
            log "Bios File Download Failed (Try $try)"
        fi
    else
        echo "Bios File Already Exists and Matches the Expected Size"
        log "Bios File Already Exists and Matches the Expected Size. $Bios_File, $(stat -c %s $Bios_File)"
        downloaded=true
        break
    fi
done

if [ "$downloaded" != true ]; then
    echo "Bios File Download Failed After $max_download_try Tries."
    log "Bios File Download Failed After $max_download_try Tries"
    exit 1
fi

echo "Bios File Check Complete ===> [$Bios_File]"
log "Bios File Checked: $Bios_File, $(stat -c %s $Bios_File)"

perform_bios_backup

sudo chmod +x $SD_Unlocker_File
sudo steamos-readonly disable
log "Steam OS Read Only: Disable"
log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
log "$(sudo ls -l /usr/share/jupiter_bios/) << If count is zero, the delete was successful."
echo "Delete Old Bios File From jupiter_bios"
if [ $Bios_Version == ${Bios_List[0]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_List[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $Jupiter_bios${Bios_List[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_List[0]} "Bios File to jupiter_bios ===> "${Bios_List[1]}"_sign.fd"
	echo "Copy "${Bios_List[0]} "Bios File to jupiter_bios ===> "${Bios_List[2]}"_sign.fd"
	log "Copying two files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_List[1]} ]; then
	#sudo cp $Bios_File $Jupiter_bios${Bios_List[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $Jupiter_bios${Bios_List[2]}"_sign.fd" # For SteamOS 3.6 
	#echo "Copy "${Bios_List[1]} "Bios File to jupiter_bios ===> "${Bios_List[1]}"_sign.fd"
	echo "Copy "${Bios_List[1]} "Bios File to jupiter_bios ===> "${Bios_List[2]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_List[2]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_List[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_List[2]} "Bios File to jupiter_bios ===> "${Bios_List[2]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
	#echo "Not Copied Bios File"
elif [ $Bios_Version == ${Bios_List[3]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_List[3]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_List[3]} "Bios File to jupiter_bios ===> "${Bios_List[3]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
	#echo "Not Copied Bios File"
fi
sudo steamos-readonly enable
log "Steam OS Read Only: Enable"

install_sd_unlocker

log "$(sudo /usr/share/jupiter_bios_updater/h2offt -SC)"
log "Bios information to update.. [ Update to $Bios_Version, Use File: $Bios_File ]"
# If you're debugging, comment out the following lines (to save testing time)
sudo /usr/share/jupiter_bios_updater/h2offt $Bios_File
