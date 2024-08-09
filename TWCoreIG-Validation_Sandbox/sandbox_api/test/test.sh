#!/bin/bash

output_file="test.txt"
command="java -jar ../validator_cli.jar /home/michelin/TWCoreIG-Validation_Sandbox/sandbox_api/input/bundle-01.json -version 4.0 -ig tw.gov.mohw.twcore -watch-mode all"
previous_line=""

$command | {
    while IFS= read -r line
    do
        if [[ "$previous_line" == *"Watching for changes (1000ms cycle)"* ]]; then
            echo "$line" > "$output_file"
        else
            echo "$line" >> "$output_file"
        fi

        previous_line="$line"
    done
}
