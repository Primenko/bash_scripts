#!/bin/bash
set -e -u
#source "$(pwd)/db_cridentions.sh"

# for local
export PGBIN=/usr/local/bin
export PGPORT=5432
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=password
export PGDATABASE=db

PSQL=${PGBIN}/psql


#code=$( echo ps -auxww | grep parseData  | grep -v grep)
#echo $code
#exit

mls_numbers=$( ${PSQL} -X -A  -t -c "SELECT DISTINCT column,photo_count FROM table ORDER BY column DESC limit 100")

for mls_no in $mls_numbers
do
    mlsno=$( echo $mls_no|cut -d '|' -f 1)
#    ${PSQL} -X -A  -t -c "DELETE FROM table WHERE column = '$mlsno'"
done

for mls_cnt_photo in $mls_numbers
    do
        photo_count=$( echo $mls_cnt_photo|cut -d '|' -f 2)
        mls=$( echo $mls_cnt_photo|cut -d '|' -f 1)
        dir=$( echo $mls|tail -c -4)
        img_dir="/path/to/images/$dir"

        if [ ! -d $img_dir ]; then
            mkdir $img_dir
        fi

        images_urls=$( ${PSQL} -X -A  -t -c "SELECT column FROM table WHERE column = '$mls'")
        IFS=' ||| ';
        j=0
        for img in $images_urls
        do
        
            if ((j == 0)); then

                add_img="${mls}.jpg"
                add_img_quality_75="$img_dir/min.progressive.${mls}.75.jpg"
                add_img_quality_50="$img_dir/min.progressive.${mls}.50.jpg"
                add_img_quality_25="$img_dir/min.progressive.${mls}.25.jpg"
                add_img_quality_15="$img_dir/min.progressive.${mls}.15.jpg"
                add_img_quality_5="$img_dir/min.progressive.${mls}.5.jpg"
                add_img_quality_120x90="$img_dir/min.progressive.${mls}.120x90.jpg"
                add_img_quality_360x260="$img_dir/min.progressive.${mls}.360x260.jpg"

                full_img_path="$img_dir/$add_img"
                full_img_path_jpegtran="$img_dir/min.progressive.$add_img"

                curl -o $full_img_path $img

                jpegtran -progressive -copy none -optimize -outfile $full_img_path_jpegtran $full_img_path # min.progressive.{mls}.jpg
                convert $full_img_path_jpegtran -quality 75 $add_img_quality_75 # min.progressive.{mls}_75.jpg
                convert $full_img_path_jpegtran -quality 50 $add_img_quality_50 # min.progressive.{mls}_50.jpg
                convert $full_img_path_jpegtran -quality 25 $add_img_quality_25 # min.progressive.{mls}_25.jpg
#                convert $full_img_path_jpegtran -quality 15 $add_img_quality_15 # min.progressive.{mls}_15.jpg
#                convert $full_img_path_jpegtran -quality 5 $add_img_quality_5 # min.progressive.{mls_5}.jpg
                convert $full_img_path_jpegtran -resize 120x90 $add_img_quality_120x90 # min.progressive.{mls}_120x90.jpg
                convert $full_img_path_jpegtran -resize 360x260 $add_img_quality_360x260 # min.progressive.{mls}_360x260.jpg
                rm $full_img_path
            else
                add_img="${mls}_$j.jpg"
                add_img_quality_75="$img_dir/min.progressive.${mls}_$j.75.jpg"
                add_img_quality_50="$img_dir/min.progressive.${mls}_$j.50.jpg"
                add_img_quality_25="$img_dir/min.progressive.${mls}_$j.25.jpg"
                add_img_quality_15="$img_dir/min.progressive.${mls}_$j.15.jpg"
                add_img_quality_5="$img_dir/min.progressive.${mls}_$j.5.jpg"
                add_img_quality_120x90="$img_dir/min.progressive.${mls}_$j.120x90.jpg"
                full_img_path="$img_dir/$add_img"
                full_img_path_jpegtran="$img_dir/min.progressive.$add_img"

                curl -o $full_img_path $img

                jpegtran -progressive -copy none -optimize -outfile $full_img_path_jpegtran $full_img_path   # min.progressive.{mls}_{i}.jpg
                convert $full_img_path_jpegtran -quality 75 $add_img_quality_75 # min.progressive.{mls}_{i}_75.jpg
#                convert $full_img_path_jpegtran -quality 50 $add_img_quality_50 # min.progressive.{mls}_{i}_50.jpg
#                convert $full_img_path_jpegtran -quality 25 $add_img_quality_25 # min.progressive.{mls}_{i}_25.jpg
#                convert $full_img_path_jpegtran -quality 15 $add_img_quality_15 # min.progressive.{mls}_{i}_15.jpg
#                convert $full_img_path_jpegtran -quality 5 $add_img_quality_5 # min.progressive.{mls}_{i}_5.jpg
                convert $full_img_path_jpegtran -resize 120x90 $add_img_quality_120x90  # min.progressive.{mls}_{i}_120x90.jpg
                rm $full_img_path
            fi
            echo $((++j))
        done

        ${PSQL} -X -A  -t -c "UPDATE table SET column = true WHERE column = '$mls'"
        
    done

exit
