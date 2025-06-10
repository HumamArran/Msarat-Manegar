#!/bin/bash

# File to watch
FILE_TO_WATCH="/usr/local/etc/raddb/clients.conf"

# Function to run when the file changes
run_function() {
    killall -q radiusd
    radiusd
    # Add your custom logic here
}

while true; do
    inotifywait -e modify -e delete -e attrib "$FILE_TO_WATCH" 2>> watch_file_e$
        run_function
    done
    echo "File $FILE_TO_WATCH was deleted or moved. Re-establishing watch..."
    sleep 1
done
