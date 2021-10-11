#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc


export CONVNET_MODEL_NAME="net.py" #UNet.py"
export CONVNET_WEIGHT_NAME="flyem/model600000.chkpt"


#export BASE_PATH="gs://neuroglancer/drosophila_v0/image_v14_single_slices"
export BASE_PATH="gs://microns-seunglab/drosophila_v0"

export IMAGE_LAYER_PATH="$BASE_PATH/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02"  # in single slice chunks

export NETOUTPUT_PATH="$BASE_PATH/nucleus/v0test"

export OUTPUT_PATH="$BASE_PATH/nucleus/normtest"
export OUTPUT_PATH="$BASE_PATH/nucleus/normtest01"
export OUTPUT_PATH="$BASE_PATH/nucleus/normtestf"

export VISIBILITY_TIMEOUT="700" # "3600" # "60"
export QUEUE_NAME="chunkflow-shang"

if [ -z ${WORKDIR+x} ];
	then export WORKDIR="."; #"/import" ;
fi
echo "\n WORKDIR is set to '$WORKDIR' \n";
#export WORKDIR="/import"
#export WORKDIR="/net"
export CF_OPPROGRAM="$WORKDIR/cf_calls.py"

echo $OUTPUT_PATH



# Note normalize-section-shang was hacked to make chunk normalization.

	#generate-task --offset 4385 6656 11008 --shape 32 3328 1792 \
	#generate-task --offset 2145 6656 16384 --shape 32 3328 1792 \

#	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
seq 8 8 | parallel -j 11 --delay 150 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 3 \
	\
	generate-task --offset 4417 9984 28928 --shape 32 3328 1792 \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 5 128 128 --name cutout-em \
	\
	normalize-section-shang  --nominalmin "-1.0" --nominalmax 1.0 \
	\
	crop-margin save --name="save0" --volume-path="$OUTPUT_PATH" \
	\
	#--upload-log --nproc 0 cloud-watch delete-task-in-queue;  

# 97-129_6656-9984_18176-19968
#	generate-task --offset 97 6656 18176 --shape 32 3328 1792 \

# 4385-4417_6656-9984_11008-12800
#	generate-task --offset 4385 6656 11008 --shape 32 3328 1792 \
# 4385-4417_6656-9984_12800-
#	generate-task --offset 4385 6656 12800 --shape 32 3328 1792 \

#	normalize-section-shang  --nominalmin "-1.0" --nominalmax 1.0 \