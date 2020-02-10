#!/bin/bash
# Example of concatenating multiple mp4s together with 1-second transitions between them.

transitions=( \
"fade"        \
"wipeleft"    \
"wiperight"   \
"wipeup"      \
"wipedown"    \
"slideleft"   \
"slideright"  \
"slideup"     \
"slidedown"   \
"circlecrop"  \
"rectcrop"    \
"distance"    \
"fadeblack"   \
"fadewhite"   \
"radial"      \
"smoothleft"  \
"smoothright" \
"smoothup"    \
"smoothdown"  \
"circleopen"  \
"circleclose" \
"vertopen"    \
"vertclose"   \
"horzopen"    \
"horzclose"   \
"dissolve"    \
"pixelize"    \
"diagtl"      \
"diagtr"      \
"diagbl"      \
"diagbr"      \
)

length=${#transitions[@]}

interval=2

x264="-look_ahead 0 -ac 2 -c:v h264_qsv -c:a aac -profile:v high -level 3.1 -preset:v veryfast"
ki="-keyint_min 72 -g 72 -sc_threshold 0"
br="-b:v 3000k -minrate 3000k -maxrate 6000k -bufsize 6000k -b:a 128k -avoid_negative_ts make_zero -fflags +genpts"

duration=1
function get_duration_video_ffprobe(){
  duration=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=duration -of default=nokey=1:noprint_wrappers=1 "$1")
  duration=$(echo "scale=3; $duration/1"|bc -l)
}
function get_duration_audio_ffprobe(){
  aduration=$(ffprobe -v error -count_frames -select_streams a:0 -show_entries stream=duration -of default=nokey=1:noprint_wrappers=1 "$1")
  aduration=$(echo "scale=3; $aduration/1"|bc -l)
}

MediaInfo="D:\soft\MediaInfo_CLI_19.04_Windows_x64\MediaInfo.exe"
function get_duration_video_MediaInfo(){
  # duration=$($MediaInfo --Inform="Video;%Duration/String3%" "$1")
  duration=$($MediaInfo --Inform="Video;%Duration%" "$1")
  duration=$(echo "scale=3; $duration/1000"|bc -l)
}
function get_duration_audio_MediaInfo(){
  # duration=$($MediaInfo --Inform="Video;%Duration/String3%" "$1")
  aduration=$($MediaInfo --Inform="Audio;%Duration%" "$1")
  aduration=$(echo "scale=3; $aduration/1000"|bc -l)
}

# ls -u *.mp4       sort by time
# ls *.mp4|sort     sort by name
line=-1
IFS=$(echo -en "\n\b")
for f in `ls *.mp4|sort`; do
     line=$((line+1))
     get_duration_video_MediaInfo "${f}"
     get_duration_audio_MediaInfo "${f}"
	 ifd=`echo "scale=0; ${aduration}*1000-${duration}*1000"|bc -l -q`
	 ifd=${ifd/.000/}
	 echo $((line+1)) ${f} ${duration} - ${aduration} = $ifd
	 if [[ ${ifd} -le 0 ]]; then
	   duration=${aduration}
	 fi
	 #echo ${line} ${f} ${duration}
	 duration_array[${line}]=${duration}
	 filename_array[${line}]=${f}
	 index_array[${line}]=${line}
done

vfstr=""
for i in ${index_array[@]}; do
	 catlen=0$(echo ${duration_array[$i]}-${interval}|bc -l)
     if [ ${i} -lt ${line} ]
         then
             vfstr=${vfstr}"[$i:a]atrim=0:$catlen[a$i];"
	     else
		     vfstr=${vfstr}"[$i:a]atrim=0:${duration_array[$i]}[a$i];"
     fi
     vfstr=${vfstr}"[$i:v]split[v${i}00][v${i}10];"
done

for i in ${index_array[@]}; do
	 catlen=0$(echo ${duration_array[$i]}-${interval}|bc -l)
     vfstr=${vfstr}"[v${i}00]trim=0:$catlen[v${i}01];"
     vfstr=${vfstr}"[v${i}10]trim=$catlen:${duration_array[$i]}[v${i}11t];"
     vfstr=${vfstr}"[v${i}11t]setpts=PTS-STARTPTS[v${i}11];"
done

for ((i=0; i<$line; ++i)) ; do
    Index=$[i%(($length))]
    #Index=$[RANDOM%(($length1))]
	echo ${transitions[$Index]}
    vfstr=${vfstr}"[v${i}11][v$((i+1))01]xfade=duration=${interval}:transition=${transitions[$Index]}[vtt${i}];"
    vfstr=${vfstr}"[vtt${i}]drawtext=fontfile='D\:/ffmpeg/libs/LED_font.ttf':fontcolor=0xf0f0f0@0.6:fontsize=80:bordercolor=0xe0e0e0@0.6:borderw=1:box=1: boxcolor=0x303030@0.2:boxborderw=12:shadowcolor=0x303030:shadowx=2:shadowy=2:x=(w-tw)/2:y=3*h/4:enable='between(t,0,${interval})':text='\ xfade ${i} ${transitions[$Index]}\ '[vt${i}];"
done

vfstr=${vfstr}"[v001]"
for ((i=0; i<$line; ++i)) ; do
    vfstr=${vfstr}"[vt${i}]"
done
vfstr=${vfstr}"[v${line}11]concat=n=$((line+2))[outv];"

for i in ${index_array[@]}; do
    vfstr=${vfstr}"[a${i}]"
done
vfstr=${vfstr}"concat=n=$((line+1)):v=0:a=1[outa]"

infile=""
for i in ${filename_array[@]}; do
     infile=${infile}" -i \"$i\""
done

if [ ! -d "merge" ];then
  mkdir merge
fi

echo ${vfstr} > _vfstr_.txt
cmd="ffmpeg -hide_banner${infile} \
-filter_complex_script \"_vfstr_.txt\" \
-map [outv] -map [outa] ${x264} ${ki} ${br} \
-y ./merge/ffmpeg-xfade-concat-drawtext.mp4"

echo $cmd >_merge_.cmd
#./_merge_.cmd

echo $cmd
bash -c "$cmd"
