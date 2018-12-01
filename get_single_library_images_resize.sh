#!/bin/bash
if [ $# = 0 ]; then
    echo "Please enter MLS Number"
    break
fi


#export PGBIN=/usr/local/bin
export PGBIN=/usr/pgsql-9.5/bin
export PGPORT=5432
export PGHOST=localhost
export PGUSER=postgres
#export PGPASSWORD=benja
export PGPASSWORD=welcom1
#export PGDATABASE=doh_prod_1
export PGDATABASE=deals_on_home_dev
PSQL=${PGBIN}/psql

mls=$1
dir=$( echo $1|tail -c -4)
img_dir="/var/www/property_images/$dir"

if [ ! -d $img_dir ]; then
    mkdir $img_dir
fi

photo_count=$( ${PSQL} -X -A  -t -c "SELECT photo_count FROM properties_agent WHERE mls_no = '$mls'")
#echo $photo_count
#echo $img_dir


for (( i=1; i<=$photo_count; i++ ))
do
    add_img="${mls}_$i.jpg"
    add_img_quality_75="$img_dir/min.progressive.${mls}_$i.75.jpg"
    add_img_quality_50="$img_dir/min.progressive.${mls}_$i.50.jpg"
    add_img_quality_25="$img_dir/min.progressive.${mls}_$i.25.jpg"
    add_img_quality_15="$img_dir/min.progressive.${mls}_$i.15.jpg"
    full_img_path="$img_dir/$add_img"
    echo "https://photos.mredllc.com/photos/property/$dir/$add_img\n"
    curl -o $full_img_path https://photos.mredllc.com/photos/property/$dir/$add_img

    convert $full_img_path -quality 75 $add_img_quality_75
    convert $full_img_path -quality 50 $add_img_quality_50
    convert $full_img_path -quality 25 $add_img_quality_25
    convert $full_img_path -quality 15 $add_img_quality_15
    echo "\n\n"
done

