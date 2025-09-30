#!/bin/bash

# ===============================
# Insert Record (GUI)
# ===============================
insert_record() {
    local database=$1

    table=$(zenity --entry --title="Insert Record" --text="Enter Table you want to insert in:")
    [ -z "$table" ] && { zenity --error --text="No table provided."; return; }

    if [ ! -f "$database/$table" ]; then
        zenity --error --text="Table '$table' does not exist."
        return
    fi

    header=$(head -n1 "$database/$table")
    columns=$(echo "$header" | tr ',' '\n')  # split into lines for display
    values=$(zenity --entry --title="Insert Record" --text="Columns: $header\nEnter values (comma-separated):")
    [ -z "$values" ] && { zenity --error --text="No values provided."; return; }

    echo "$values" >> "$database/$table"
    zenity --info --text="Record inserted successfully into '$table'."
}

# ===============================
# Select Record (GUI)
# ===============================
select_record() {
    local database=$1

    table=$(zenity --entry --title="Select Record" --text="Enter Table you want to select from:")
    [ -z "$table" ] && { zenity --error --text="No table provided."; return; }

    if [ ! -f "$database/$table" ]; then
        zenity --error --text="Table '$table' does not exist."
        return
    fi

    header=$(head -n1 "$database/$table")
    columns=$(echo "$header" | tr ',' '\n')
    
    choice=$(zenity --list --title="Select Option" --column="Option" \
        "Show all records" \
        "Search by column value")

    case $choice in
        "Show all records")
            data=$(cat "$database/$table")
            zenity --text-info --title="All Records in $table" --width=600 --height=400 --filename="$database/$table"
            ;;
        "Search by column value")
            IFS=',' read -a cols <<< "$header"
            col_options=""
            for i in "${!cols[@]}"; do
                col_options+="$((i+1)) ${cols[$i]} "
            done

            colid=$(zenity --entry --title="Search Record" --text="Columns: $header\nEnter column number to search by:")
            value=$(zenity --entry --title="Search Record" --text="Enter value to search for:")

            if [[ -z "$colid" || -z "$value" ]]; then
                zenity --error --text="Column or value not provided."
                return
            fi

            tmpfile=$(mktemp)
            awk -F',' -v c="$colid" -v v="$value" 'NR==1 || $c==v' "$database/$table" > "$tmpfile"
            zenity --text-info --title="Search Results" --width=600 --height=400 --filename="$tmpfile"
            rm -f "$tmpfile"
            ;;
    esac
}

