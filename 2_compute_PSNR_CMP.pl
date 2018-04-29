#! /bin/perl -w
use strict;
# -------------------- Variable --------------------- # 
# my $vname = "Elephant";
my $vname = $ARGV[0];
# my @QP_ar = qw(28);
my @QP_ar = qw(24 28 32 36 40 44 48);
# my @QP_ar = qw(24);
my @W_tile_arr  = qw(2 2 4);
my @H_tile_arr  = qw(1 2 3);
# my @W_tile_ar = qw(1 8 12);
# my @H_tile_ar = qw(1 4 6);
my $No_scheme = @W_tile_arr;
my $W_viewport = $ARGV[4];
my $H_viewport = $ARGV[5];
my $W_face = $ARGV[4];
my $H_face = $ARGV[5];
my $No_face =  6; ############## Change 6
my $No_face_tile_W =  1; 
my $No_face_tile_H =  1; 
my $No_face_tile =  $No_face_tile_W*$No_face_tile_H ; 

my $H_face_tile = $H_face/$No_face_tile_H;
my $W_face_tile = $W_face/$No_face_tile_W;

my $No_FR_D	= 0; # No frames to delete ############## Change 600 
my $No_FR_P	= 48; # No frames to process ############## Change 300 
my $No_FR	= $No_FR_D + $No_FR_P; # No frames to encode 
my $frame_rate			= 24;
my @longitude = qw(0 180 270 270 270 90);
my @altitude  = qw(0 0    90  270 0   0);
my @longitude_tile;
my @altitude_tile;

#=========== Duc's variable ===================
my $converter = "./TApp360ConvertStatic";
my $encoder = "x265";
my $yuv = "Dataset/videos/Timelapse.yuv";
my $W_yuv = $ARGV[6];
my $H_yuv = $ARGV[7];
my $fps = 24;
my $outFolder_yuv;
my $outFolder_log;
my $face_folder;
my @BR;
my $tile_size;
my $t_name;
my $CMP_W = $ARGV[2];
my $CMP_H = $ARGV[3];

#========== for calculating PSNRs =============
my $t_skip = 0;
my $No_fr = $ARGV[8];
my $ver_dir;
my $out;
# my $refVideo = "../Dataset/videos/Elephant_10s_20s.yuv";
my $refVideo = $ARGV[1];
my @PSNR;
my @SPSNR_NN;
my @WSPSNR;
my @SPSNR_I;
my $LOG;
my $FOUT;
my $ver_id;
my $fid;
my $tid;
my $cmd;
my $QP;
my $tile_name_ori;
my @tile_name;
my $cnt_face;
my $w;
my $h;
my @file_t; # store tiles' names
my @file_f; # store faces' names
my $tmp;
$ver_dir = 	 "tmp/";
# 
print "#[check] @ARGV\n";
# exit;
# no-tile case
open $FOUT,'>', "${vname}/RD_CMP_no-tile.txt";
print $FOUT "QP\tBitrate\tPSNR\tSPSNR_NN\tWSPSNR\tSPSNR_I\n";
my $c = 0;
$ver_id = 0;
foreach $QP (@QP_ar){
	$t_name = "../Dataset/${vname}/no_tile/QP${QP}.h265";
	$tile_size = -s $t_name;
	$BR[$ver_id] = (${tile_size} * 8.0 / 1000.0)/(${No_fr} * 1.0 / ${fps});
	# exit;
	if(-e "${vname}/log_psnr_CMP_no-tile_QP_${QP}.txt"){

		}else{
# decode CMP
	$cmd = "ffmpeg -i ../Dataset/${vname}/no_tile/QP${QP}.h265 ${ver_dir}QP${QP}.yuv -n";
	system "$cmd";
	# calculate PSNR
	$cmd = "./TApp360ConvertStatic -w 1 -r $refVideo --SphFile=sphere_655362.txt --ReferenceGeometryType=0 --ReferenceFaceWidth=${W_yuv} --ReferenceFaceHeight=${H_yuv} -i ${ver_dir}QP${QP}.yuv -wdt ${CMP_W} -hgt ${CMP_H} --InputBitDepth=8 --OutputBitDepth=8 -fr 24 -fs 0 -icf 420 --SourceFPStructure=\"2 3 4 0 0 0 5 0 3 180 1 270 2 0\" --InputGeometryType=1 --CodingGeometryType=1 --CodingFPStructure=\"2 3 4 0 0 0 5 0 3 180 1 270 2 0\" --CodingFaceWidth=${W_face} --CodingFaceHeight=${H_face} -f $No_fr -o try.yuv > ${vname}/log_psnr_CMP_no-tile_QP_${QP}.txt";
	}
	print "$cmd\n";
	system "$cmd";
	# exit;
	# 
	my $LOG;
	my @arr;
	my $log_psnr = "${vname}/log_psnr_CMP_no-tile_QP_${QP}.txt";
	print "$log_psnr\n";
	open $LOG, "$log_psnr"; # contain frames's actual viewport
	while (<$LOG>){
		chomp;
		my $line = $_;
		# print "$line\n";
		if ($line =~ $refVideo && $line =~ /PSNRS/){
			print "$line\n";
			# $line = "1x1x1x1 $line";
			# exit;
			my $start_pos = index $line, "PSNRS";
			$line = substr $line, $start_pos;
			print "$line\n";
			# exit;
			@arr = ($line =~ /(\d+)/g);
			$PSNR[$c][$ver_id] = ( 6 * "$arr[0].$arr[1]" + "$arr[2].$arr[3]" + "$arr[4].$arr[5]")/8.0; 
			$SPSNR_NN[$c][$ver_id] = ( 6 * "$arr[6].$arr[7]" + "$arr[8].$arr[9]" + "$arr[10].$arr[11]")/8.0; 
			$WSPSNR[$c][$ver_id] = ( 6 * "$arr[12].$arr[13]" + "$arr[14].$arr[15]" + "$arr[16].$arr[17]")/8.0; 
			$SPSNR_I[$c][$ver_id] = ( 6 * "$arr[18].$arr[19]" + "$arr[20].$arr[21]" + "$arr[22].$arr[23]")/8.0; 
			print "PNSR = $PSNR[$c][$ver_id] $SPSNR_NN[$c][$ver_id] $WSPSNR[$c][$ver_id] $SPSNR_I[$c][$ver_id] \n";
			# print "$arr[5].$arr[6] $arr[7].$arr[8] $arr[9].$arr[10] $arr[11].$arr[12]\n";
			printf $FOUT "%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", $QP,$BR[$ver_id], $PSNR[$c][$ver_id], $SPSNR_NN[$c][$ver_id], $WSPSNR[$c][$ver_id], $SPSNR_I[$c][$ver_id];
			# exit;
		}
	}
	# cleaning
	$cmd = "rm ${ver_dir}QP${QP}.yuv";
	# system $cmd;
	# exit;
    $ver_id ++;
}
close $FOUT;
# exit;
# 
for($c = 0; $c < $No_scheme; $c++){
# for(my $c = 1; $c < 3; $c++){
    $No_face_tile_W =  $W_tile_arr[$c]; 
    $No_face_tile_H =  $H_tile_arr[$c]; 
    $No_face_tile =  $No_face_tile_W*$No_face_tile_H ; 
    $H_face_tile = $H_face/$No_face_tile_H;
    $W_face_tile = $W_face/$No_face_tile_W;
    $face_folder = "../Dataset/${vname}/6f_${No_face_tile_W}x${No_face_tile_H}/face/";
	$outFolder_yuv = "../Dataset/${vname}/6f_${No_face_tile_W}x${No_face_tile_H}/tile_yuv/";
	$outFolder_log = "../Dataset/${vname}/6f_${No_face_tile_W}x${No_face_tile_H}/tile_log/";
	if(-d $ver_dir){
    	# print "Folder exists !\n";
    }else{
    	print "#[Log] Creating folder !\n";
    	$cmd = "mkdir $ver_dir";
    	system $cmd;
    }
    # 
    open $FOUT,'>', "${vname}/RD_CMP_${No_face_tile_W}x${No_face_tile_H}.txt";
	print $FOUT "QP\tBitrate\tPSNR\tSPSNR_NN\tWSPSNR\tSPSNR_I\n";
    # 
    $ver_id = 0;
    foreach $QP (@QP_ar){
    	$BR[$ver_id] = 0;
    	for($fid=0; $fid < $No_face; $fid++){
	    	for($tid = 0; $tid < $No_face_tile; $tid ++){
	    		$t_name = "${outFolder_yuv}f${fid}_t${tid}_${W_face_tile}x${H_face_tile}_QP${QP}.h265";
				$tile_size = -s $t_name;
				$BR[$ver_id] += $tile_size;
	    	}
	    }
	    # 
	    $BR[$ver_id] = ($BR[$ver_id] * 8.0 / 1000.0)/(${No_fr} * 1.0 / ${fps});
		# 
    	# if(-e "${ver_dir}CMP_${CMP_W}x${CMP_H}_QP_${QP}.yuv" || -e "${vname}/log_psnr_CMP_${No_face_tile_W}x${No_face_tile_H}_QP_${QP}.txt"){
    	if(-e "${vname}/log_psnr_CMP_${No_face_tile_W}x${No_face_tile_H}_QP_${QP}.txt"){
    		print "${ver_dir}CMP_${CMP_W}x${CMP_H}_QP_${QP}.yuv existed \n";
    	}else{
	    # extract tiles from original ones
	    for($fid=0; $fid < $No_face; $fid++){
	    	for($tid = 0; $tid < $No_face_tile; $tid ++){
	    		$tile_name_ori = "${outFolder_yuv}f${fid}_t${tid}_${W_face_tile}x${H_face_tile}_QP${QP}.h265";
	    		$tile_name[$fid][$tid] = "${ver_dir}f${fid}_t${tid}_${W_face_tile}x${H_face_tile}_QP${QP}.yuv";
	    		if(-e $tile_name[$fid][$tid]){
	    			print "$tile_name[$fid][$tid] existed \n";
	    		}else{
		    		$cmd = "ffmpeg -r 1 -i $tile_name_ori -ss $t_skip -frames $No_fr $tile_name[$fid][$tid]";
					print "$cmd\n";
					system $cmd;
				}
	    	}
	    }
	    # reconstruct CMP from tiles
	    for ($cnt_face = 0; $cnt_face < $No_face; $cnt_face++) {
	    	$file_f[$cnt_face] = "${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}.yuv";
	    	if(-e $file_f[$cnt_face]){
	    		print "$file_f[$cnt_face] existed !\n";
	    	}else{
				# stitching reference tiles into face
				for ($h = 0; $h < $No_face_tile_H; $h++) {
					$cmd = "ffmpeg -y";
					for($w=0; $w < $No_face_tile_W; $w++){
						my $cnt_t = $h * $No_face_tile_W + $w;
						my $name_id = $cnt_t; # Name of each tile
						# if ($cnt_face == 2) { # top  
						# 	$name_id =  $w * $No_face_tile_H + ($No_face_tile_H - $h -1);
						# 		print "\n \n ############# $cnt_face $cnt_t $name_id \n";
						# }
						# elsif($cnt_face == 3) { # bottom 
							# $name_id =  $No_face_tile_H * ($No_face_tile_W - $w -1) + $h;
							# print "\n \n ############# $cnt_face $cnt_t $name_id \n";
						# }
						$file_t[$cnt_face][$cnt_t] = "${ver_dir}f${cnt_face}_t${name_id}_${W_face_tile}x${H_face_tile}_QP${QP}.yuv"; 

						$tmp = " -f rawvideo -vcodec rawvideo -s ${W_face_tile}x${H_face_tile} -r 30 -pix_fmt yuv420p -i ${file_t[$cnt_face][$cnt_t]}";
						$cmd = $cmd . $tmp;
					}
					#
					$tmp = " -filter_complex \"[0:v]pad=iw*${No_face_tile_W}:ih*1";
					$cmd = $cmd . $tmp;
					#
					for(my $w=1; $w < $No_face_tile_W; $w++){
						$tmp = "[tmp${w}];[tmp${w}][${w}:v]overlay=shortest=1:x=${w}*W/${No_face_tile_W}:y=0";
						$cmd = $cmd . $tmp;
					}
					$tmp = "[vid]\" -map [vid] -vframes $No_fr ${ver_dir}tmp_${h}_${W_face}x${H_face_tile}.yuv";
					$cmd = $cmd . $tmp;
					print "\n\n\n$cmd\n";
					system $cmd;
				}
				$cmd = "ffmpeg -y";
				for(my $h=0; $h < $No_face_tile_H; $h++){
					$tmp = " -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face_tile} -r 30 -pix_fmt yuv420p -i ${ver_dir}tmp_${h}_${W_face}x${H_face_tile}.yuv";
					$cmd = $cmd . $tmp;
				}	
				$tmp = " -filter_complex \"[0:v]pad=iw*1:ih*${No_face_tile_H}";
				$cmd = $cmd . $tmp;
				#
				for (my $h = 1; $h < $No_face_tile_H; $h++) {
					$tmp = "[tmp${h}];[tmp${h}][${h}:v]overlay=shortest=1:x=0:y=${h}*H/${No_face_tile_H}";
					$cmd = $cmd . $tmp;	
				}
				$tmp = "[vid]\" -map [vid] -vframes $No_fr ${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}.yuv";
				$cmd = $cmd . $tmp;
				print "\n\n\n$cmd\n";
				system $cmd;
		    	# exit;
			}
			# exit;
		}
		# exit;
		# rotate faces 3,1,2
		# for($cnt_face = 1; $cnt_face <= 3; $cnt_face++){
		# 	$cmd = "ffmpeg -y -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i $file_f[$cnt_face]  -vf \"transpose=1\" ${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}_rot.yuv";
		# 	if(-e "${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}_rot.yuv"){
		# 		print "${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}_rot.yuv existed\n";
		# 	}else{
		# 		print "##############\n$cmd\n##############\n";
		# 		system $cmd;
		# 	}
		# }
		# rotate faces 3,1,2
		for($cnt_face = 1; $cnt_face <= 3; $cnt_face++){
			if($cnt_face == 1 || $cnt_face == 3){
				$cmd = "ffmpeg -y -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i $file_f[$cnt_face]  -vf \"transpose=1\" ${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}_rot.yuv";
				if(-e "${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}_rot.yuv"){
					print "${ver_dir}face_${cnt_face}_${W_face}x${H_face}_QP${QP}_rot.yuv existed\n";
				}else{
					print "##############\n$cmd\n##############\n";
					system $cmd;
				}
			}
		}
		# 
		$cmd = "ffmpeg -y -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i ${ver_dir}face_3_${W_face}x${H_face}_QP${QP}_rot.yuv  -vf \"transpose=1\" ${ver_dir}face_3_${W_face}x${H_face}_QP${QP}_rot2.yuv";
		system $cmd;

		# exit;
		# create cube-map from selected faces
		if(-e "${ver_dir}CMP_${CMP_W}x${CMP_H}_QP_${QP}.yuv"){
			print "${ver_dir}CMP_${CMP_W}x${CMP_H}_QP_${QP}.yuv existed\n";
		}else{
			$cmd = "ffmpeg -y -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i $file_f[4] -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i $file_f[0] -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i $file_f[5] -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i ${ver_dir}face_3_${W_face}x${H_face}_QP${QP}_rot2.yuv -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i ${ver_dir}face_1_${W_face}x${H_face}_QP${QP}_rot.yuv -f rawvideo -vcodec rawvideo -s ${W_face}x${H_face} -r ${fps} -pix_fmt yuv420p -i ${ver_dir}face_2_${W_face}x${H_face}_QP${QP}.yuv -filter_complex \"[0:v]pad=iw*3:ih*2[tmp1];[tmp1][1:v]overlay=W/3:0[tmp2];[tmp2][2:v]overlay=2*W/3:0[tmp3];[tmp3][3:v]overlay=shortest=1:y=H/2[tmp4];[tmp4][4:v]overlay=shortest=1:x=W/3:y=H/2[tmp5];[tmp5][5:v]overlay=shortest=1:x=2*W/3:y=H/2[vid]\" -map [vid] ${ver_dir}CMP_${CMP_W}x${CMP_H}_QP_${QP}.yuv";
			print "##############\n$cmd\n##############\n";
			system $cmd;
		}
	}
		# exit;
		# cleaning
		$cmd = "rm ${ver_dir}*QP${QP}*.yuv";
		print "$cmd\n";
		# exit;
		system $cmd;
		# calculate distortions
		if(-e "${vname}/log_psnr_CMP_${No_face_tile_W}x${No_face_tile_H}_QP_${QP}.txt"){
			print "${vname}/log_psnr_CMP_${No_face_tile_W}x${No_face_tile_H}_QP_${QP}.txt existed !\n";
		}else{
			# exit;
			$cmd = "./TApp360ConvertStatic -w 1 -r $refVideo --SphFile=sphere_655362.txt --ReferenceGeometryType=0 --ReferenceFaceWidth=${W_yuv} --ReferenceFaceHeight=${H_yuv} -i ${ver_dir}CMP_${CMP_W}x${CMP_H}_QP_${QP}.yuv -wdt ${CMP_W} -hgt ${CMP_H} --InputBitDepth=8 --OutputBitDepth=8 -fr 24 -fs 0 -icf 420 --SourceFPStructure=\"2 3 4 0 0 0 5 0 3 180 1 270 2 0\" --InputGeometryType=1 --CodingGeometryType=1 --CodingFPStructure=\"2 3 4 0 0 0 5 0 3 180 1 270 2 0\" --CodingFaceWidth=${W_face} --CodingFaceHeight=${H_face} -f $No_fr -o try.yuv > ${vname}/log_psnr_CMP_${No_face_tile_W}x${No_face_tile_H}_QP_${QP}.txt";
			# exit;
			system $cmd;
		}
		# exit;
		# extract result
		my $LOG;
		my @arr;
		my $log_psnr = "${vname}/log_psnr_CMP_${No_face_tile_W}x${No_face_tile_H}_QP_${QP}.txt";
		print "$log_psnr\n";
		open $LOG, "$log_psnr"; # contain frames's actual viewport
		while (<$LOG>){
			chomp;
			my $line = $_;
			# print "$line\n";
			if ($line =~ $refVideo && $line =~ /PSNRS/){
				print "$line\n";
				my $start_pos = index $line, "PSNRS";
				$line = substr $line, $start_pos;
				# exit;
				@arr = ($line =~ /(\d+)/g);
				$PSNR[$c][$ver_id] = ( 6 * "$arr[0].$arr[1]" + "$arr[2].$arr[3]" + "$arr[4].$arr[5]")/8.0; 
				$SPSNR_NN[$c][$ver_id] = ( 6 * "$arr[6].$arr[7]" + "$arr[8].$arr[9]" + "$arr[10].$arr[11]")/8.0; 
				$WSPSNR[$c][$ver_id] = ( 6 * "$arr[12].$arr[13]" + "$arr[14].$arr[15]" + "$arr[16].$arr[17]")/8.0; 
				$SPSNR_I[$c][$ver_id] = ( 6 * "$arr[18].$arr[19]" + "$arr[20].$arr[21]" + "$arr[22].$arr[23]")/8.0; 
				print "PNSR = $PSNR[$c][$ver_id] $SPSNR_NN[$c][$ver_id] $WSPSNR[$c][$ver_id] $SPSNR_I[$c][$ver_id] \n";
				# print "$arr[5].$arr[6] $arr[7].$arr[8] $arr[9].$arr[10] $arr[11].$arr[12]\n";
				printf $FOUT "%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", $QP, $BR[$ver_id], $PSNR[$c][$ver_id], $SPSNR_NN[$c][$ver_id], $WSPSNR[$c][$ver_id], $SPSNR_I[$c][$ver_id];
			}
		}
		# cleaning
	 	$cmd = "rm ${ver_dir}*.yuv";
	 	system $cmd;
		# exit;
    	$ver_id ++;
	}
	close $FOUT;
}