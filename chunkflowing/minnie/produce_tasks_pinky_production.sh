#!/bin/sh 

BLOCK_SIZE='128 1280 2816'   #13.2GB 

QUEUE=chunkflow-shang

PRODUCE="$HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py"


python3 $PRODUCE -g 17 3 2 -q $QUEUE -b $BLOCK_SIZE -s 1 1909 2187


