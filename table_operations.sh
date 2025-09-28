#!/bin/bash
# ================================
# File: table_operations.sh
# ===============================
#
source ./record_operations.sh

tables_menu(){
	local database=$1

	while true;
	do
		echo " Database: $database"
        	echo "=========================="
        	echo "1) Create Table"
        	echo "2) List Tables"
        	echo "3) Drop Table"
        	echo "4) Insert into Table"
        	echo "5) Select From Table"
        	echo "6) Delete From Table"
        	echo "7) Update Table"
        	echo "8) Back to Main Menu"
        	read -p "Enter choice: " choice
		case $choice in
			1)
				create_table "$database"
				;;
			2)
				list_tables "$database"
				;;
			3)
				drop_table "$database"
				;;
			4)
				insert_record "$database"
				;;
			5)
				select_record "$database"
				;;
			6)
				delete_record "$database"
				;;
			7)
				update_record "$database"
				;;
			8)
				break
				;;
			*)
				echo "try again"
				;;
		esac
	done

}
create_table(){
	local database=$1
	echo -n "Enter Table Name: "
	read table
	if [ -f "$database/$table" ];
	then
		echo "Table $table already exists"
	else
		echo "Enter Table Columns (comma-separated)"
		read columns
		echo "$columns">"$database/$table"
		echo "Table $table created successfuly"
	fi
}
list_tables(){
	local database=$1
	echo "Tables in $database:"
	ls $database
}
drop_table(){
	local database=$1
	read -p "Enter table you want to delete: " table
	if [ -f "$database/$table" ];
	then
		rm "$database/$table"
		echo "Table $table deleted"
	else
		echo "Table $table not found"
	fi
}
