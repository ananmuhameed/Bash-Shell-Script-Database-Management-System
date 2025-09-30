#!/bin/bash
# ================================
# File: db_operations.sh
# ================================
create_database() {
  db=$(zenity --entry --title="Create Database" --text="Enter database name:")
  [ -z "$db" ] && { zenity --error --text="No name provided. Aborted."; return; }
  if [ -d "$DATABASES/$db" ]; then
    zenity --error --text="Database '$db' already exists."
    return
  fi
  mkdir -p "$DATABASES/$db"
  zenity --info --text="Database '$db' created at $DATABASES/$db"
}


list_databases() {
  dbs=$(ls -1 "$DATABASES" 2>/dev/null)
  if [ -z "$dbs" ]; then
    zenity --info --title="Databases" --text="(none found)"
  else
    zenity --list --title="Databases" --column="Database Name" $dbs
  fi
}


drop_database() {
  db=$(zenity --entry --title="Drop Database" --text="Enter database name:")
  [ -z "$db" ] && { zenity --error --text="No name provided."; return; }
  if [ ! -d "$DATABASES/$db" ]; then
    zenity --error --text="Database '$db' not found."
    return
  fi
  zenity --question --title="Confirm Delete" --text="Are you sure you want to permanently delete '$db'?"
  if [ $? -eq 0 ]; then
    rm -rf "$DATABASES/$db"
    zenity --info --text="Deleted '$db'."
  else
    zenity --info --text="Aborted."
  fi
}

