#!/bin/bash
# ================================
# File: dbms.sh (Main Script)
# ================================

DATABASES="./databases"
mkdir -p "$DATABASES"

source ./db_operations.sh
source ./table_operations.sh
source ./record_operations.sh

while true;
do
	echo "Main Menu"
	echo "---------"
	echo "1) Create Database"
    	echo "2) List Databases"
    	echo "3) Connect to Database"
    	echo "4) Drop Database"
    	echo "5) Exit"
    	echo "----------------------------"
    	echo -n "Enter choice (1-5): "
	read  answer
	echo
	case $answer in
		1)
			echo -n "enter database name: "
			read db
			;;
		2)
			echo "available databases: "
			ls "$DATABASES"
			;;
		3)
			read -p "enter db you want to connect: " db

			if [ -d "$DATABASES/$db" ];
                        then
                                tables_menu "$DATABASES/$db"
			else
				echo "$db not found"
			fi
			;;
		4)
			echo -n "enter database you want to delete: "
			read db
			;;
		5)
			echo "Exiting"
			exit 0
			;;
		*)
			echo "try again"
			;;
	esac
done
