#! /bin/perl -w
use strict;
use warnings;

# -------------------- Variable --------------------- # 
my $video_name 				= $ARGV[0];
my $source = $ARGV[1];
print "${video_name} $source\n";
# exit;
# my $ERP_W = 3840;
# my $ERP_H = 1920;
my $ERP_W = $ARGV[2];
my $ERP_H = $ARGV[3];
my @QP_ar = qw(48 44 40 36 32 28 24);
my @W_tile_ar = qw(1 4 6 12);
my @H_tile_ar = qw(1 3 4 6);
# my @W_tile_ar = qw(4 12);
# my @H_tile_ar = qw(3 6);
my $No_scheme = @W_tile_ar;
my $frame_rate	= 24;
my $GoP		= 24;
my $No_skip = 0;
my $No_FR = 48;
my $QP;
my $tile_W;
my $tile_H;
my $W_tile_num;
my $H_tile_num;
my $tile_num;
my $No_ver = 7;
my $tile_id;
my @tile_list = qw(2);
my $tile_folder;
my $log_folder;
my @longitude;
my @altitude;
my $cmd;
my $tile_name;

for(my $c = 0; $c < $No_scheme; $c++){
# for(my $c = 0; $c < $No_scheme; $c++){
    $W_tile_num = $W_tile_ar[$c];
    $tile_W = $ERP_W / $W_tile_num;
    $H_tile_num = $H_tile_ar[$c];
    $tile_H = $ERP_H / $H_tile_num;
    $tile_num = $W_tile_num * $H_tile_num;
    for (my $i = 0; $i < $tile_num; $i++) {
 		$longitude[$i] = int($i % $W_tile_num)  * $tile_W;
 		$altitude[$i] = int($i / $W_tile_num) * $tile_H;
 		print "$longitude[$i]\t$altitude[$i]\n";
    }
    # checking folders
    if(-e "Dataset/${video_name}/GOP_${GoP}/${W_tile_num}x${H_tile_num}"){

    	}else{
    		$cmd = "mkdir Dataset/${video_name}/GOP_${GoP}/${W_tile_num}x${H_tile_num}";
    		system "$cmd";
    	}
    $tile_folder = "Dataset/${video_name}/GOP_${GoP}/" . $W_tile_num . 'x' . $H_tile_num . '/tile_yuv/';
    if(-e $tile_folder){

    	}else{
    		$cmd = "mkdir $tile_folder";
    		system "$cmd";
    	}
    $log_folder = "Dataset/${video_name}/GOP_${GoP}/" . $W_tile_num . 'x' . $H_tile_num . '/tile_log/';
    if(-e $log_folder){

   	}else{
    	$cmd = "mkdir $log_folder";
    	system $cmd;
    }
    print "$tile_folder\n$log_folder\n";
    #
    #next;
    for ($tile_id = 0; $tile_id < $tile_num; $tile_id++) {
	$tile_name = "Tile_${tile_id}_${tile_W}x${tile_H}.yuv";
	# extract tile
	my $generate_tile = 1;
	if($generate_tile == 1){
	    my $lt = ${longitude[$tile_id]};
	    my $at = ${altitude[$tile_id]};
	    my $cmd = "ffmpeg -y -s ${ERP_W}x${ERP_H} -r ${frame_rate} -i $source -filter:v \"crop=${tile_W}:${tile_H}:$lt:$at\" -frames ${No_FR} -c:v rawvideo -pix_fmt yuv420p ${tile_folder}${tile_name}";
	    print "$cmd\n";
	    if(-e "${tile_folder}${tile_name}"){
	    	print "${tile_folder}${tile_name} existed!\n";
	    }else{
	    	system $cmd;
	    }
	}
	# encode tile
	my $encode_tile = 1;
	if($encode_tile == 1){
	    # foreach $QP (@QP_ar){
	    for(my $QP_id = 0; $QP_id < $No_ver; $QP_id ++){
			$QP = $QP_ar[$QP_id];
			my $log = "${log_folder}log_PSNR_tile_${tile_id}_QP_${QP}.txt";
			my $out = "${tile_folder}Tile_${tile_id}_${tile_W}x${tile_H}_QP_${QP}.h265";
			#my $cmd = "./TAppEncoderStatic -c encoder_lowdelay_main.cfg -wdt ${tile_W} -hgt ${tile_H} -q ${QP} -o $out -fs $No_skip -f $No_FR -i ${tile_folder}${tile_name} > ${log}";
			my $cmd = "x265 --input ${tile_folder}${tile_name} --input-depth 8 --frames ${No_FR}  --input-res ${tile_W}x${tile_H} --input-csp 1 --fps 30 --qp ${QP}  --ipratio 1 --pbratio 1 --keyint ${GoP} --min-keyint ${GoP} --scenecut 0  --bframes 2 --no-open-gop --preset slow --ssim --psnr --log-level 3 --csv-log-level 2 --csv ${log} -o ${out}";
			if(-e "$out"){
	    		print "$out existed!\n";
	    	}else{
				print "$cmd\n";
	    		system $cmd;
	    	}
	    }
	    # cleaning
	    if(-e "${tile_folder}${tile_name}"){
		    $cmd = "rm ${tile_folder}${tile_name}";
		    print "$cmd\n";
		    system "$cmd";
	    }else{
		}
	}
    }
    # exit;
}
