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

    # Read schema and PK
    schema_line=$(head -n1 "$database/$table")   # e.g. id:INT,name:TEXT,grade:REAL|PK=id
    schema=${schema_line%%|*}                    # left of '|'
    pk_col=${schema_line##*PK=}                  # right of 'PK='

    IFS=',' read -ra col_defs <<< "$schema"

    record=""
    pk_value=""

    for i in "${!col_defs[@]}"; do
        coldef="${col_defs[$i]}"
        colname="${coldef%%:*}"
        coltype="${coldef##*:}"

        value=$(zenity --entry --title="Insert Record" --text="Enter value for [$colname] ($coltype):")
        [ -z "$value" ] && { zenity --error --text="No value for $colname provided."; return; }

        # ✅ Validate type
        case "$coltype" in
            INT)
                [[ "$value" =~ ^[0-9]+$ ]] || { zenity --error --text="Invalid INT for $colname."; return; }
                ;;
            REAL)
                [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { zenity --error --text="Invalid REAL for $colname."; return; }
                ;;
            DATE)
                [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { zenity --error --text="Invalid DATE (YYYY-MM-DD) for $colname."; return; }
                ;;
            TEXT) ;; # allow anything
        esac

        # Save PK value for uniqueness check
        if [[ "$colname" == "$pk_col" ]]; then
            pk_value="$value"
            pk_index=$((i+1))   # store column index (awk is 1-based)
        fi

        record+="$value,"
    done

    record=${record%,}   # remove trailing comma

    # ✅ Check PK uniqueness
    if [ -n "$pk_col" ] && [ -n "$pk_value" ]; then
        if awk -F',' -v col="$pk_index" -v val="$pk_value" 'NR>1 && $col==val {found=1} END{exit found}' "$database/$table"; then
            zenity --error --text="Duplicate value '$pk_value' for Primary Key column '$pk_col'."
            return
        fi
    fi

    # Insert record
    echo "$record" >> "$database/$table"
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
update_record() {
    local database=$1

    table=$(zenity --entry --title="Update Record" --text="Enter table name:")
    [ -z "$table" ] && { zenity --error --text="No table provided."; return; }

    if [ ! -f "$database/$table" ]; then
        zenity --error --text="Table '$table' does not exist."
        return
    fi

    # Get schema (id:INT,name:TEXT,...)
    schema=$(head -n1 "$database/$table")
    IFS=',' read -ra col_defs <<< "$schema"

    # Build menu (col index + colname:type)
    menu=()
    for i in "${!col_defs[@]}"; do
        menu+=("$((i+1))" "${col_defs[$i]}")
    done

    # Choose column
    col_choice=$(zenity --list --title="Choose column to update" \
        --column="Column Number" --column="Column" "${menu[@]}")
    [ -z "$col_choice" ] && { zenity --error --text="No column selected."; return; }

    col_index=$(echo "$col_choice" | cut -d'|' -f1)
    col_def="${col_defs[$((col_index-1))]}"
    col_name="${col_def%%:*}"
    col_type="${col_def##*:}"

    # Ask for ID (WHERE condition)
    match_id=$(zenity --entry --title="Update Record" --text="Enter ID value to match (WHERE id=?):")
    [ -z "$match_id" ] && { zenity --error --text="No ID provided."; return; }

    # New value
    new_val=$(zenity --entry --title="Update Record" --text="Enter new value for [$col_name] ($col_type):")
    [ -z "$new_val" ] && { zenity --error --text="No value provided."; return; }

    # Validate type
    case "$col_type" in
        INT)  [[ "$new_val" =~ ^[0-9]+$ ]] || { zenity --error --text="Must be INT."; return; } ;;
        REAL) [[ "$new_val" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { zenity --error --text="Must be REAL."; return; } ;;
        DATE) [[ "$new_val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { zenity --error --text="Must be DATE (YYYY-MM-DD)."; return; } ;;
        TEXT) : ;;
    esac

    # Apply update
    awk -F',' -v id="$match_id" -v col="$col_index" -v val="$new_val" '
        NR==1 { print; next }
        {
            if ($1 == id) $col = val
            OFS=","; print
        }
    ' "$database/$table" > tmpfile && mv tmpfile "$database/$table"

    zenity --info --text="Updated record where id=$match_id in $table."
}


