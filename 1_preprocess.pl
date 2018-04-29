#! /bin/perl -w
use strict;
use warnings;
#========FULL (6 videos)=============
# my @seq_name = qw(AerialLakeView Driving_NYCity Dubai Elemental_Demo Panda shark Skiing Timelapse_NY);
# my @seq_start_time = qw(120 10 0 0 60 5 120 0);
# my @seq_res_W = qw(7680 7680 7680 7680 7680 7680 5760 7680);
# my @seq_res_H = qw(3840 3840 3840 3840 3840 3840 5760 3840);
# my @seq_fps = qw(30 30 30 30 30 30 60 30);
# 
#======== SHORT (6 videos)=============
my @seq_name = qw(AerialLakeView Driving_NYCity Dubai Panda shark Timelapse_NY);
my @seq_start_time = qw(120 10 0 60 5 0);
my @seq_res_W = qw(7680 7680 7680 7680 7680 7680);
my @seq_res_H = qw(3840 3840 3840 3840 3840 3840);
my @seq_fps = qw(30 30 30 30 30 30);
my $NO_SEQ = @seq_name;
my $GOP = 24;
my $NO_FR = 2 * $GOP;
my $ext = "webm";
my $seq_id;
my $cmd;
my $fs; # Number of frames skipped
my $fp; # Number of frames processed
my $in;
my $out;
my $CMP_FACE_W = 1152;
my $CMP_FACE_H = 1152;
my $ERP_W = 4032;
my $ERP_H = 2016;
# converter
my $converter = "../../TApp360ConvertStatic";
my $enc = "x265";
my $a;

for($seq_id =0; $seq_id < $NO_SEQ; $seq_id ++){
	printf "%s\t\t%dx%d@%d\n", $seq_name[$seq_id], $seq_res_W[$seq_id], $seq_res_H[$seq_id], $seq_fps[$seq_id];
	# extract 2GOP
	$fs = $seq_start_time[$seq_id] * $seq_fps[$seq_id];
	$fp = 2 * $GOP;
	$in = "$seq_name[$seq_id].${ext}";
	$out = "$seq_name[$seq_id]_${seq_res_W[$seq_id]}x${seq_res_H[$seq_id]}_2GOP.yuv";
	$cmd = "ffmpeg -r 1 -i $in -ss $fs -t $fp $out -n";
	print "$cmd\n";
	# system $cmd;
	# upsampling
	$in = $out;
	$a =  (${seq_res_W[$seq_id]}/3) * 2;
	$out = "$seq_name[$seq_id]_${seq_res_W[$seq_id]}x${a}_2GOP.yuv";
	$cmd = "ffmpeg -f rawvideo -pix_fmt yuv420p -s ${seq_res_W[$seq_id]}x${seq_res_H[$seq_id]} -i $in -s ${seq_res_W[$seq_id]}x${a} -vframes ${NO_FR} $out -y";
	print "$cmd\n";
	# system $cmd;
	# exit;
	# 
	$in = $out;
	$out = "$seq_name[$seq_id]_2GOP_ERP.yuv";
	$cmd = "../../TApp360ConvertStatic -w 1 -i $in -wdt ${seq_res_W[$seq_id]} -hgt $a --InputBitDepth=8 --OutputBitDepth=8 -fr 24 -fs 0 -icf 420 --SourceFPStructure=\"2 3 4 0 0 0 5 0 3 180 1 270 2 0\" --InputGeometryType=1 --CodingGeometryType=0 --CodingFPStructure=\"1 1 0  0\" --CodingFaceWidth=${seq_res_W[$seq_id]} --CodingFaceHeight=${seq_res_H[$seq_id]} -f ${NO_FR} -o $out";
	print "$cmd\n";
	# system $cmd;
	# exit;
	$out = "$seq_name[$seq_id]_2GOP_ERP_${seq_res_W[$seq_id]}x${seq_res_H[$seq_id]}x8_cf1.yuv";
	# extract coding ERP
	$in = $out;
	$out = "$seq_name[$seq_id]_2GOP_ERP_${ERP_W}x${ERP_H}.yuv";
	$cmd = "ffmpeg -f rawvideo -pix_fmt yuv420p -s ${seq_res_W[$seq_id]}x${seq_res_H[$seq_id]} -i $in -s ${ERP_W}x${ERP_H} -vframes $NO_FR $out -y";
	print "$cmd\n";
	system $cmd;
	# exit;
	# extract coding CMP
	$out = "$seq_name[$seq_id]_2GOP_CMP.yuv";
	$cmd = "../../TApp360ConvertStatic -w 1 -i $in -wdt ${seq_res_W[$seq_id]} -hgt ${seq_res_H[$seq_id]} --InputBitDepth=8 --OutputBitDepth=8 -fr 24 -fs 0 -icf 420 --SourceFPStructure=\"1 1 0 0\" --InputGeometryType=0 --CodingGeometryType=1 --CodingFPStructure=\" 2 3 4 0 0 0 5 0 3 180 1 270 2 0\" --CodingFaceWidth=$CMP_FACE_W --CodingFaceHeight=$CMP_FACE_H -f ${NO_FR} -o $out";
	print "$cmd\n";
	system $cmd;
	# exit;
}