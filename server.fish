#! /usr/bin/env fish

# Temporary file for saving incoming JSON
set temp_file (mktemp)
echo "temp file:"
echo $temp_file

# File for keeping track of seen ids
set ids_file (mktemp)
echo "id file:"
echo $ids_file

set kars https://cdde-131-239-192-194.ngrok-free.app/
set tony https://2792-131-239-192-194.ngrok-free.app/

while true
    # Start a listener on port 80
    echo -e 'HTTP/1.1 200 OK\r\ncontent-length: 0\r\n\r\n' | nc -l 80 >$temp_file

    # Extract the JSON payload
    set body (sed -n -e '/{/,$p' $temp_file | jq)

    if echo $body | jq 'has("blame")' | grep -q true
        echo "received blame, sending to kars"
        curl -d "$body" -H "Content-Type: application/json" -X POST $kars || echo "failed to blame"
    else
        if echo $body | jq 'has("id")' | grep -q true
            # Extract the required fields from the JSON
            set id (echo $body | jq -r ".id")
            set author (echo $body | jq -r ".author")
            set message (echo $body | jq -r ".message")
            set relayers (echo $body | jq -r '.relayers + ["butts.io"]')

            # Check if the id has been seen before
            if grep -Fxq "$id" $ids_file
                echo "Received again"
            else
                echo "$id" >>$ids_file
                set body (jq -n --arg id "$id" --arg author "$author" --arg message "$message" --argjson relayers "$relayers" \
            '{id: $id, author: $author, message: $message, relayers: $relayers}')
                echo $body

                # Send a POST request
                # post to tony
                if ! curl -d "$body" -H "Content-Type: application/json" -X POST $tony
                    echo "failed to send, blaming tony back to Kars"
                    curl -d '{"blame": "Tony"}' -H "Content-Type: application/json" -X POST $kars || echo "failed to blame"
                end
            end
        else
            echo "failed to parse body, blaming tony back to Kars"
            curl -d '{"blame": "Tony"}' -H "Content-Type: application/json" -X POST $kars || echo "failed to blame"
        end
    end
end
