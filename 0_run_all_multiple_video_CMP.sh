#!/bin/bash
REF_ERP_W=7680
REF_ERP_H=3840
CODE_ERP_W=4032
CODE_ERP_H=2016
CODE_CMP_W=3456
CODE_CMP_H=2304
CMP_FACE_W=1152
CMP_FACE_H=1152
GOP=24
NO_FR=48
# declare -a seq_name_arr=("AerialLakeView" "Driving_NYCity" "Dubai" "Panda" "shark" "Timelapse_NY")
declare -a seq_name_arr=("Panda" "AerialLakeView" "Driving_NYCity" "Dubai" "shark")
# declare -a seq_name_arr=("Driving_NYCity" "Dubai" "Panda" "shark" "Timelapse_NY")
# declare -a seq_name_arr=("Dubai" "Panda" "shark" "Timelapse_NY")
# declare -a seq_name_arr=("AerialLakeView")
for seq_name in "${seq_name_arr[@]}"
do
	echo "$seq_name"
	erp_yuv_name="${seq_name}_2GOP_ERP"
	cmp_yuv="Dataset/8K/${seq_name}_2GOP_CMP_${CODE_CMP_W}x${CODE_CMP_H}x8_cf1.yuv"
	source="Dataset/8K/${erp_yuv_name}_${CODE_ERP_W}x${CODE_ERP_H}.yuv"
	refVideo="../Dataset/8K/${erp_yuv_name}_${REF_ERP_W}x${REF_ERP_H}x8_cf1.yuv"
	echo "$source $refVideo"
	# create folder if necessary
	# rm -r Dataset/${seq_name}
	mkdir Dataset/${seq_name}
	# rm -r Dataset/${seq_name}/GOP_${GOP}
	mkdir Dataset/${seq_name}/GOP_${GOP}
	# rm -r viewport_quality/${seq_name}
	mkdir Dataset/${seq_name}/no_tile
	mkdir viewport_quality/${seq_name}
	# create ERP tiles and calculate BD-delta values
	# CMP
	perl 1_create_tile_CMP.pl ${seq_name} $source $cmp_yuv $CODE_ERP_W $CODE_ERP_H $CODE_CMP_W $CODE_CMP_H $CMP_FACE_W $CMP_FACE_H $NO_FR
	cd ./viewport_quality/
	perl 2_compute_PSNR_CMP.pl ${seq_name} $refVideo $CODE_CMP_W $CODE_CMP_H $CMP_FACE_W $CMP_FACE_H $REF_ERP_W $REF_ERP_H $NO_FR
	cd ../
	# pwd
done