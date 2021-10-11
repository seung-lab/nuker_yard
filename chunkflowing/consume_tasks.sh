#!/bin/sh 

#source $HOME/.bashrc

## basil v
#python consume_tasks.py --image-layer-path="gs://microns-seunglab/minnie_v0/minnie10/image" \
#    --output-layer-path="gs://microns-seunglab/minnie_v0/minnie10/affinitymap/test" \
#    --convnet-model-path="/nets/model700000.chkpt" --convnet-weight-path="/nets/model700000.chkpt" \
#    --queue-name chunkflow --patch-size 20 256 256 --patch-overlap 4 64 64 --cropping-margin-size 4 64 64 \
#    --output-key affinity --num-output-channels 3 --mip 1 --framework pytorch-multitask \
#    --image-validate-mip 5 --visibility-timeout 1800 --proc-num 1 --interval 300



# test run for model selection
export CONVNET_MODEL_NAME="net.py" #UNet.py"
export CONVNET_WEIGHT_NAME="model250000.chkpt"
#export CONVNET_PATH="/import/${CONVNET_MODEL_NAME}"
export IMAGE_LAYER_PATH="gs://neuroglancer/basil_v0/son_of_alignment/v3.04_cracks_only_normalized_rechunked/"
export OUTPUT_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0"
export VISIBILITY_TIMEOUT="1800" # "700"
export QUEUE_NAME="chunkflow-shang"

#mkdir /nets; cd /nets; 
#--wget -nc -nv "${CONVNET_PATH}${CONVNET_MODEL_NAME}"
#--wget -nc -nv "${CONVNET_PATH}${CONVNET_WEIGHT_NAME}"
seq 10 | parallel -j 10 --delay 120 --ungroup echo Starting worker {}\; chunkflow --verbose --mip 4 \
	generate-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 0 128 128 \
	normalize-section-mu  --nominalmin "-1.0" --nominalmax 1.0 \
	inference \
	\
	--convnet-model="/import/${CONVNET_MODEL_NAME}" --convnet-weight-path="/import/${CONVNET_WEIGHT_NAME}" \
	\
	--patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \
	--original-num-output-channels 1 --num-output-channels 1 \
	--framework='pytorch' --batch-size 32 \
	crop-margin save --volume-path="$OUTPUT_LAYER_PATH" \
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  

#  margin / overlap?
#CUDA_VISIBLE_DEVICES=2,3 

# Ran with wrong renormalization on these blocks:
# 0-128_3520-7232_12096-16192.json	269 B	application/json	Regional	3/29/19, 5:36:31 PM UTC-4	
# 0-128_7232-10944_-192-3904.json	269 B	application/json	Regional	3/29/19, 5:53:18 PM UTC-4	
# 0-128_7232-10944_3904-8000.json	269 B	application/json	Regional	3/29/19, 6:13:57 PM UTC-4	
# 0-128_7232-10944_8000-12096.json