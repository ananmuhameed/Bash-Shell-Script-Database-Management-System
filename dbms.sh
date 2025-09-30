#!/bin/bash

DATABASES="./databases"
mkdir -p "$DATABASES"

source ./db_operations.sh
source ./table_operations.sh
source ./record_operations.sh

while true; do
    choice=$(zenity --list --title="Bash DBMS Main Menu" \
        --column="Option" --column="Description" \
        1 "Create Database" \
        2 "List Databases" \
        3 "Connect to Database" \
        4 "Drop Database" \
        5 "Exit")

    case $choice in
        1)
            create_database
            ;;
        2)
            list_databases
            ;;
        3)
            db=$(zenity --entry --title="Connect to Database" --text="Enter database name:")
            if [ -d "$DATABASES/$db" ]; then
                tables_menu "$DATABASES/$db"
            else
                zenity --error --text="Database '$db' not found"
            fi
            ;;
        4)
            drop_database
            ;;
        5)
            zenity --info --text="Exiting..."
            exit 0
            ;;
        *)
            zenity --error --text="Invalid choice, try again."
            ;;
    esac
done

