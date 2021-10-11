#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"


export CONVNET_MODEL_NAME="net_allen.py"
export CONVNET_WEIGHT_NAME="allen/best_checkpoint.pytorch"


export IMAGE_LAYER_PATH="gs://neuroglancer/basil_v0/son_of_alignment/v3.04_cracks_only_normalized_rechunked/"

export NETOUTPUT_PATH="gs://microns-seunglab/basil_v0/nucleus/allen"


export VISIBILITY_TIMEOUT="1800" # "700"
export QUEUE_NAME="chunkflow-shang"


	#fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	#generate-task --offset 0 3520 10048 --shape 128 2048 2048 \
	#generate-task --offset 0 3520 12096 --shape 128 2048 2048 \
	#generate-task --offset 256 3520 12096 --shape 128 2048 2048 \
	#generate-task --offset 0 3520 12096 --shape 128 2048 2048 \

seq 3 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {}\; \
	\
	chunkflow --verbose --mip 4 \
	\
	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	\
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 64 64 64 --name cutout-em \
	\
	inference \
	\
	--convnet-model="/import/${CONVNET_MODEL_NAME}" --convnet-weight-path="/import/${CONVNET_WEIGHT_NAME}" \
	\
	--patch-size 256 256 256 --patch-overlap 64 64 64 \
	--original-num-output-channels 1 --num-output-channels 1 \
	--framework='pytorch' --batch-size 1 \
	\
	crop-margin save --name="save-netoutput" --volume-path="$NETOUTPUT_PATH" \
	--upload-log --nproc 0 cloud-watch delete-task-in-queue; 

