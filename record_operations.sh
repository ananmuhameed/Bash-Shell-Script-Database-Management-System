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
        #echo "Columns: $header"

	echo "1) Show all records"
        echo "2) Search by column value"
        read -p "Choose an option: " choice

	case $choice in
        	1)
            		echo "---- All Records ----"
            		cat "$database/$table"
            		;;
		2)
			IFS=',' read -a columns <<<"$header"
			echo "Columns: $header"
			for i in "${!columns[@]}";
		       	do
    				echo "$((i+1)) ${columns[$i]}"
			done

			read -p "Enter col id to search with: " colid
			read -p "Enter value to search with: " value

			awk -F',' -v c="$colid" -v v="$value" 'NR==1 || $c==v' 				"$database/$table"
			;;
	esac
}
update_record() {
    local database=$1
    read -p "Enter Table you want to update: " table
    if [ ! -f "$database/$table" ]; then
        echo "Table $table does not exist"
        return
    fi

    header=$(head -n1 "$database/$table")
    #echo "Columns: $header"

    IFS=',' read -a cols <<<"$header"
    for i in "${!cols[@]}";
    do
        echo "$((i+1)) ${cols[$i]}"
    done

    read -p "Enter ID to update (WHERE id=?): " match_id
    read -p "Enter column number to update (SET): " update_col
    read -p "Enter new value (SET): " new_val

    awk -F',' -v id="$match_id" -v uc=$update_col -v nv="$new_val" '
        NR==1 { print; next }
        {
            if ($1 == id) {
                $uc = nv
            }
            OFS=","; print
        }
    ' "$database/$table" > tmpfile && mv tmpfile "$database/$table"

    echo "Record with id=$match_id updated successfully!"

}

delete_record() {
    local database=$1
    read -p "Enter table to delete from: " table

    if [ ! -f "$database/$table" ]; then
        echo "Table $table does not exist"
        return
    fi

    echo "======================="
    header=$(head -n1 "$database/$table")
    echo "Columns: $header"
    echo "======================="

    read -p "Enter column name to delete by: " colname
    read -p "Enter value for $colname: " val

    if ! grep -Fq "$val" "$database/$table"; then
        echo "Value does not exist"
        return
    fi

    grep -F -v "$val" "$database/$table" > tmp
    mv tmp "$database/$table"

    echo "Rows containing '$val' in column '$colname' deleted successfully"
}
