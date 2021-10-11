#!/bin/sh 

# s1 
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 0 0 -b 156 1280 1280 -g 12 5 5 -q chunkflow-s1

# minnie02
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 19968 60160 99840 -b 156 1280 1280 -g 14 69 17 -q chunkflow-v1-interp

# minnieX
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 19968 71680 38400 -b 156 1280 1280 -g 14 77 124 -q chunkflow-v1-interp

# minnie65
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 14820 43520 30720 -b 156 1280 1280 -g 84 99 144 -q chunkflow-minnie65

# nucleus detection
# basil test cube with a size about 4kx4kx8k
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 153 70000 180000 -b 1024 512 512 -g 61 5 5 -q chunkflow-shang
python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 -192 -192 -b 128 3712 4096  -g 8 5 4 -q chunkflow-shang
# rework regions with wrong grey normalization
python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 3520 12096 -b 128 3712 4096  -g 1 1 1 -q chunkflow-shang
python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 7232 -192 -b 128 3712 4096  -g 1 1 3 -q chunkflow-shang


# z-interpolate stitching
#python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 -192 -192 -b 999 1024 1024  -g 1 19 16 -q chunkflow-shang
python3 $HOME/workspace/chunkflow/bin/produce_tasks.py -s 0 -192 -192 -b 999 640 1408  -g 1 29 11 -q chunkflow-shang