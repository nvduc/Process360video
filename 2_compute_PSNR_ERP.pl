#! /bin/perl -w
use strict;
use warnings;

# -------------------- Variable --------------------- # 
# my $video_name 				= "Elephant";
my $video_name 				= $ARGV[0];
# my $ERP_W = 3840;
# my $ERP_H = 1920;
my $ref_W = $ARGV[4];
my $ref_H = $ARGV[5];
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
my $No_FR = 48;
my $No_skip = 0;
my $QP;
my $erp_H = $ARGV[3];
my $erp_W = $ARGV[2];
my $tile_W;
my $tile_H;
my $W_tile_num;
my $H_tile_num;
my $tile_num;
my $No_ver = 7;
my $ver_id;
my $tile_id;
my @tile_list = qw(2);
my $tile_folder;
my $log_folder;
my $tile_yuv;
my @longitude;
my @altitude;
my $tmp;
my $i;
my $j;
my $cmd;
my @title_name;
my $t_skip = 0;
my $No_fr = 48;
my $ver_dir;
my $out;
# my $refVideo = "../Dataset/videos/Elephant_10s_20s.yuv";
# my $refVideo = "../Dataset/videos/Paris_3min20_3min25.yuv";
my $refVideo = $ARGV[1];
my @PSNR;
my @SPSNR_NN;
my @WSPSNR;
my @SPSNR_I;
my $LOG;
my $FOUT;
my @BR;
my $tile_size;
print "$ARGV[0] $ARGV[1]\n";
# exit;

# for(my $c = 0; $c < 1; $c++){
for(my $c = 0; $c < $No_scheme; $c++){
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
    #
    # $W_tile_num = 1;
	# $H_tile_num = 1;
	open $FOUT,'>', "${video_name}/RD_ERP_${W_tile_num}x${H_tile_num}.txt";
	print $FOUT "QP\tBitrate\tPSNR\tSPSNR_NN\tWSPSNR\tSPSNR_I\n";
    #
    $tile_yuv = "../Dataset/${video_name}/GOP_${GoP}/" . $W_tile_num . 'x' . $H_tile_num . '/tile_yuv';
    $ver_dir = "tmp";
    if(-d $ver_dir){
    	print "Folder exists !\n";
    }else{
    	print "#[Log] Creating folder !\n";
    	$cmd = "mkdir $ver_dir";
    	system $cmd;
    }
    # exit;
    #
    # reconstruct ERP from tiles for each version
    # mp4 -> yuv
    $ver_id = 0; 
    foreach $QP (@QP_ar){
    	print "#[Log] QP=${QP}\n";
    	# calculate version bitrate
    	$BR[$ver_id] = 0;
    	for(my $i=0; $i < $tile_num; $i++){
    		$title_name[$i] = "${tile_yuv}/Tile_${i}_${tile_W}x${tile_H}_QP_${QP}.h265";
    		$tile_size = -s $title_name[$i];
            # print "Tile $i : $title_name[$i] : $tile_size\n";
            $BR[$ver_id] += $tile_size;
    	}
    	$BR[$ver_id] = ($BR[$ver_id] * 8.0 / 1000.0)/(${No_fr} * 1.0 / ${frame_rate});
    	# 
    	$out = "${ver_dir}/ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.yuv"; 
    	if(-e $out || -e "${video_name}/log_psnr_ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.txt"){
    		print "File existed !\n"
    	}else{
    		# exit;
    		# decode tiles
	    	for (my $i = 0; $i < $tile_num; $i++) {
				$title_name[$i] = "${ver_dir}/Tile_${i}_${tile_W}x${tile_H}_QP_${QP}.yuv";
				if(-e $title_name[$i]){

				}else{
					$cmd = "ffmpeg -r 1 -i ${tile_yuv}/Tile_${i}_${tile_W}x${tile_H}_QP_${QP}.h265 -ss $t_skip -frames $No_fr $title_name[$i]";
					print "$cmd\n";
					system $cmd;
				}
			}
			# exit;
			# Reconstruct ERP
		    for ($i = 0; $i < $H_tile_num; $i++) {
				$cmd = "ffmpeg -y";
				for($j=0; $j < $W_tile_num; $j++){
					$tile_id = $i * $W_tile_num + $j;
					$tmp = " -f rawvideo -vcodec rawvideo -s ${tile_W}x${tile_H} -r 1 -pix_fmt yuv420p -i $title_name[${tile_id}]";
					$cmd = $cmd . $tmp;
				}
				#
				$tmp = " -filter_complex \"[0:v]pad=iw*${W_tile_num}:ih*1";
				$cmd = $cmd . $tmp;
				#
				for($j=1; $j < $W_tile_num; $j++){
					$tmp = "[tmp${j}];[tmp${j}][${j}:v]overlay=shortest=1:x=${j}*W/${W_tile_num}:y=0";
					$cmd = $cmd . $tmp;
				}
				$tmp = "[vid]\" -map [vid] -vframes $No_fr ${ver_dir}/tmp_${i}_${erp_W}x${tile_H}.yuv";
				$cmd = $cmd . $tmp;
				print "$cmd\n";
				system $cmd;
			}
			$cmd = "ffmpeg -y";
			for($j=0; $j < $H_tile_num; $j++){
				$tmp = " -f rawvideo -vcodec rawvideo -s ${erp_W}x${tile_H} -r 1 -pix_fmt yuv420p -i ${ver_dir}/tmp_${j}_${erp_W}x${tile_H}.yuv";
				$cmd = $cmd . $tmp;
			}
			#
			$tmp = " -filter_complex \"[0:v]pad=iw*1:ih*${H_tile_num}";
			$cmd = $cmd . $tmp;
			#
			for ($j = 1; $j < $H_tile_num; $j++) {
				$tmp = "[tmp${j}];[tmp${j}][${j}:v]overlay=shortest=1:x=0:y=${j}*H/${H_tile_num}";
				$cmd = $cmd . $tmp;	
			}
			$tmp = "[vid]\" -map [vid] -vframes $No_fr ${ver_dir}/ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.yuv"; 
			$cmd = $cmd . $tmp;
			print "$cmd\n";
			system $cmd;
			# clean
			$cmd = "rm ${ver_dir}/Tile_*.yuv";
			system $cmd;
			# exit;
		}
		# exit;
		# Calculate bitrate and distortion
		$cmd = "./TApp360ConvertStatic -w 1 -r $refVideo --SphFile=sphere_655362.txt --ReferenceGeometryType=0 --ReferenceFaceWidth=${ref_W} --ReferenceFaceHeight=${ref_H} -i ${ver_dir}/ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.yuv -wdt ${ERP_W} -hgt ${ERP_H} --InputBitDepth=8 --OutputBitDepth=8 -fr 24 -fs 0 -icf 420 --SourceFPStructure=\"1 1 0 0\" --InputGeometryType=0 --CodingGeometryType=0 --CodingFPStructure=\"1 1 0 0\" --CodingFaceWidth=${ERP_W} --CodingFaceHeight=${ERP_H} -f $No_fr -o try.yuv > ${video_name}/log_psnr_ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.txt";
		if(-e "${video_name}/log_psnr_ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.txt"){
			print "${video_name}/log_psnr_ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.txt existed !\n";
		}else{
			# exit;
			print "$cmd\n";
			system $cmd;
			# clean
			$cmd = "rm ${ver_dir}/*.yuv";
			system $cmd;
			# 
		}
		# exit;
		my $LOG;
		my @arr;
		my $log_psnr = "${video_name}/log_psnr_ERP_${W_tile_num}x${H_tile_num}_QP_${QP}.txt";
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
				printf $FOUT "%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", $QP,$BR[$ver_id], $PSNR[$c][$ver_id], $SPSNR_NN[$c][$ver_id], $WSPSNR[$c][$ver_id], $SPSNR_I[$c][$ver_id];
			}
		}
    	$ver_id ++;
		# exit;
    }
    close $FOUT;
}