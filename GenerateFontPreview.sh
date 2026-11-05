#/bin/bash

# Rob 2026-11-05 
# True type font preview generator 

# requires imagemagick installed, tested with version 6.9.11.60 installed under Debian on WSL

# generate a preview of the font file into a PNG image file
for font in *.ttf; do
    convert -background white -fill black -font "./$font" -density 200 -pointsize 32 -bordercolor "#cccccc" -border 2 \
    label:"${font%.*}  !?#- ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqurstuvwxyz 1234567890 Съешьте еще немного этих МЯГКИХ БУЛОЧЕК" \
    "${font%.*}-preview.png"
done

# now add all the previews to a single file
convert *-preview.png -append font_previews.png