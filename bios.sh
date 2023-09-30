#!/bin/bash

SD_Unlocker_File=/home/deck/SD_Unlocker
Backup_Bios_File_Name="bios_backup.fd".$(date "+%y%m%d%H%M")
Backup_Bios_File=/home/deck/$Backup_Bios_File_Name
Jupiter_bios=/usr/share/jupiter_bios/
Bios_Size=17778888   # 바이오스 파일 사이즈 (byte)
Current_Bios_Version=`sudo dmidecode -s bios-version`
COLOR_1="\033[1;34m"
COLOR_2="\033[1;31m"
COLOR_END="\033[0m"

# 0 - SD_Unlocker, 1 - 110 Bios, 2 - 116 Bios, 3 - 118 Bios
# https://gitlab.com/evlaV/jupiter-PKGBUILD#valve-official-steam-deck-jupiter-release-bios-database
Link=("https://github.com/Ma-cchiato/deck_bios_downgrade/raw/main/SD_Unlocker" "https://gitlab.com/evlaV/jupiter-hw-support/-/raw/0660b2a5a9df3bd97751fe79c55859e3b77aec7d/usr/share/jupiter_bios/F7A0110_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/38f7bdc2676421ee11104926609b4cc7a4dbc6a3/usr/share/jupiter_bios/F7A0116_sign.fd"
"https://gitlab.com/evlaV/jupiter-hw-support/-/raw/f79ccd15f68e915cc02537854c3b37f1a04be9c3/usr/share/jupiter_bios/F7A0118_sign.fd")

Bios_List=("F7A0110" "F7A0116" "F7A0118")

echo "           Select Bios Version" 
echo "[1] " ${Bios_List[0]} " [2] " ${Bios_List[1]} " [3] " ${Bios_List[2]} 
read select
if [ $select == "1" ]; then
	Bios_Version=${Bios_List[0]}
elif [ $select == "2" ]; then
	Bios_Version=${Bios_List[1]}
elif [ $select == "3" ]; then
	Bios_Version=${Bios_List[2]}
else
	echo "Process terminated"
	echo "No change to bios"
	exit
fi

Bios_File=/home/deck/$Bios_Version"_sign.fd"
echo -e "Your Current Bios Version is ["$COLOR_1 $Current_Bios_Version $COLOR_END"]"
echo -e "Selected Bios Version is     ["$COLOR_2 $Bios_Version $COLOR_END"]"
echo "Are you Sure? (Enter y to continue)"
read reply
if [ $reply == "y" ]; then
	continue
elif [ $reply == "Y" ]; then
	continue
else
	echo "Process terminated"
	echo "No change to bios"
	exit
fi

if [ ! -f $Bios_File ]; then
	echo "Bios File Missing. Retry Downloading Files"
	rm -rf $Bios_File
	rm -rf $SD_Unlocker_File
	wget ${Link[0]} -O $SD_Unlocker_File
	if [ $Bios_Version == ${Bios_List[0]} ]; then
		wget ${Link[1]} -O $Bios_File
	elif [ $Bios_Version == ${Bios_List[1]} ]; then
		wget ${Link[2]} -O $Bios_File
	elif [ $Bios_Version == ${Bios_List[2]} ]; then
		wget ${Link[3]} -O $Bios_File
	fi
	echo "Bios File Download Complete ===> [" $Bios_File "]"
	
elif [ -f $Bios_File ]; then
	if [ ! $(stat -c %s "$Bios_File") -eq $Bios_Size ]; then
		echo "Bios File Size is Different. Retry Downloading Files"
		rm -rf $Bios_File
		rm -rf $SD_Unlocker_File
		wget ${Link[0]} -O $SD_Unlocker_File
		if [ $Bios_Version == ${Bios_List[0]} ]; then
			wget ${Link[1]} -O $Bios_File
		elif [ $Bios_Version == ${Bios_List[1]} ]; then
			wget ${Link[2]} -O $Bios_File
		elif [ $Bios_Version == ${Bios_List[2]} ]; then
			wget ${Link[3]} -O $Bios_File
		fi
		echo "Bios File Download Complete ===> [" $Bios_File "]"
	fi
	echo "Bios File Check Complete ===> [" $Bios_File "]"
fi

if [ ! -f $Backup_Bios_File ]; then
	# 기존 바이오스 백업, 복구 가이드는 https://gall.dcinside.com/mgallery/board/view/?id=steamdeck&no=91558 참고
	sudo /usr/share/jupiter_bios_updater/h2offt $Backup_Bios_File -O
	if [ -f $Backup_Bios_File ]; then
		echo "바이오스 백업 파일 생성 완료 ===>" $Backup_Bios_File_Name
		echo "바이오스 백업 파일 생성 완료 ===>" $Backup_Bios_File_Name
	else
		echo "바이오스 백업 파일 생성 실패"
		echo "바이오스 백업 파일 생성 실패"
	fi
fi

sudo chmod +x /home/deck/SD_Unlocker
sudo steamos-readonly disable
sudo rm -rf /usr/share/jupiter_bios/F7A*.fd
echo "Delete Old Bios File From jupiter_bios"
if [ $Bios_Version == ${Bios_List[0]} ]; then
	sudo cp $Bios_File $Jupiter_bios${Bios_List[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $Jupiter_bios${Bios_List[2]}"_sign.fd" # For SteamOS 3.6 
	echo "Copy "${Bios_List[0]} "Bios File to jupiter_bios ===> "${Bios_List[1]}"_sign.fd"
	echo "Copy "${Bios_List[0]} "Bios File to jupiter_bios ===> "${Bios_List[2]}"_sign.fd"
elif [ $Bios_Version == ${Bios_List[1]} ]; then
	#sudo cp $Bios_File $Jupiter_bios${Bios_List[1]}"_sign.fd" # For SteamOS 3.5 ~ Stable 
	sudo cp $Bios_File $Jupiter_bios${Bios_List[2]}"_sign.fd" # For SteamOS 3.6 
	#echo "Copy "${Bios_List[1]} "Bios File to jupiter_bios ===> "${Bios_List[1]}"_sign.fd"
	echo "Copy "${Bios_List[1]} "Bios File to jupiter_bios ===> "${Bios_List[2]}"_sign.fd"
elif [ $Bios_Version == ${Bios_List[2]} ]; then
	#sudo cp $Bios_File $Jupiter_bios${Bios_List[2]}"_sign.fd" # For SteamOS 3.6 
	#echo "Copy "${Bios_List[2]} "Bios File to jupiter_bios ===> "${Bios_List[2]}"_sign.fd"
	echo "Not Copied Bios File"
fi
sudo steamos-readonly enable
sudo $SD_Unlocker_File
echo "SD_Unlocker is Installed"
sudo /usr/share/jupiter_bios_updater/h2offt $Bios_File
