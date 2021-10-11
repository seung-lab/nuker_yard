#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc

export CONVNET_MODEL_NAME="net_RSU.py"
export CONVNET_WEIGHT_NAME="rsu_model773000.chkpt"
export CONVNET_WEIGHT_NAME="rsu_model1195000.chkpt"

export CONVNET_MODEL_NAME="net_RSU3.py"
export CONVNET_WEIGHT_NAME="rsu3_model1200000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3_model1600000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3_model2174000.chkpt"  # a little hole at initial slice
export CONVNET_WEIGHT_NAME="rsu3.3_model4906000.chkpt" #holes... lots of them
export CONVNET_WEIGHT_NAME="rsu3.3_model4837000.chkpt" #minnie holes
export CONVNET_WEIGHT_NAME="rsu3.4_model4701000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.5m_model5471000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.5m_model5505000.chkpt"
# export CONVNET_WEIGHT_NAME="rsu3.5m_model5528000.chkpt"
# export CONVNET_WEIGHT_NAME="rsu3.5m2_model5728000.chkpt"
# export CONVNET_WEIGHT_NAME="rsu3.5m2_model5801000.chkpt"
# export CONVNET_WEIGHT_NAME="rsu3.5m2_model5823000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.5m2_model5858000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.5m2_model5897000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.5m2_model5907000.chkpt"
export CONVNET_WEIGHT_NAME="rsu3.5m2_model6500000.chkpt"

#export CONVNET_WEIGHT_NAME="model.chkpt"




export BASE_PATH="gs://microns-seunglab/drosophila_v0"
export IMAGE_LAYER_PATH="$BASE_PATH/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02"  # in single slice chunks
export NETOUTPUT_PATH="gs://shang-scratch/fly_nuc_test"





if [ -z ${WORKDIR+x} ];
	then export WORKDIR="."; #"/import" ;
fi
echo "\n WORKDIR is set to '$WORKDIR' \n";

# DEBUGGING:
#ls -al $WORKDIR



export VISIBILITY_TIMEOUT="3800" # GCP ~1800s w 4 parallel, 1350 w 3, on T4. 3400s w 3 on K80. AWS T4 just 500s single 
export QUEUE_NAME="chunkflow-shang"

# export VISIBILITY_TIMEOUT="70" # "700"
# export QUEUE_NAME="chunkflow-shang"



#193536, 193536, 17927

#	generate-task --offset 17920 12096 12096 --shape 192 2048 2048 \
#	generate-task --offset 17920 12096 12096 --shape 128 2048 2048 \
#minnie2020 #	generate-task --offset 14976 12608 19904 --shape 128 896 896

	#fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	#cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 16 64 64 --name cutout-em \
	#--patch-size 64 256 256 --patch-overlap 16 64 64 --output-key='nucleus' \

	#cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 12 80 80 --name cutout-em \
	#--patch-size 32 160 160 --patch-overlap 8 48 48 --output-key='nucleus' \

seq 3 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 3 \
	\
	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 16 64 64 --name cutout-em --fill-missing \
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

