#!/bin/bash

SD_Unlocker_File=/home/deck/SD_Unlocker
Current_Bios_Version=`sudo dmidecode -s bios-version`
apu_name=`sudo dmidecode -s system-family`
#processor_version=`sudo dmidecode -s processor-version`
Backup_Bios_File_Name="bios_backup_$Current_Bios_Version.bin".$(date "+%y%m%d%H%M")
Backup_Bios_File="/home/deck/$Backup_Bios_File_Name"
Jupiter_bios=/usr/share/jupiter_bios/
Bios_Size_l=17778888   # bios file size (LCD)
Bios_Size_o=17778936   # bios file size (OLED)
COLOR_1="\033[1;34m"
COLOR_2="\033[1;31m"
COLOR_3="\033[1;33m"
COLOR_END="\033[0m"


# 0 - SD_Unlocker, 1 - 110 Bios, 2 - 116 Bios, 3 - 118 Bios, 4 - 119 Bios
# LCD Bios File https://gitlab.com/evlaV/jupiter-PKGBUILD#valve-official-steam-deck-jupiter-release-bios-database
# OLED Bios File https://gitlab.com/evlaV/jupiter-PKGBUILD#steam-deck-oled-galileo-f7g-release-bios
Link_l=("https://github.com/Ma-cchiato/deck_bios_downgrade/raw/main/SD_Unlocker" "https://gitlab.com/evlaV/jupiter-hw-support/-/raw/0660b2a5a9df3bd97751fe79c55859e3b77aec7d/usr/share/jupiter_bios/F7A0110_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/38f7bdc2676421ee11104926609b4cc7a4dbc6a3/usr/share/jupiter_bios/F7A0116_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/f79ccd15f68e915cc02537854c3b37f1a04be9c3/usr/share/jupiter_bios/F7A0118_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/bc5ca4c3fc739d09e766a623efd3d98fac308b3e/usr/share/jupiter_bios/F7A0119_sign.fd")

Link_o=("https://gitlab.com/evlaV/jupiter-hw-support/-/raw/332fcc2fbfcb3a2a31bba5363c0b22cdc1f66822/usr/share/jupiter_bios/F7G0105_sign.fd")

Bios_lcd=("F7A0110" "F7A0116" "F7A0118" "F7A0119")
Bios_oled=("F7G0105")
Device_List=("Steam Deck LCD" "Steam Deck OLED")
device_flag=0

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
if [[ "${Current_Bios_Version}" == *"F7A"* ]] || [ "$apu_name" == "Aerith" ]; then
	echo $Current_Bios_Version
	echo $apu_name
	current_device=${Device_List[0]}
	echo -e "\nYour device is $current_device."
	echo -e "Supported model\n"
	log "Device is ${current_device}"
	device_flag=1
elif [[ "${Current_Bios_Version}" == *"F7G"* ]] || [ "$apu_name" == "Sephiroth" ]; then
	echo $Current_Bios_Version
	echo $apu_name
	current_device=${Device_List[1]}
	echo -e "\nYour device is ${current_device}."
	echo -e "${current_device} models are not yet supported.\n"
	log "Device is ${current_device}"
	device_flag=2
	#exit 0
else
	echo "Failed to Check (Unknown Device)"
	log "Failed to Check (Unknown Device)"
	exit 1
fi
}

# Function to perform BIOS backup
perform_bios_backup() {
if [ ! -f $Backup_Bios_File ]; then
echo -e "\n======================================"
echo -e "Start a bios backup\n"
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
echo -e "Ending a bios backup\n"
echo -e "\n======================================\n"
}

# Function to install SD Unlocker
install_sd_unlocker() {
if [ $Current_Bios_Version == ${Bios_lcd[0]} ]||[ $Current_Bios_Version == ${Bios_lcd[1]} ]; then
	log "Install SD Unlocker"
	sudo $SD_Unlocker_File
	echo "SD_Unlocker is Installed"
else
	log "Not install SD Unlocker (Supported only Steam Deck Lcd or Bios Version is not 110 or 116)"
	echo "SD_Unlocker is Not Installed (Supported only Steam Deck Lcd or Bios Version is not 110 or 116)"
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
if [ $device_flag == 1 ];then
	echo "[1] " ${Bios_lcd[0]} " [2] " ${Bios_lcd[1]} " [3] " ${Bios_lcd[2]} " [4] " ${Bios_lcd[3]} 
	read -p "==> " select
	if [ $select == "1" ]; then
		Bios_Version=${Bios_lcd[0]}
		log "$Bios_Version Bios select" 
	elif [ $select == "2" ]; then
		Bios_Version=${Bios_lcd[1]}
		log "$Bios_Version Bios select" 
	elif [ $select == "3" ]; then
		Bios_Version=${Bios_lcd[2]}
		log "$Bios_Version Bios select" 
	elif [ $select == "4" ]; then
		Bios_Version=${Bios_lcd[3]}
		log "$Bios_Version Bios select"
	else
		log "Decline Bios Select: $select" 
		echo "Process terminated"
		echo "No change to bios"
		exit 1
	fi
elif [ $device_flag == 2 ];then
	echo "[1] " ${Bios_oled[0]} 
	read -p "==> " select
	if [ $select == "1" ]; then
		Bios_Version=${Bios_oled[0]}
		log "$Bios_Version Bios select" 
	else
		log "Decline Bios Select: $select" 
		echo "Process terminated"
		echo "No change to bios"
		exit 1
	fi
else
	echo "Failed to Check (Unknown device flag)"
	log "Failed to Check (Unknown device flag)"
fi

Bios_File=/home/deck/$Bios_Version"_sign.fd"
log "Destination File is $Bios_File"

echo -e "Your Device is               ["$COLOR_3 $current_device $COLOR_END"]"
echo -e "Your Current Bios Version is ["$COLOR_1 $Current_Bios_Version $COLOR_END"]"
echo -e "Selected Bios Version is     ["$COLOR_2 $Bios_Version $COLOR_END"]"
log "Device is $current_device"
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

#수정할 코드

# Select BIOS file size based on device_flag
if [ $device_flag == 1 ]; then
    Bios_Size=$Bios_Size_l
elif [ $device_flag == 2 ]; then
    Bios_Size=$Bios_Size_o
else
    echo "device_flag is missing."
    log "device_flag is missing."
    exit 1
fi

for ((try = 1; try <= max_download_try; try++)); do
    if [ ! -f "$Bios_File" ] || [ ! $(stat -c %s "$Bios_File") -eq $Bios_Size ]; then
        echo "Unable to verify file. Downloading Bios File... (Try $try)"
        log "Unable to verify file. Bios File is missing or Bios File size is different. (Try $try)"
        rm -rf "$Bios_File"
        rm -rf "$SD_Unlocker_File"
        # Check the device flag to determine which BIOS file to download
        if [ $device_flag == 1 ]; then
			wget "${Link_l[0]}" -O "$SD_Unlocker_File"
            # Download LCD BIOS file
            wget "${Link_l[$select]}" -O "$Bios_File"
			log "Downloading Bios File ==> $Bios_File"
        elif [ $device_flag == 2 ]; then
            # Download OLED BIOS file
            wget "${Link_o[$select - 1]}" -O "$Bios_File"
			log "Downloading Bios File ==> $Bios_File"
        else
            echo "Invalid device_flag value. Exiting..."
            log "Invalid device_flag value. Exiting..."
            exit 1
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

# 수정항 코드 end


if [ "$downloaded" != true ]; then
    echo "Bios File Download Failed After $max_download_try Tries."
    log "Bios File Download Failed After $max_download_try Tries"
    exit 1
fi

echo "Bios File Check Complete ===> [$Bios_File]"
log "Bios File Checked: $Bios_File, $(stat -c %s $Bios_File)"

perform_bios_backup

sudo steamos-readonly disable
log "Steam OS Read Only: Disable"
if [ $device_flag == 1 ];then
	sudo chmod +x $SD_Unlocker_File
	install_sd_unlocker
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
	sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
#elif [ $device_flag == 2 ];then
#	log "$(sudo ls -l /usr/share/jupiter_bios/F7G*.fd)"
#	sudo rm -rf /usr/share/jupiter_bios/F7G*.fd
fi
log "$(sudo ls -l /usr/share/jupiter_bios/) << If count is zero, the delete was successful."
echo "Delete Old Bios File From jupiter_bios"
if [ $Bios_Version == ${Bios_lcd[0]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_lcd[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $Jupiter_bios${Bios_lcd[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_lcd[0]} "Bios File to jupiter_bios ===> "${Bios_lcd[1]}"_sign.fd"
	echo "Copy "${Bios_lcd[0]} "Bios File to jupiter_bios ===> "${Bios_lcd[2]}"_sign.fd"
	log "Copying two files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_lcd[1]} ]; then
	#sudo cp $Bios_File $Jupiter_bios${Bios_lcd[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $Jupiter_bios${Bios_lcd[2]}"_sign.fd" # For SteamOS 3.6 
	#echo "Copy "${Bios_lcd[1]} "Bios File to jupiter_bios ===> "${Bios_lcd[1]}"_sign.fd"
	echo "Copy "${Bios_lcd[1]} "Bios File to jupiter_bios ===> "${Bios_lcd[2]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_lcd[2]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_lcd[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_lcd[2]} "Bios File to jupiter_bios ===> "${Bios_lcd[2]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
	#echo "Not Copied Bios File"
elif [ $Bios_Version == ${Bios_lcd[3]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_lcd[3]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_lcd[3]} "Bios File to jupiter_bios ===> "${Bios_lcd[3]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
	#echo "Not Copied Bios File"
fi

if [ $Bios_Version == ${Bios_oled[0]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_oled[0]}"_sign.fd" # For OLED SteamDeck 3.5.x ~
	echo "Copy "${Bios_oled[0]} "Bios File to jupiter_bios ===> "${Bios_oled[0]}"_sign.fd"
	log "Copying one files."
	log "$(sudo ls -l /usr/share/jupiter_bios/F7G*.fd)"
fi

sudo steamos-readonly enable
log "Steam OS Read Only: Enable"


log "$(sudo /usr/share/jupiter_bios_updater/h2offt -SC)"
log "Bios information to update.. [ Update to $Bios_Version, Use File: $Bios_File ]"
# If you're debugging, comment out the following lines (to save testing time)
#sudo /usr/share/jupiter_bios_updater/h2offt $Bios_File
