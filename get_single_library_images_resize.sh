#!/bin/bash
set -e -u
#source "$(pwd)/db_cridentions.sh"

# for test
export PGBIN=/usr/pgsql-9.5/bin
export PGPORT=5432
export PGHOST=localhost_name
export PGUSER=postgres
export PGPASSWORD=password
export PGDATABASE=database_name

PSQL=${PGBIN}/psql

mls_numbers=$( ${PSQL} -X -A  -t -c "SELECT mls_no,photo_count FROM tmp_photos ORDER BY mls DESC limit 500")

for mls_cnt_photo in $mls_numbers
    do
        photo_count=$( echo $mls_cnt_photo|cut -d '|' -f 2)
        mls=$( echo $mls_cnt_photo|cut -d '|' -f 1)

        dir=$( echo $mls|tail -c -4)
        img_dir="/var/www/property_images/$dir"

        if [ ! -d $img_dir ]; then
            mkdir $img_dir
        fi

        add_img="${mls}.jpg"
        add_img_quality_75="$img_dir/min.progressive.${mls}.75.jpg"
        add_img_quality_50="$img_dir/min.progressive.${mls}.50.jpg"
        add_img_quality_25="$img_dir/min.progressive.${mls}.25.jpg"
        add_img_quality_15="$img_dir/min.progressive.${mls}.15.jpg"
        add_img_quality_5="$img_dir/min.progressive.${mls}.5.jpg"
        add_img_quality_120x90="$img_dir/min.progressive.${mls}.120x90.jpg"
        full_img_path="$img_dir/$add_img"
        full_img_path_jpegtran="$img_dir/min.progressive.$add_img"
        echo "https://photos.mredllc.com/photos/property/$dir/$add_img\n"
        curl -o $full_img_path https://photos.mredllc.com/photos/property/$dir/$add_img

        jpegtran -progressive -copy none -optimize -outfile $full_img_path_jpegtran $full_img_path
        convert $full_img_path_jpegtran -quality 75 $add_img_quality_75
        convert $full_img_path_jpegtran -quality 50 $add_img_quality_50
        convert $full_img_path_jpegtran -quality 25 $add_img_quality_25
        convert $full_img_path_jpegtran -quality 15 $add_img_quality_15
        convert $full_img_path_jpegtran -quality 5 $add_img_quality_5
        convert $full_img_path_jpegtran -resize 120x90 $add_img_quality_120x90
        echo "\n\n"

        let photo_count=$(( photo_count - 1 ))
        for (( i=1; i<=$photo_count; i++ ))
        do
            add_img="${mls}_$i.jpg"
            add_img_quality_75="$img_dir/min.progressive.${mls}_$i.75.jpg"
            add_img_quality_50="$img_dir/min.progressive.${mls}_$i.50.jpg"
            add_img_quality_25="$img_dir/min.progressive.${mls}_$i.25.jpg"
            add_img_quality_15="$img_dir/min.progressive.${mls}_$i.15.jpg"
            add_img_quality_5="$img_dir/min.progressive.${mls}_$i.5.jpg"
            add_img_quality_120x90="$img_dir/min.progressive.${mls}_$i.120x90.jpg"
            full_img_path="$img_dir/$add_img"
            full_img_path_jpegtran="$img_dir/min.progressive.$add_img"
            echo "https://photos.mredllc.com/photos/property/$dir/$add_img\n"
            curl -o $full_img_path https://photos.mredllc.com/photos/property/$dir/$add_img

            jpegtran -progressive -copy none -optimize -outfile $full_img_path_jpegtran $full_img_path
            convert $full_img_path_jpegtran -quality 75 $add_img_quality_75
            convert $full_img_path_jpegtran -quality 50 $add_img_quality_50
            convert $full_img_path_jpegtran -quality 25 $add_img_quality_25
            convert $full_img_path_jpegtran -quality 15 $add_img_quality_15
            convert $full_img_path_jpegtran -quality 5 $add_img_quality_5
            convert $full_img_path_jpegtran -resize 120x90 $add_img_quality_120x90
            echo "\n\n"
        done
        ${PSQL} -X -A  -t -c "UPDATE test_table SET photos_downloaded = true WHERE mls_no = '$mls'"
        ${PSQL} -X -A  -t -c "DELETE FROM tmp_photos  WHERE mls_no = '$mls'"
done