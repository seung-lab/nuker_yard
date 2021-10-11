#!/bin/sh 

BLOCK_SIZE='128 2048 2048'

QUEUE=chunkflow-shang

PRODUCE="$HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py"


# phase3 image
#python3 $PRODUCE -g 102 8 12 -q $QUEUE -b $BLOCK_SIZE -s 14825 3788 3000

# phase2 image
python3 $PRODUCE -g 102 8 11 -q $QUEUE -b $BLOCK_SIZE -s 14825 5000 4000


# CMDLINE="python3 $PRODUCE -g 1 1 1 -q $QUEUE -b $BLOCK_SIZE -s "
# $CMDLINE 25001  5324 22200 # p3 vessel/pia #1 part1 
