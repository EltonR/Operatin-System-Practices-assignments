#!/bin/bash

titulo="Erasch's Machine Management System"

function menu(){
	option=""
	while [ "$option" != "Quit" ]
	do
		option=$( dialog --stdout --backtitle "$titulo" --title 'Main Menu' --menu 'Please choose an option:' 0 0 0  Search_Machine  '' Add_Machine '' Delete_Machine '' Edit_Machine '' View_Machines '' Quit '')
		

		if [ "$option" == "Search_Machine" ]; then
			search "$1"
		fi


		if [ "$option" == "Add_Machine" ]; then
			add "$1"
		fi


		if [ "$option" == "Delete_Machine" ]; then
			delete "$1"
		fi


		if [ "$option" == "Edit_Machine" ]; then
			edit "$1"
		fi


		if [ "$option" == "View_Machines" ]; then
			view "$1"
		fi
	done
}

function edit(){
	while [ true ]
	do
		temp=""
		tuple=""
		
		exec 3>&1
		machines=$(grep -v '^$' "$1" | awk '( $1!="#" ){print $2" "$1"-"$3"-"$4}')
		choosen=$(dialog --backtitle "$titulo" --title 'List of entries:' --menu "Choose one" 0 0 0 $machines 2>&1 1>&3)
		
		if [ "$choosen"!="" ];then
			temp=$(awk -v choosen=$choosen -F ' ' '{if ( $2!=choosen ) { print $0; }}' $1)
			tuple=$(awk -v choosen=$choosen -F ' ' '{if ( $2==choosen ) { print $0; }}' $1)
		fi
		[ $? -ne 0 ] && break
		exec 3>&-

		name=$(echo "$tuple" | cut -d ' ' -f1)
		mac=$(echo "$tuple" | cut -d ' ' -f3)
		ip=$(echo "$tuple" | cut -d ' ' -f2)
		group=$(echo "$tuple" | cut -d ' ' -f4)
		aliass=$(echo "$tuple" | cut -d ' ' -f5)

		exec 3>&1
		VALUES=$(dialog --ok-label "Submit" --backtitle "$titulo" --title "Edit Machine" --form "Edit Fields:" 20 50 0 \
			"HostName:"	1 1	"$name"	1 10 40 0 \
			"MAC:" 2 1	"$mac" 2 10 40 0 \
			"IP:" 3 1 "$ip"	3 10 40 0 \
			"Group:" 4 1 "$group"	4 10 40 0 \
			"Alias:" 5 1 "$aliass"	5 10 40 0 \
		2>&1 1>&3)
		[ $? -ne 0 ] && break
		exec 3>&-

		name=$(echo "$VALUES" | cut -d $'\n' -f1)
		mac=$(echo "$VALUES" | cut -d $'\n' -f2)
		ip=$(echo "$VALUES" | cut -d $'\n' -f3)
		group=$(echo "$VALUES" | cut -d $'\n' -f4)
		aliass=$(echo "$VALUES" | cut -d $'\n' -f5)


		if [ "$name" == "" ] || [ "$mac" == "" ] ||  [ "$ip" == "" ] || [ "$group" == "" ] || [ "$aliass" == "" ]; then
			dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "None of the fields can be empty!" 0 0	
		else
			if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
				#IP Pattern OK
				ipv=""
				ipv=$(echo "$ip" | awk -F "." '{if ($1 > 255 || $2 > 255 || $3 > 255 || $4 > 255){ print $0;}}')
				if [ "$ipv" == "" ]; then
					if grep -Fwq "$ip" "$temp" ; then
						dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "IP Adress already taken!\n$ip" 0 0	
					else
						#IP NOT TAKEN
						if [[ "$mac" =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]]; then
							#MAC PATTERN OK
							if grep -Fwq "$ip" "$temp" ; then
								dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "MAC Adress already taken!\n$mac" 0 0	
							else
								#MAC NOT TAKEN
								echo "$temp" > "$1"
								echo "$name $ip $mac $group $aliass" >> "$1"
								dialog --backtitle "$titulo" --title "Success" --no-collapse --msgbox "Machine saved!" 0 0
								break
							fi
						else
							dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "Invalid MAC Adress!" 0 0
						fi
					fi
				fi
			else
				dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "Invalid IP Adress!\n$ip" 0 0
			fi
		fi
	done
}

function delete(){
	name=""
	mac=""
	ip=""


	while [ true ]
	do
		# open fd
		exec 3>&1


		# Store data to $VALUES variable
		VALUES=$(dialog --ok-label "Submit" --backtitle "$titulo" --title "Search for Machine to delete" --form "Search Fields:" 15 50 0 \
			"HostName:"	1 1	"$name"	1 10 30 0 \
			"(OR) MAC:" 2 1	"$mac"  2 10 30 0 \
			"(OR) IP:"  3 1	"$ip"  	3 10 30 0 \
		2>&1 1>&3)

		[ $? -ne 0 ] && break

		# close fd
		exec 3>&-

		name=$(echo "$VALUES" | cut -d $'\n' -f1)
		mac=$(echo "$VALUES" | cut -d $'\n' -f2)
		ip=$(echo "$VALUES" | cut -d $'\n' -f3)
		if [ "$name" == "" ];then
			echo "$name"
		fi




		choosen=""
		#All blank, show everything...
		machines=""
		if [ "$name" == "" ] && [ "$ip" == "" ] && [ "$mac" == "" ]; then
			machines=$(grep -v '^$' "$1" | awk '( $1!="#" ){print $2" "$1"-"$3"-"$4}')
			choosen=$(dialog --backtitle "$titulo" --title 'List of entries:' --menu "Choose one machine to delete" 0 0 0 $machines 3>&2 2>&1 1>&3)
		else
			if [ "$name" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | awk -v name=$name -F ' ' '( $1!="#" ){ 
				if( match($1, name) ){ 
					print $2" "$1"-"$3"-"$4; 
				}}') 
			fi
			if [ "$ip" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | awk -v ip=$ip -F ' ' '( $1!="#" ){ 
				if( match($2, ip) ){ 
					print $2" "$1"-"$3"-"$4; 
				}}') 
			fi
			if [ "$mac" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | awk -v mac=$mac -F ' ' '( $1!="#" ){ 
				if( match($3, mac) ){ 
					print $2" "$1"-"$3"-"$4; 
				}}') 
			fi
			choosen=$(dialog --backtitle "$titulo" --title 'List of entries:' --menu "Choose one" 0 0 0 $machines 3>&2 2>&1 1>&3)
		fi
		
		if [ "$choosen"!="" ];then
			temp=$(awk -v choosen=$choosen -F ' ' '{if ( $2!=choosen ) { print $0; }}' $1)
			echo "$temp" > "$1"
		fi
	done
}

function add(){
	status="0"
	name=""
	mac=""
	ip=""
	group=""
	aliass=""
	while [ true ]
	do
		exec 3>&1
		VALUES=$(dialog --ok-label "Submit" --backtitle "$titulo" --title "Insert Machine" --form "Inform Fields:" 20 50 0 \
			"HostName:"	1 1	"$name"	1 10 40 0 \
			"MAC:" 2 1	"$mac" 2 10 40 0 \
			"IP:" 3 1 "$ip"	3 10 40 0 \
			"Group:" 4 1 "$group"	4 10 40 0 \
			"Alias:" 5 1 "$aliass"	5 10 40 0 \
		2>&1 1>&3)
		[ $? -ne 0 ] && break
		exec 3>&-

		name=$(echo "$VALUES" | cut -d $'\n' -f1)
		mac=$(echo "$VALUES" | cut -d $'\n' -f2)
		ip=$(echo "$VALUES" | cut -d $'\n' -f3)
		group=$(echo "$VALUES" | cut -d $'\n' -f4)
		aliass=$(echo "$VALUES" | cut -d $'\n' -f5)

		aux=""
		aux=$(grep -v '^$' "$1" | awk '($1!="#") {print $1}' | grep -Fw "$name")

		if [ "$name" == "" ] || [ "$mac" == "" ] ||  [ "$ip" == "" ] || [ "$group" == "" ] || [ "$aliass" == "" ]; then
			dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "None of the fields can be empty!" 0 0	
			echo "NAME: $name - MAC: $mac - IP: $ip - GROUP: $group - ALIAS: $aliass"
		else
			if [[ "$aux" != "" ]]; then
				dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "Name already taken!\n$name" 0 0
			else
				if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
					ipv=""
					ipv=$(echo "$ip" | awk -F "." '{if ($1 > 255 || $2 > 255 || $3 > 255 || $4 > 255){ print $0;}}')
					if [ "$ipv" == "" ]; then
						#IP Pattern OK
						if grep -Fwq "$ip" "$1" ; then
							dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "IP Adress already taken!\n$ip" 0 0	
						else
							#IP NOT TAKEN
							if [[ "$mac" =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]]; then
								#MAC PATTERN OK
								if grep -Fwq "$ip" "$1" ; then
									dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "MAC Adress already taken!\n$mac" 0 0	
								else
									#MAC NOT TAKEN
									echo "$name $ip $mac $group $aliass" >> "$1"
									dialog --backtitle "$titulo" --title "Success" --no-collapse --msgbox "Machine added!" 0 0
								fi
							else
								dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "Invalid MAC Adress!" 0 0
							fi
						fi
					else
						dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "Invalid IP Adress!\n$ipv" 0 0
					fi
				else
					dialog --backtitle "$titulo" --title "Error" --no-collapse --msgbox "Invalid IP Adress!\n$ip" 0 0
				fi
			fi
		fi
	done
}

function search(){

	name=""
	mac=""
	ip=""


	while [ true ]
	do
		# open fd
		exec 3>&1

		# Store data to $VALUES variable
		VALUES=$(dialog --ok-label "Submit" --backtitle "$titulo" --title "Search for Machine" --form "Search fields containing:" 15 50 0 \
			"HostName:"	1 1	"$name"	1 10 30 0 \
			"(OR) MAC:" 2 1	"$mac"  2 10 30 0 \
			"(OR) IP:"  3 1	"$ip"  	3 10 30 0 \
		2>&1 1>&3)

		[ $? -ne 0 ] && break

		# close fd
		exec 3>&-

		name=$(echo "$VALUES" | cut -d $'\n' -f1)
		mac=$(echo "$VALUES" | cut -d $'\n' -f2)
		ip=$(echo "$VALUES" | cut -d $'\n' -f3)
		if [ "$name" == "" ];then
			echo "$name"
		fi

		machines=""
		#All blank, show everything...
		if [ "$name" == "" ] && [ "$ip" == "" ] && [ "$mac" == "" ]; then
			machines=$(grep -v '^$' "$1" | awk '( $1!="#" ){print $0}')
			dialog  --backtitle "$titulo" --title 'Results (No filter): ' --msgbox "$machines" 0 0
		else
			if [ "$name" != "" ]; then
				machines=$(grep -v '^$' "$1" | awk -v name=$name -F ' ' '( $1!="#" ){ 
				if( match($1, name) ){ 
					print $0; 
				}}') 
			fi
			if [ "$ip" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | awk -v ip=$ip -F ' ' '( $1!="#" ){ 
				if( match($2, ip) ){ 
					print $0; 
				}}') 
			fi
			if [ "$mac" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | awk -v mac=$mac -F ' ' '( $1!="#" ){ 
				if( match($3, mac) ){ 
					print $0; 
				}}') 
			fi
			dialog  --backtitle "$titulo" --title "Results: " --msgbox "$machines" 0 0
		fi
	done
}

function view(){

	name=""
	mac=""
	ip=""


	while [ true ]
	do
		# open fd
		exec 3>&1

		# Store data to $VALUES variable
		VALUES=$(dialog --ok-label "Submit" --backtitle "$titulo" --title "View Machines" --form "Search Fields (blank to see all):" 15 50 0 \
			"HostName:"	1 1	"$name"	1 10 30 0 \
			"(OR) MAC:" 2 1	"$mac"  2 10 30 0 \
			"(OR) IP:"  3 1	"$ip"  	3 10 30 0 \
		2>&1 1>&3)

		[ $? -ne 0 ] && break

		# close fd
		exec 3>&-

		name=$(echo "$VALUES" | cut -d $'\n' -f1)
		mac=$(echo "$VALUES" | cut -d $'\n' -f2)
		ip=$(echo "$VALUES" | cut -d $'\n' -f3)
		if [ "$name" == "" ];then
			echo "$name"
		fi

		fields=$(dialog	--backtitle "$titulo" --checklist 'Select the fields to see:' 0 0 0 IP 'The IP received' ON MAC 'The mac adress of the machine' ON Name 'Machines hostname' ON Group 'The Group it belongs' ON Alias 'The Alias' ON 3>&2 2>&1 1>&3)

		machines=""
		#All blank, show everything...
		if [ "$name" == "" ] && [ "$ip" == "" ] && [ "$mac" == "" ]; then
			echo "AQUI"	
			machines=$(grep -v '^$' "$1" | sort -k4,4 | awk -v fields="$fields" '( $1!="#" ){ 
				if( match(fields, "Name") ){
					printf $1" ";
				}
				if( match(fields, "IP") ){
					printf $2" ";
				}
				if( match(fields, "MAC") ){
					printf $3" ";
				}
				if( match(fields, "Group") ){
					printf $4" ";
				}
				if( match(fields, "Alias") ){
					printf $5" ";
				}
				print "";
			}')
			dialog --backtitle "$titulo" --title 'Results (No filter): ' --msgbox "$machines" 0 0
		else
			if [ "$name" != "" ]; then
				machines=$(grep -v '^$' "$1" | sort -k4,4 | awk -v name=$name -F ' ' '( $1!="#" ){ 
				if( match(fields, "Name") ){
					printf $1" ";
				}
				if( match(fields, "IP") ){
					printf $2" ";
				}
				if( match(fields, "MAC") ){
					printf $3" ";
				}
				if( match(fields, "Group") ){
					printf $4" ";
				}
				if( match(fields, "Alias") ){
					printf $5" ";
				}
				print "";
				}' fields="$fields") 
			fi
			if [ "$ip" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | sort -k4,4 | awk -v ip=$ip -F ' ' '( $1!="#" ){ 
				if( match(fields, "Name") ){
					printf $1" ";
				}
				if( match(fields, "IP") ){
					printf $2" ";
				}
				if( match(fields, "MAC") ){
					printf $3" ";
				}
				if( match(fields, "Group") ){
					printf $4" ";
				}
				if( match(fields, "Alias") ){
					printf $5" ";
				}
				print "";
				}' fields="$fields") 
			fi
			if [ "$mac" != "" ]; then
				machines="$machines"$(grep -v '^$' "$1" | sort -k4,4 | awk -v mac=$mac -F ' ' '( $1!="#" ){ 
				if( match(fields, "Name") ){
					printf $1" ";
				}
				if( match(fields, "IP") ){
					printf $2" ";
				}
				if( match(fields, "MAC") ){
					printf $3" ";
				}
				if( match(fields, "Group") ){
					printf $4" ";
				}
				if( match(fields, "Alias") ){
					printf $5" ";
				}
				print "";
				}' fields="$fields") 
			fi
			dialog  --backtitle "$titulo" --title "Results: " --msgbox "$machines" 0 0
		fi
	done
}

menu "$1"

