#!/bin/bash
for folder in /var/www/property_images/*
    do
    for file in $( ls "$folder")
        do

        mls=$(echo $file|cut -d '.' -f 3)
        dir=$(echo $mls|tail -c -4)

        img="/var/www/property_images/$dir/min.progressive.$mls.jpg"
        img75="/var/www/property_images/$dir/min.progressive.$mls.75.jpg"
        img50="/var/www/property_images/$dir/min.progressive.$mls.50.jpg"
        img25="/var/www/property_images/$dir/min.progressive.$mls.25.jpg"
        img15="/var/www/property_images/$dir/min.progressive.$mls.15.jpg"
        img10="/var/www/property_images/$dir/min.progressive.$mls.10.jpg"
        img5="/var/www/property_images/$dir/min.progressive.$mls.5.jpg"

        if [ -f $img50 ]; then
            if [ ! -f $img25 ]; then
                convert $img50 -quality 50 $img25
                echo "convert $img50 -quality 50 $img25"
            fi
            if [ ! -f $img15 ]; then
                convert $img50 -quality 30 $img15
                echo "convert $img50 -quality 30 $img15"
            fi
            if [ ! -f $img10 ]; then
                convert $img50 -quality 40 $img10
                echo "convert $img50 -quality 40 $img10"
            fi
        fi
    done
done