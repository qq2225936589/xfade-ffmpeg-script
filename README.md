# xfade-ffmpeg-script
A bash script that uses ffmpeg's xfade transition filter to connect multiple video files to a single file.
xfade transition filter - FFmpeg 2020.02.10+
A bash script that uses ffmpeg's xfade transition filter to connect multiple video files to a single file.

Apply cross fade from one input video stream to another input video stream. The cross fade is applied for specified duration.

The filter accepts the following options:
1. 'transition' Set one of available transition effects:
  -1 'custom'
   0 'fade' <--- Default transition effect.
   1 'wipeleft'
   2 'wiperight'
   3 'wipeup'
   4 'wipedown'
   5 'slideleft'
   6 'slideright'
   7 'slideup'
   8 'slidedown'
   9 'circlecrop'
  10 'rectcrop'
  11 'distance'
  12 'fadeblack'
  13 'fadewhite'
  14 'radial'
  15 'smoothleft'
  16 'smoothright'
  17 'smoothup'
  18 'smoothdown'
  19 'circleopen'
  20 'circleclose'
  21 'vertopen'
  22 'vertclose'
  23 'horzopen'
  24 'horzclose'
  25 'dissolve'
  26 'pixelize'
  27 'diagtl'
  28 'diagtr'
  29 'diagbl'
  30 'diagbr'

2. 'duration' Set cross fade duration in seconds. Default duration is 1 second.
3. 'offset'   Set cross fade start relative to first input stream in seconds. Default offset is 0.
4. 'expr'     Set expression for custom transition effect.
The expressions can use the following variables and functions:
  'X' 'Y' The coordinates of the current sample.
  'W' 'H' The width and height of the image.
  'P' Progress of transition effect.
  'PLANE' Currently processed plane.
  'A' Return value of first input at current location and plane.
  'B' Return value of second input at current location and plane.
  'a0(x, y)' 'a1(x, y)' 'a2(x, y)' 'a3(x, y)'
    Return the value of the pixel at location (x,y) of the first/second/third/fourth component of first input.
  'b0(x, y)' 'b1(x, y)' 'b2(x, y)' 'b3(x, y)'
    Return the value of the pixel at location (x,y) of the first/second/third/fourth component of second input.

Cross fade from one input video to another input video, with fade transition and duration of transition of 2 seconds starting at offset of 5 seconds Examples:
ffmpeg -i first.mp4 -i second.mp4 -filter_complex xfade=transition=fade:duration=2:offset=5 output.mp4
