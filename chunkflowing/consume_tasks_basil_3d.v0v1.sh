#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"



export CONVNET_MODEL_NAME="net_RSU.py"
export CONVNET_MODEL_NAME="net_RSU3.py"
#export CONVNET_WEIGHT_NAME="rsu_model773000.chkpt"
#	generate-task --offset 0 3520 12096 --shape 192 2048 2048 \
#	--patch-size 32 256 256 --patch-overlap 16 64 64 --output-key='nucleus' \
export CONVNET_WEIGHT_NAME="rsu_model923000.chkpt"
export CONVNET_WEIGHT_NAME="rsu_model999000.chkpt"
# export CONVNET_WEIGHT_NAME="rsu_model1022000.chkpt"
# export CONVNET_WEIGHT_NAME="rsu3_model808000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3_model1600000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3_model2320000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3_model4500000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3_model4616000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.2_model4526000.chkpt"
#export CONVNET_WEIGHT_NAME="rsu3_model4664000.chkpt"  # garbage



export IMAGE_LAYER_PATH="gs://neuroglancer/basil_v0/son_of_alignment/v3.04_cracks_only_normalized_rechunked/"


export NETOUTPUT_PATH="gs://microns-seunglab/basil_v0/nucleus/3d_v0"
export NETOUTPUT_PATH="gs://microns-seunglab/basil_v0/nucleus/3d_test"  # rsu3_model2320000  #example for Forrest  # rsu3_model4616000 at corner
export NETOUTPUT_PATH="gs://microns-seunglab/basil_v0/nucleus/3d_test2"   # corner is rsu3_model4664000
#export NETOUTPUT_PATH="gs://microns-seunglab/basil_v0/nucleus/3d_test3" #rsu3_model1600000 rsu3.2_model4526000
# export NETOUTPUT_PATH="gs://microns-seunglab/basil_v0/nucleus/3d_v1" # not used and non-exist
export NETOUTPUT_PATH="gs://neuroglancer/basil_v0/basil_full/nucleus/3d_v1"




if [ -z ${WORKDIR+x} ];
	then export WORKDIR="."; #"/import" ;
fi
echo "\n WORKDIR is set to '$WORKDIR' \n";

# DEBUGGING:
#ls -al $WORKDIR



export VISIBILITY_TIMEOUT="3800" # ~1800s w 4 parallel, 1350 w 3, on T4. 3400s w 3 on K80.
export QUEUE_NAME="chunkflow-shang"

#T4: 12.1, somehow 13.1GiB for an instant right before a new task
#


#: <<'disabled'

#193536, 56320, 0

	#fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	#generate-task --offset 0 3520 10048 --shape 128 2048 2048 \
	#generate-task --offset 0 3520 12096 --shape 128 2048 2048 \
	#generate-task --offset 256 3520 12096 --shape 128 2048 2048 \
# Inference time: 267s on batchsize 1, 217s on 2, 194s on 3
#patch-size 64 256 256 : 2531MiB GPU  on station1001 for RSU3
#128 2048 2048: 9.4-11.6 GB RAM  during inference

	#generate-task --offset 0 320 832 --shape 128 2048 2048 \

seq 3 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 4 \
	\
	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 16 64 64 --name cutout-em \
	\
	\
	inference \
	\
	--convnet-model="$WORKDIR/${CONVNET_MODEL_NAME}" --convnet-weight-path="$WORKDIR/${CONVNET_WEIGHT_NAME}" \
	\
	--patch-size 64 256 256 --patch-overlap 16 64 64 --output-key='nucleus' \
	--original-num-output-channels 1 --num-output-channels 1 \
	--framework='pytorch' --batch-size 1 \
	\
	crop-margin save --name="save-netoutput" --volume-path="$NETOUTPUT_PATH" \
	\
	\
	\
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  
#disabled

: <<'disabled'
seq 3 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 4 \
	\
	generate-task --offset 448 2112 5952 --shape 64 256 384 \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 0 0 0 --name cutout-em \
	copy-var --name="makecopy-cutout-em" --from-name='chunk' --to-name='cutout-em' \
	\
	\
	inference \
	\
	--convnet-model="/import/${CONVNET_MODEL_NAME}" --convnet-weight-path="/import/${CONVNET_WEIGHT_NAME}" \
	\
	--patch-size 64 256 384 --patch-overlap 0 0 0 --output-key='nucleus' \
	--original-num-output-channels 1 --num-output-channels 1 \
	--framework='pytorch' --batch-size 1 \
	\
	copy-var --name="makecopy-netoutput" --from-name='chunk' --to-name='netoutput' \
	crop-margin save --name="save-netoutput" --volume-path="$NETOUTPUT_PATH" \
	\
	\
	\
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  
disabled

# cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 9 80 80 --name cutout-em \
# 	--patch-size 18 160 160 --patch-overlap 9 80 80 --output-key='nucleus' \
	#--patch-size 18 160 160 --patch-overlap 4 40 40 --output-key='nucleus' \