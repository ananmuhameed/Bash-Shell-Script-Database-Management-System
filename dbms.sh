#!/bin/bash
# ================================
# File: dbms.sh (Main Script)
# ================================

DATABASES="./databases"
mkdir -p "$DATABASES"

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
	read -n1 answer
	echo
	case $answer in
		1)
			echo -n "enter database name: "
			read db
			;;
		2)
			echo -n "available databases: "
			ls "$DATABASES"
			;;
		3)
			echo -n "enter db you want to connect: "
			read db
			;;
		4)
			echo -n "enter database you want to delete: "
			read db
			;;
		5)
			echo "Exit"
			exit 0
			;;
		*)
			echo "try again"
			;;
	esac
done
