#!/bin/bash
# ================================
# File: dbms.sh (Main Script)
# ================================

DATABASES="./databases"
mkdir -p "$DATABASES"


# Import functions
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
			create_database
			;;
		2)

			list_databases
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
			drop_database
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
