#!/bin/bash

# ===============================
# GUI Tables Menu
# ===============================

tables_menu(){
    local database=$1

    while true; do
        choice=$(zenity --list --title="Database: $database" \
            --column="Option" --column="Description" \
            1 "Create Table" \
            2 "List Tables" \
            3 "Drop Table" \
            4 "Insert into Table" \
            5 "Select From Table" \
            6 "Delete From Table" \
            7 "Update Table" \
            8 "Back to Main Menu")

        case $choice in
            1) create_table "$database" ;;
            2) list_tables "$database" ;;
            3) drop_table "$database" ;;
            4) insert_record "$database" ;;
            5) select_record "$database" ;;
            6) delete_record "$database" ;;
            7) update_record "$database" ;;
            8) break ;;
            *) zenity --error --text="Invalid choice, try again." ;;
        esac
    done
}

# ===============================
# Create Table
# ===============================
create_table(){
    local database=$1
    table=$(zenity --entry --title="Create Table" --text="Enter Table Name:")
    table=$(echo "$table" | tr ' ' '_')
    [ -z "$table" ] && { zenity --error --text="No table name provided."; return; }

    if [ -f "$database/$table" ]; then
        zenity --error --text="Table '$table' already exists."
    else
        columns=$(zenity --entry --title="Create Table" \
            --text="Enter Table Columns (comma-separated, e.g. id,name,age):")
        [ -z "$columns" ] && { zenity --error --text="No columns provided."; return; }

        IFS=',' read -a col_array <<< "$columns"
        schema=""

        for col in "${col_array[@]}"; do
            dtype=$(zenity --list --radiolist \
                --title="Select Data Type" \
                --text="Choose datatype for column: [$col]" \
                --column="Choose" --column="Type" \
                TRUE "INT" \
                FALSE "TEXT" \
                FALSE "REAL" \
                FALSE "DATE")

            [ -z "$dtype" ] && dtype="TEXT"   # default if user cancels
            schema+="$col:$dtype,"
        done

        schema=${schema%,}  # remove trailing comma

        #Primary Key
        pk=$(zenity --list --title="Primary Key" \
            --text="Select a column as Primary Key" \
            --column="Column" "${col_array[@]}")
        [ -z "$pk" ] && { zenity --error --text="No Primary Key selected."; return; }

        # Append PK info at the end of schema line
        echo "$schema|PK=$pk" > "$database/$table"

        zenity --info --text="Table '$table' created with schema:\n$schema\nPrimary Key: $pk"
    fi
}

# ===============================
# List Tables
# ===============================
list_tables(){
    local database=$1
    tables=$(ls "$database")
    if [ -z "$tables" ]; then
        zenity --info --title="Tables" --text="No tables found in $database"
    else
        zenity --list --title="Tables in $database" --column="Table Name" $tables
    fi
}

# ===============================
# Drop Table
# ===============================
drop_table(){
    local database=$1
    table=$(zenity --entry --title="Drop Table" --text="Enter table name to delete:")
    [ -z "$table" ] && { zenity --error --text="No table name provided."; return; }

    if [ -f "$database/$table" ]; then
        zenity --question --text="Are you sure you want to delete '$table'?"
        if [ $? -eq 0 ]; then
            rm "$database/$table"
            zenity --info --text="Table '$table' deleted."
        else
            zenity --info --text="Aborted."
        fi
    else
        zenity --error --text="Table '$table' not found."
    fi
}


