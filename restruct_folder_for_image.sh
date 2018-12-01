#!/bin/bash
for file in /var/www/property_images/*.jpg
    do
    d=$( echo $file|tail -c -11|cut -d '.' -f 1)
    if [ ! -d $d ]; then
        mkdir "/var/www/property_images/$d"
        if [ -d "/var/www/property_images/$d" ]; then
            mv $file "/var/www/property_images/$d/"
        fi
    elif [ -d "/var/www/property_images/$d" ]; then
        mv $file "/var/www/property_images/$d/"
    fi
done