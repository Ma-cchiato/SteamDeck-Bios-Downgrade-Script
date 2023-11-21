#!/bin/bash

jupiter_Unlock_File=/home/deck/jupiter_unlock
jupiter_tool=/home/deck/jupiter_bios_tool.py
jupiter_bios=/usr/share/jupiter_bios/
Current_Bios_Version=`sudo dmidecode -s bios-version`
apu_name=`sudo dmidecode -s system-family`
#processor_version=`sudo dmidecode -s processor-version`
Backup_Bios_File_Name="bios_backup_$Current_Bios_Version.$(date "+%y%m%d%H%M").bin"
Backup_Bios_File="/home/deck/$Backup_Bios_File_Name"
Bios_Size_l=17778888   # bios file size (LCD)
Bios_Size_o=17778936   # bios file size (OLED)
COLOR_1="\033[1;34m"
COLOR_2="\033[1;31m"
COLOR_3="\033[1;33m"
COLOR_END="\033[0m"


# 0 - 110 Bios, 1 - 116 Bios, 2 - 118 Bios, 3 - 119 Bios
# LCD Bios File https://gitlab.com/evlaV/jupiter-PKGBUILD#valve-official-steam-deck-jupiter-release-bios-database

# 0 - 105 Bios 
# OLED Bios File https://gitlab.com/evlaV/jupiter-PKGBUILD#steam-deck-oled-galileo-f7g-release-bios
# SD Unlocker is removed
Link_l=("https://gitlab.com/evlaV/jupiter-hw-support/-/raw/0660b2a5a9df3bd97751fe79c55859e3b77aec7d/usr/share/jupiter_bios/F7A0110_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/38f7bdc2676421ee11104926609b4cc7a4dbc6a3/usr/share/jupiter_bios/F7A0116_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/f79ccd15f68e915cc02537854c3b37f1a04be9c3/usr/share/jupiter_bios/F7A0118_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/bc5ca4c3fc739d09e766a623efd3d98fac308b3e/usr/share/jupiter_bios/F7A0119_sign.fd")

Link_o=("https://gitlab.com/evlaV/jupiter-hw-support/-/raw/332fcc2fbfcb3a2a31bba5363c0b22cdc1f66822/usr/share/jupiter_bios/F7G0105_sign.fd")

Link_t=("https://gitlab.com/evlaV/jupiter-PKGBUILD/-/raw/master/bin/jupiter-bios-unlock" "https://gitlab.com/evlaV/jupiter-PKGBUILD/-/raw/master/jupiter-bios-tool.py?inline=false")

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
echo "Start logging"
echo -e "log file >> $log_File\n"
touch $log_File
#cat /dev/null > $log_File
echo -e "\n===========================================" >> $log_File
echo -e "\nbios downgrader log" >> $log_File
echo -e "Run Time: $(date "+%Y-%m-%d %H:%M:%S")\n" >> $log_File
}


check_model() {
if [[ "${Current_Bios_Version}" == *"F7A"* ]] || [ "$apu_name" == "Aerith" ]; then
	#echo $Current_Bios_Version
	#echo $apu_name
	current_device=${Device_List[0]}
	echo -e "\nYour device is $current_device."
	echo -e "\n"
	log "Device is ${current_device}"
	device_flag=1
elif [[ "${Current_Bios_Version}" == *"F7G"* ]] || [ "$apu_name" == "Sephiroth" ]; then
	#echo $Current_Bios_Version
	#echo $apu_name
	current_device=${Device_List[1]}
	echo -e "\nYour device is ${current_device}."
	echo -e "${current_device} models are still in testing.\n"
	log "Device is ${current_device}"
	device_flag=2
	#exit 0
else
	echo "Failed to Check (Unknown Device)"
	log "Failed to Check (Unknown Device)"
	exit 1
fi
}

jupiter_tool () {

if [ ! -f $jupiter_Unlock_File ] || [ ! -f $jupiter_tool ]; then
    rm -rf "$jupiter_Unlock_File"
	rm -rf "$jupiter_tool"
	# Download jupiter-bios-unlock, jupiter-bios-tool
	log "Downloading jupiter_unlock file ==> $jupiter_Unlock_File"
	wget "${Link_t[0]}" -O "$jupiter_Unlock_File"
	log "Downloading jupiter_bios_tool file ==> $jupiter_tool"
	wget "${Link_t[1]}" -O "$jupiter_tool"
else
	echo "jupiter unlock file, jupiter bios tool is already downloaded"
fi

echo -e "\n" 
echo -e "     Select the jupiter Bios Tool Option\n" 
echo "[1] BACKUP_UID_TO_FILE   [2] GENERATE_UID_TO_FILE"
echo "[3] INJECT_UID_FROM_FILE [4] REMOVE_UID_FROM_FILE"
echo "[5] TRIMMING             [6] HELP"
echo "[7] Analyze/Verify BIOS  [8] EXIT/PASS"
echo -e "\n"
read -p "==> " b_opt

if [ $b_opt == "1" ]; then
	log "Tool $b_opt select"
	if [ -f $Backup_Bios_File ]; then
		selected_bios=${Backup_Bios_File}
		echo $selected_bios
	else
		find_bios_file
	fi
	if [[ "${Current_Bios_Version}" == *"F7A"* ]] || [ "$apu_name" == "Aerith" ]; then
		python $jupiter_tool $find_result $find_result.UID_backup.bin -b --F7A
	elif [[ "${Current_Bios_Version}" == *"F7G"* ]] || [ "$apu_name" == "Sephiroth" ]; then
		echo $selected_bios
		python $jupiter_tool $selected_bios -b $selected_bios.UID_backup.bin
	fi

elif [ $b_opt == "2" ]; then
	log "Tool $b_opt select"
	if [ -f $Backup_Bios_File ]; then
		selected_bios=${Backup_Bios_File}
		echo $selected_bios
	else
		find_bios_file
	fi
	python $jupiter_tool -g $selected_bios-UID_generated.bin

elif [ $b_opt == "3" ]; then
	log "Tool $b_opt select"
	if [ -f $Backup_Bios_File ]; then
		selected_bios=${Backup_Bios_File}
		echo $selected_bios
	else
		find_bios_file
	fi
	python $jupiter_tool $selected_bios $selected_bios-UID_injected.bin -i $sel_inject_uid

elif [ $b_opt == "4" ]; then
	log "Tool $b_opt select"
	if [ -f $Backup_Bios_File ]; then
		selected_bios=${Backup_Bios_File}
		echo $selected_bios
	else
		find_bios_file
	fi
	python $jupiter_tool $selected_bios $selected_bios-UID_removed.bin -r

elif [ $b_opt == "5" ]; then
	log "Tool $b_opt select"
	if [ -f $Backup_Bios_File ]; then
		selected_bios=${Backup_Bios_File}
		echo $selected_bios
	else
		find_bios_file
	fi
	python $jupiter_tool $selected_bios $selected_bios-trimmed.bin

elif [ $b_opt == "6" ]; then
	log "Tool $b_opt select"
	python $jupiter_tool -h

elif [ $b_opt == "7" ]; then
	log "Tool $b_opt select"
	if [ -f $Backup_Bios_File ]; then
		selected_bios=${Backup_Bios_File}
		echo $selected_bios
	else
		find_bios_file
	fi
	python $jupiter_tool $selected_bios

elif [ $b_opt == "8" ]; then
	echo "jupiter bios tool terminated"

else
	log "Decline jupiter Bios Tool Option Select: $b_opt" 
	echo "jupiter bios tool terminated"
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

# jupiter-bios-tool 
# https://gitlab.com/evlaV/jupiter-PKGBUILD#-steam-deck-jupiter-bios-tool-jupiter-bios-tool-

	if [ -f $Backup_Bios_File ]; then
		log "Bios Backup File: $Backup_Bios_File"
		echo "Finished creating the bios backup file ===>" $Backup_Bios_File_Name
		read -p "Use jupiter-bios-tool? (Enter y to continue) " use_tool
		if [ $use_tool == "y" ] || [ $use_tool == "Y" ]; then
			jupiter_tool
		fi
	else
		log "Failed to create Bios Backup File"
		echo "Failed to create Bios Backup File"
	fi
fi
echo -e "Ending a bios backup\n"
echo -e "\n======================================\n"
}

# Unlock the bios with jupiter-bios-unlock
jupiter_unlock () {
if [ $Current_Bios_Version == ${Bios_lcd[0]} ]||[ $Current_Bios_Version == ${Bios_lcd[1]} ]; then
	# jupiter-bios-unlock to replace sd unlocker 
	sudo chmod +x $jupiter_Unlock_File
	log "Unlock the bios with jupiter-bios-unlock"
	sudo $jupiter_Unlock_File
	echo "BIOS is unlocked with jupiter-bios-unlock"
else
	log "BIOS is not unlocked (Supported only Steam Deck Lcd or Bios Version is not 110 or 116)"
	echo "BIOS is not unlocked (Supported only Steam Deck Lcd or Bios Version is not 110 or 116)"
fi
}

find_bios_file () {

# Find bios files with .rom, .fd, .bin extensions
find_result=($(find /home/deck -maxdepth 1 -type f \( -name "*.rom" -o -name "*.fd" -o -name "*.bin" \)))

# output a list of files stored in an array
for ((i=0; i<${#find_result[@]}; i++)); do
	echo "[$((i+1))] ${find_result[$i]}"
done

# Prompt user to select a BIOS file
read -p "Select Source Bios file Number... " sel_bios_number

# Check if the input is a valid number
if [[ $sel_bios_number =~ ^[0-9]+$ ]]; then
    index=$((sel_bios_number - 1))
    
    # Check if the index is valid
    if ((index >= 0 && index < ${#find_result[@]})); then
      selected_bios=${find_result[index]}
      echo "You selected: $selected_bios"
    else
      echo "Invalid selection. Please enter a valid index."
    fi
else
    echo "Invalid input. Please enter a number."
fi

# If the user chooses option 3, prompt for another selection
if [ $b_opt == "3" ]; then
    read -p "Select Source Bios file Number... " sel_inject_uid_number

    # Check if the input is a valid number
    if [[ $sel_inject_uid_number =~ ^[0-9]+$ ]]; then
      index=$((sel_inject_uid_number - 1))

      # Check if the index is valid
      if ((index >= 0 && index < ${#find_result[@]})); then
        sel_inject_uid=${find_result[index]}
        echo "Selected BIOS file for injection: $sel_inject_uid"
      else
        echo "Invalid selection. Please enter a valid index."
        exit 1
      fi
	else
      echo "Invalid input. Please enter a number."
      exit 1
    fi
fi
}

help_command(){
echo -e "\nAvailable options\n"
echo -e "Bios Backup: -B, -b"
echo -e "Check Model: -C, -c"
echo -e "BIOS Unlock (110 or 116 only): -U, -u"
echo -e "Boot Bios Menu: -M, -m"
echo -e "jupiter bios tool: -T, -t"
}

# Logging is disabled by default
log_enabled=false
log_File=""

# logging enable option is -l
while getopts "lbsmchtBSMCHT" opt; do
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
	  jupiter_unlock
      exit 0
      ;;
    S)
	  jupiter_unlock
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
	T)
      use_tool=1
      jupiter_tool
      exit 0
      ;;
	t)
      use_tool=1
      jupiter_tool
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

max_download_try=3  # Maximum attempts
downloaded=false


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
        rm -rf "$jupiter_Unlock_File"
		rm -rf "$jupiter_tool"
        # Check the device flag to determine which BIOS file to download
        if [ $device_flag == 1 ]; then
			# Download jupiter-bios-unlock, jupiter-bios-tool
			log "Downloading jupiter_unlock file ==> $jupiter_Unlock_File"
			wget "${Link_t[0]}" -O "$jupiter_Unlock_File"
			log "Downloading jupiter_bios_tool file ==> $jupiter_tool"
			wget "${Link_t[1]}" -O "$jupiter_toole"
            # Download LCD BIOS file
			log "Downloading Bios File ==> $Bios_File"            
			wget "${Link_l[$select - 1]}" -O "$Bios_File"
        elif [ $device_flag == 2 ]; then
            # Download OLED BIOS file
            log "Downloading Bios File ==> $Bios_File"
			wget "${Link_o[$select - 1]}" -O "$Bios_File"
        else
            log "Invalid device_flag value. Exiting..."
            echo "Invalid device_flag value. Exiting..."
            exit 1
        fi

        if [ -f "$Bios_File" ] && [ $(stat -c %s "$Bios_File") -eq $Bios_Size ]; then
            downloaded=true
            log "Bios File Download Successful. $Bios_File, $(stat -c %s $Bios_File)"
            echo "Bios File Download Successful"
            break
        else
            log "Bios File Download Failed (Try $try)"
            echo "Bios File Download Failed (Try $try)"
        fi
    else
        log "Bios File Already Exists and Matches the Expected Size. $Bios_File, $(stat -c %s $Bios_File)"
        echo "Bios File Already Exists and Matches the Expected Size"
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

sudo steamos-readonly disable
log "Steam OS Read Only: Disable"
if [ $device_flag == 1 ];then
	#sudo chmod +x $Jupiter_Unlock_File
	sudo chmod +x $SD_Unlocker_File
	jupiter_unlock
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
	sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
#elif [ $device_flag == 2 ];then
#	log "$(sudo ls -l /usr/share/jupiter_bios/F7G*.fd)"
#	sudo rm -rf /usr/share/jupiter_bios/F7G*.fd
fi
log "$(sudo ls -l /usr/share/jupiter_bios/) << If count is zero, the delete was successful."
echo "Delete Old Bios File From jupiter_bios"
if [ $Bios_Version == ${Bios_lcd[0]} ]; then
	sudo cp $Bios_File $jupiter_bios${Bios_lcd[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $jupiter_bios${Bios_lcd[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_lcd[0]} "Bios File to jupiter_bios ===> "${Bios_lcd[1]}"_sign.fd"
	echo "Copy "${Bios_lcd[0]} "Bios File to jupiter_bios ===> "${Bios_lcd[2]}"_sign.fd"
	log "Copying two files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_lcd[1]} ]; then
	#sudo cp $Bios_File $jupiter_bios${Bios_lcd[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $jupiter_bios${Bios_lcd[2]}"_sign.fd" # For SteamOS 3.6 
	#echo "Copy "${Bios_lcd[1]} "Bios File to jupiter_bios ===> "${Bios_lcd[1]}"_sign.fd"
	echo "Copy "${Bios_lcd[1]} "Bios File to jupiter_bios ===> "${Bios_lcd[2]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_lcd[2]} ]; then
	sudo cp $Bios_File $jupiter_bios${Bios_lcd[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_lcd[2]} "Bios File to jupiter_bios ===> "${Bios_lcd[2]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
elif [ $Bios_Version == ${Bios_lcd[3]} ]; then
	sudo cp $Bios_File $jupiter_bios${Bios_lcd[3]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_lcd[3]} "Bios File to jupiter_bios ===> "${Bios_lcd[3]}"_sign.fd"
	log "Copying one files"
	log "$(sudo ls -l /usr/share/jupiter_bios/F7A*.fd)"
fi

if [ $Bios_Version == ${Bios_oled[0]} ]; then
	sudo cp $Bios_File $jupiter_bios${Bios_oled[0]}"_sign.fd" # For OLED SteamDeck 3.5.x ~
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
