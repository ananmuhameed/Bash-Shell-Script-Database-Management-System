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
done
