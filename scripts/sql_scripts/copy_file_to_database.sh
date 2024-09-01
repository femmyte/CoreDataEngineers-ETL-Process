#!/bin/bash

# Variables
DB_NAME="newposey"
DB_USER="posgress"
DB_HOST="localhost"
DB_PORT="5432"
CSV_DIR="../../raw/parch_posey"

# Iterate over each CSV file in the directory
for file in "$CSV_DIR"/*.csv
do
  # Extract table name from the CSV file name (assuming the table name is the same as the file name without extension)
  table_name=$(basename "$file" .csv)

  echo "Processing $file for table $table_name"

  # Read the first line (header) of the CSV file to get column names
  header=$(head -n 1 "$file")
  
  # Generate the table schema (assumes all columns are TEXT)
  schema=""
  IFS=',' read -ra columns <<< "$header"
  for col in "${columns[@]}"; do
    # Use double quotes for column names to avoid issues with special characters or reserved words
    schema+=$(printf "\"%s\" TEXT," "$col")
  done
  schema=${schema%,}  # Remove trailing comma

  # Create the table with the generated schema
  psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "
    CREATE TABLE IF NOT EXISTS \"$table_name\" ($schema);
  "

  # Import the CSV file into the PostgreSQL table
  psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "
    COPY \"$table_name\" FROM '$file' WITH CSV HEADER;
  "

  echo "$file imported successfully into table $table_name"
done







