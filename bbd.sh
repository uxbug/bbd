#!/bin/bash

if [[ -z "$1" ]]; then
    echo "bbd <bottle>"
    exit 1
fi
FORMULA=$1

FORMULA_JSON=$(curl -s "https://formulae.brew.sh/api/formula/$FORMULA.json")

if [[ $(echo $FORMULA_JSON | jq -r '.name' 2>/dev/null) == "null" ]]; then
    echo "Formulae Not Found: $FORMULA"
    exit 1
fi

VERSION=$(echo $FORMULA_JSON | jq -r '.versions.stable' 2>/dev/null)

BOTTLES=$(echo $FORMULA_JSON | jq -r '.bottle.stable.files | to_entries[] | "\(.key) \(.value.url)"' 2>/dev/null)

if [[ -z "$BOTTLES" ]]; then
    echo "Can't find the bottle"
    exit 1
fi

echo "Find the following bottles (version: $VERSION):"
COUNT=1
declare -a URLS
declare -a FILENAMES
declare -a ARCHITECTURES
declare -a SYSTEMS
while IFS= read -r line; do
    FILENAME=$(echo $line | cut -d' ' -f1)
    URL=$(echo $line | cut -d' ' -f2)
    SYSTEM=$(echo $FILENAME | cut -d'.' -f2)
    ARCHITECTURE=$(echo $FILENAME | cut -d'.' -f1)
    DISPLAY_NAME="${FORMULA}-${VERSION}_${SYSTEM}.bottle.tar.gz"
    echo "$COUNT) $DISPLAY_NAME"
    URLS+=("$URL")
    FILENAMES+=("$DISPLAY_NAME")
    ((COUNT++))
done <<< "$BOTTLES"

echo "Please select the bottle to download (default 1):"
read -r CHOICE
CHOICE=${CHOICE:-1}

SELECTED_URL="${URLS[$CHOICE-1]}"
SELECTED_FILENAME="${FILENAMES[$CHOICE-1]}"

REAL_URL=$(curl -s -I -L -H "Authorization: Bearer QQ==" "$SELECTED_URL" | grep -i "Location" | awk '{print $2}' | tr -d '\r')

if [[ -z "$REAL_URL" ]]; then
    curl -L -o "$SELECTED_FILENAME" -H "Authorization: Bearer QQ==" "$SELECTED_URL"
else
    curl -L -o "$SELECTED_FILENAME" "$REAL_URL"
fi
