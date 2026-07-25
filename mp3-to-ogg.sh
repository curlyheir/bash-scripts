#!/bin/bash

# Linux mp3 to ogg
# Converts .mp3 files to .ogg files 

# Convert all .mp3 files to .ogg
for file in *.mp3; do
    ffmpeg -i "$file" -vn -acodec libvorbis -y "${file%.mp3}.ogg"
done   
