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

delete_record() {
    local database=$1
    read -p "Enter table to delete from: " table

    if [ ! -f "$database/$table" ]; then
        echo "Table $table does not exist"
        return
    fi

    header=$(head -n1 "$database/$table")
    echo "Columns: $header"

    read -p "Enter full value to delete (any row containing this will be removed): " val

    grep -F -v "$val" "$database/$table" > tmp
    mv tmp "$database/$table"

    echo "Rows containing '$val' deleted successfully"
}


update_record() {
    local database=$1
    read -p "Enter Table you want to update: " table
    if [ ! -f "$database/$table" ]; then
        echo "Table $table does not exist"
        return
    fi

    header=$(head -n1 "$database/$table")
    echo "Columns: $header"

    read -p "Enter column name to match: " match_col
    read -p "Enter value to match: " match_val
    read -p "Enter column name to update: " update_col
    read -p "Enter new value: " new_val

    match_index=0
    update_index=0
    i=1
    IFS=',' read -ra cols <<< "$header"
    for col in "${cols[@]}"; do
        if [ "$col" == "$match_col" ]; then match_index=$i; fi
        if [ "$col" == "$update_col" ]; then update_index=$i; fi
        i=$((i+1))
    done


    tmpfile="$database/${table}.tmp"
    while IFS= read -r line; do
        if [ "$line" == "$header" ]; then
            echo "$line" >> "$tmpfile"
            continue
        fi

        IFS=',' read -ra fields <<< "$line"
        if [ "${fields[$((match_index-1))]}" == "$match_val" ]; then
            fields[$((update_index-1))]="$new_val"
        fi
        (IFS=','; echo "${fields[*]}") >> "$tmpfile"
    done < "$database/$table"

    mv "$tmpfile" "$database/$table"
    echo "Updated rows where $match_col=$match_val → $update_col=$new_val"
}
