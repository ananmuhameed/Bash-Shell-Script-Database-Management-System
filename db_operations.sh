#!/bin/bash
# ================================
# File: db_operations.sh
# ================================
create_database() {
  read -rp "Database name: " db
  if [ -z "$db" ]; then
    echo "Aborted."
    return
  fi
  if [ -d "$DATABASES/$db" ]; then
    echo "Database '$db' already exists."
    return
  fi
  mkdir -p "$DATABASES/$db"
  echo "Database '$db' created at $BASE_DIR/$db"
}

list_databases() {
  echo "Databases:"
  local found=0
  for d in "$DATABASES"/*; do
    [ -d "$d" ] || continue
    printf " - %s\n" "$(basename "$d")"
    found=1
  done
  if [ "$found" -eq 0 ]; then
    echo " (none found)"
  fi
}

drop_database() {
  read -rp "Drop database (name): " db
  [ -z "$db" ] && { echo "no database name was given"; return; }
  if [ ! -d "$DATABASES/$db" ]; then
    echo "Database '$db' not found."
    return
  fi
  read -rp "Are you sure you want to permanently delete '$db'? Type 'yes' to confirm: " conf
  if [ "$conf" = "yes" ]; then
    rm -rf "$DATABASES/$db"
    echo "Deleted '$db'."
  else
    echo "Aborted."
  fi
}
