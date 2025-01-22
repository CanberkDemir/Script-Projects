#!/bin/bash

# AUTHOR: Canberk Demir
# DATE: 22/01/25 13.25
# TODO: Make Sure that spaces do not break the metadata
# Version: 0.1

# Ensure ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it before running this script."
    exit 1
fi

CURRENT_DIR=$PWD
# Verify that the folder exists
if [ ! -d "$CURRENT_DIR" ]; then
    echo "The specified folder does not exist: $FOLDER"
    exit 1
fi

# functionalized for later use
metadata(){
    # Ask for metadata variables
    echo -n "Enter new Artist (leave blank to keep current): "
    read ARTIST
    echo -n "Enter new Album (leave blank to keep current): "
    read ALBUM
    echo -n "Enter new Genre (leave blank to keep current): "
    read GENRE
    echo -n "Enter new Year (leave blank to keep current): "
    read YEAR

    # Process each mp3 file in the folder
    for FILE in "$CURRENT_DIR"/*.mp3; do
        # Skip if no mp3 files are found
        if [ ! -e "$FILE" ]; then
            echo "No MP3 files found in $CURRENT_DIR."
            exit 1
        fi

        echo "Processing file: $(basename -s .mp3 "$FILE")"

        # Create a temporary output file name
        OUTPUT_FILE="${FILE%.mp3}_updated.mp3"

        # Get the Title variable as the filename
        TITLE="$(basename -s .mp3 "$FILE")"

        # Build ffmpeg metadata options
        METADATA_OPTIONS=()
        [ -n "$TITLE" ] && METADATA_OPTIONS+=(-metadata title="$TITLE")
        [ -n "$ARTIST" ] && METADATA_OPTIONS+=(-metadata artist="$ARTIST")
        [ -n "$ALBUM" ] && METADATA_OPTIONS+=(-metadata album="$ALBUM")
        [ -n "$GENRE" ] && METADATA_OPTIONS+=(-metadata genre="$GENRE")
        [ -n "$YEAR" ] && METADATA_OPTIONS+=(-metadata date="$YEAR")

        # Run ffmpeg to update metadata
        ffmpeg -i "$FILE" -y -codec copy "${METADATA_OPTIONS[@]}" "$OUTPUT_FILE"

        if [ $? -eq 0 ]; then
            echo "Metadata updated successfully: $OUTPUT_FILE"
            # Optionally replace the original file with the updated one
            mv "$OUTPUT_FILE" "$FILE"
        else
            echo "Failed to update metadata for: $FILE"
            # Clean up the temporary file if the operation failed
            [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
        fi

        echo "---------------------------------------------"
    done

    echo "Metadata update process completed."
}

# functionalized for later use
albumcover(){
    # Look for a jpeg or png file (supports only those two)
    for FILE in "$CURRENT_DIR"/*; do
        case "$FILE" in
            *.jpg|*.jpeg)
                echo "Found an image file!"
                echo $(basename "$FILE")
                COVER_FILENAME="$(basename "$FILE")"
                ;;
            *.png)
                echo "Found an image file!"
                echo $(basename "$FILE")
                COVER_FILENAME="$(basename "$FILE")"
                ;;
        esac
    done

    # Process each mp3 file in the folder
    for FILE in "$CURRENT_DIR"/*.mp3; do
        # Skip if no mp3 files are found
        if [ ! -e "$FILE" ]; then
            echo "No MP3 files found in $CURRENT_DIR."
            exit 1
        fi

        echo "Processing file: $(basename -s .mp3 "$FILE")"
        # Create a temporary output file name
        OUTPUT_FILE="${FILE%.mp3}_updated.mp3"
        # Run ffmpeg to update image
        FILE=$(realpath "$FILE")
        ffmpeg -i "$FILE" -i "$COVER_FILENAME" -c copy -map 0 -map 1 "$OUTPUT_FILE"

        #Check whether the ffmpeg command returned exit code 0
        if [ $? -eq 0 ]; then
            echo "Image updated successfully: $OUTPUT_FILE"
            # Optionally replace the original file with the updated one
            mv "$OUTPUT_FILE" "$FILE"
        else
            echo "Failed to update metadata for: $FILE"
            # Clean up the temporary file if the operation failed
            [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
        fi

        echo "---------------------------------------------"
    done
    echo "Image update process completed."
}

# Command Line menu for the script will work according to the positional arguments
case $1 in
    album)
        echo "Running album cover changer..."
        albumcover
        echo "Thank you for using metadata_edit!"
        exit 0
        ;;
    metadata)
        echo "Running metadata changer..."
        metadata
        echo "Thank you for using metadata_edit!"
        exit 0
        ;;
    help)
        cat << EOF
Hi! This script can do two functions:
-Album cover art changer
-Metadata changer for albums

Usage:
The script should be in the same folder as the mp3 and image files
Call function "album" for album cover art changes
Call function "metadata" for metadata changes
Call "quit" to exit the script
Call "help" to see this text again

NOTES:
-Cover art changer function only supports png and jpeg files
-Metadata changer picks the titles from file names. To function properly, file names should be renamed accordingly before execution
EOF
        ;;
    quit)
        echo "Thank you for using metadata_edit!"
        exit 0
        ;;
    *)
        echo "See help (as a posargu) for a list of commands and explanations"
        ;;
esac
