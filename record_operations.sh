#!/bin/bash
# ================================
# File: record_operations.sh
# ================================
#
insert_record(){
	local database=$1
	read -p "Enter Table you want to insert in: " table
	if [ ! -f "$database/$table" ];
	then
		echo "Table $table does not exits"
		return
	fi
	header=$(head -n1 "$database/$table")
	echo "$header"
	read -p "Enter values for $header (comma-separated): " values	
	echo "$values" >> "$database/$table"
	echo "Record inserted successfully"
	
}
select_record(){
	local database=$1
        read -p "Enter Table you want to select from: " table
        if [ ! -f "$database/$table" ];
        then
                echo "Table $table does not exits"
                return
        fi

	header=$(head -n1 "$database/$table")
        echo "Columns: $header"

	echo "1) Show all records"
        echo "2) Search by column value"
        read -p "Choose an option: " choice

	case $choice in
        	1)
            		echo "---- All Records ----"
            		cat "$database/$table"
            		;;
	esac
}
