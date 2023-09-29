#!/bin/bash

Bios_Version=F7A0110  # 바이오스 버전
Bios_File=/home/deck/$Bios_Version"_sign.fd"
SD_Unlocker_File=/home/deck/SD_Unlocker
Backup_Bios_File_Name="bios_backup.fd".$(date "+%y%m%d%H%M")
Backup_Bios_File=/home/deck/$Backup_Bios_File_Name
Jupiter_bios=/usr/share/jupiter_bios/
Bios_Size=17778888   # 바이오스 파일 사이즈 (byte)

Link=("https://github.com/Ma-cchiato/deck_bios_downgrade/raw/main/SD_Unlocker" "https://gitlab.com/evlaV/jupiter-hw-support/-/raw/0660b2a5a9df3bd97751fe79c55859e3b77aec7d/usr/share/jupiter_bios/F7A0110_sign.fd")


if [ ! -f $Bios_File ]; then
	echo "Bios File Missing. Retry Download File"
	rm -rf $Bios_File
	rm -rf $SD_Unlocker_File
	wget ${Link[1]} -O $Bios_File
	wget ${Link[0]} -O $SD_Unlocker_File
	echo "Bios File Download Complete"
elif [ -f $Bios_File ]; then
	if [ ! $(stat -c %s "$Bios_File") -eq $Bios_Size ]; then
		echo "Bios File Size Different. Retry Download File"
		rm -rf $Bios_File
		rm -rf $SD_Unlocker_File
		wget ${Link[1]} -O $Bios_File
		wget ${Link[0]} -O $SD_Unlocker_File
		echo "Bios File Download Complete"
	fi
	echo "Bios File Check Complete"
fi
if [ ! -f $Backup_Bios_File ]; then
	sudo /usr/share/jupiter_bios_updater/h2offt $Backup_Bios_File -O # 기존 바이오스 백업, 복구 가이드는 https://gall.dcinside.com/mgallery/board/view/?id=steamdeck&no=91558 참고
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
echo "Delete Old Bios File From Jupiter_bios"
sudo cp $Bios_File $Jupiter_bios"F7A0116_sign.fd" # For SteamOS 3.5 ~ Stable 
sudo cp $Bios_File $Jupiter_bios"F7A0118_sign.fd" # For SteamOS 3.6 
echo "Copy 110 Bios File to Jupiter_bios ===> F7A0116_sign.fd"
echo "Copy 110 Bios File to Jupiter_bios ===> F7A0118_sign.fd"
sudo steamos-readonly enable
sudo $SD_Unlocker_File
sudo /usr/share/jupiter_bios_updater/h2offt $Bios_File
