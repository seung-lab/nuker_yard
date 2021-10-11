#!/bin/sh 

# s1 
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 0 0 -b 156 1280 1280 -g 12 5 5 -q chunkflow-s1

# nucleus detection
# minnie test cube
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 153 70000 180000 -b 1024 512 512 -g 61 5 5 -q chunkflow-shang


# 2019.08.15,  17920-17984_12096-12352_12096-12352, vol possibly with blanks
# 64x256x256

# this one was not run?
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 17920 12096 12096 -b 64 2048 2048  -g 1 1 1 -q chunkflow-shang

# 2019.08.16,  17920-18048_12096-16192_12096-16192, vol possibly with blanks - no,
#  didn't see blanks in the vol: mip0 coord: 17920-18048_(193536 259072)*2
# Note this overlaps with (and must've overwrote) the 2019.08.15 one
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 17920 12096 12096 -b 128 4096 4096  -g 1 1 1 -q chunkflow-shang
# expand-margin-size 5 128 128


# 2020.01.17 not yet
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 17920 12096 12096 -b 64 2048 2048  -g 1 1 1 -q chunkflow-shang



# Notes up to 20190903:

#2048 blocks. 1200GiB gpu mem, 16-40 GiB machine mem for inference, 
baseline 24 9.39Gib  64
95.2

71.2 GiB (i.e. 44GiB added) for 1 z-interp + 9.8 GiB for each saved copy
= 81 GiB

61
138*4352*4352*4(float32)/1024/1024 = 9970 MiB

2GiB image ~ 2 hour (<2 without both methods), 5min inference
this is just 2.4x of the  999 640 1408 , 2.4x124=295s cleanup1, 2.4x42s=100s cutout - bad ref volume
2.4x152=365s cleanup1, 2.4x512s=1228s cutout

# end "Notes up to 20190903", comparing against previous basil run