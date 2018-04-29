#!/bin/bash
REF_ERP_W=7680
REF_ERP_H=3840
CODE_ERP_W=4032
CODE_ERP_H=2016
GOP=24
# declare -a seq_name_arr=( "Timelapse_NY" "Dubai" "Panda" "shark" "AerialLakeView" "Driving_NYCity" )
declare -a seq_name_arr=("Panda" "shark" "AerialLakeView" "Driving_NYCity" )
# declare -a seq_name_arr=("Driving_NYCity" "Dubai" "Panda" "shark" "Timelapse_NY")
# declare -a seq_name_arr=("Panda" "shark" "Timelapse_NY")
# declare -a seq_name_arr=("Driving_NYCity")
for seq_name in "${seq_name_arr[@]}"
do
	echo "$seq_name"
	yuv_name="${seq_name}_2GOP_ERP"
	source="Dataset/8K/${yuv_name}_${CODE_ERP_W}x${CODE_ERP_H}.yuv"
	refVideo="../Dataset/8K/${yuv_name}_${REF_ERP_W}x${REF_ERP_H}x8_cf1.yuv"
	echo "$source $refVideo"
	# create folder if necessary
	# rm -r Dataset/${seq_name}
	mkdir Dataset/${seq_name}
	# rm -r Dataset/${seq_name}/GOP_${GOP}
	mkdir Dataset/${seq_name}/GOP_${GOP}
	# rm -r viewport_quality/${seq_name}
	mkdir viewport_quality/${seq_name}
	# create ERP tiles and calculate BD-delta values
	perl 1_create_tile_ERP.pl ${seq_name} $source $CODE_ERP_W $CODE_ERP_H
	cd ./viewport_quality/
	# pwd
	perl 2_compute_PSNR_ERP.pl ${seq_name} $refVideo $CODE_ERP_W $CODE_ERP_H $REF_ERP_W $REF_ERP_H
	cd ../
	pwd
done
# video_name="Elephant"
# yuv_name="Elephant_10s_20s"
# # video_name="RollerCoaster"
# # yuv_name="Rollercoaster_2min_2min10"
# source="Dataset/videos/${yuv_name}_${CODE_ERP_W}x${CODE_ERP_H}.yuv"
# refVideo="../Dataset/videos/${yuv_name}.yuv"
# perl 1_create_tile_erp.pl ${video_name} $source $CODE_ERP_W $CODE_ERP_H
# cd ./viewport_quality/
# # pwd
# perl 2_compare_projection_tiling_ERP.pl ${video_name} $refVideo $CODE_ERP_W $CODE_ERP_H $REF_ERP_W $REF_ERP_H 