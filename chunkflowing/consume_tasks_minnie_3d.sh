#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc

## basil v
#python consume_tasks.py --image-layer-path="gs://microns-seunglab/minnie_v0/minnie10/image" \
#    --output-layer-path="gs://microns-seunglab/minnie_v0/minnie10/affinitymap/test" \
#    --convnet-model-path="/nets/model700000.chkpt" --convnet-weight-path="/nets/model700000.chkpt" \
#    --queue-name chunkflow --patch-size 20 256 256 --patch-overlap 4 64 64 --cropping-margin-size 4 64 64 \
#    --output-key affinity --num-output-channels 3 --mip 1 --framework pytorch-multitask \
#    --image-validate-mip 5 --visibility-timeout 1800 --proc-num 1 --interval 300


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
export CONVNET_WEIGHT_NAME="rsu3.5m2_model5894000.chkpt"


export BASE_PATH="gs://microns-seunglab/minnie_v4/alignment/fine/sergiy_multimodel_v1/vector_fixer30_faster_v01/image_stitch_multi_block_v1"

#export IMAGE_LAYER_PATH="gs://seunglab2/minnie_v1/alignment/fine/tmacrina_minnie10_serial/image"
export IMAGE_LAYER_PATH="$BASE_PATH"
export IMAGE_LAYER_PATH="https://s3-hpcrc.rc.princeton.edu/minnie65/aligned_image"  #phase 2
#gone precomputed://gs://seunglab_minnie_phase3/sergiy/final_fine_x4/image_stitch_dd200_mip1_final
#back?precomputed://gs://seunglab_minnie_phase3/sergiy/final_fine_x4/image_stitch_dd200_mip1_final
# the 8x8x40 data there is said to be gone, but mip2+ is there.
#gs://minnie65_2020_aligned_em/sergiy/final_fine_x4/image_stitch_dd200_mip1_final
export IMAGE_LAYER_PATH="gs://seunglab_minnie_phase3/sergiy/final_fine_x4/image_stitch_dd200_mip1_final"


#export NETOUTPUT_PATH="gs://microns-seunglab/minnie_v1/nucleus/v0"
export NETOUTPUT_PATH="$BASE_PATH/nucleus/3d_v0"
export NETOUTPUT_PATH="$BASE_PATH/nucleus/3d_test" #rsu_model1195000
export NETOUTPUT_PATH="$BASE_PATH/nucleus/3d_test2"  #rsu3_model1200000
export NETOUTPUT_PATH="$BASE_PATH/nucleus/3d_test3" #rsu3_model1600000 
export NETOUTPUT_PATH="$BASE_PATH/nucleus/3d_test4" #rsu3_model2174000
export NETOUTPUT_PATH="gs://shang-scratch/minnie_nuc_test"  #p2 image. 5528
export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test"  #5471  vol33,29:m1-5528
export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test2"  #5505
# export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test3"  # m2_model5728000 volset2, set3, set1 pias
# #export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test4"  # m2_model5801000 pia/bloodvessel - ouch used phase 2 image
# export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test5"  # m2_model5801000 pia/bloodvessel, set3, mine, all
# export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test6"  # m2_model5801000 pia/bloodvessel #1, 5823
export NETOUTPUT_PATH="gs://shang-scratch/minnie_p3_nuc_test7"  # 5m2_model5858000
#export NETOUTPUT_PATH="gs://shang-scratch/minnie_nuc_test160"
#export NETOUTPUT_PATH="gs://shang-scratch/minnie_nuc_test176"


# export IMAGE_LAYER_PATH="https://minnie65-phase3-em.s3.amazonaws.com/aligned"
# export IMAGE_LAYER_PATH="s3://minnie65-phase3-em/aligned"
# export NETOUTPUT_PATH="s3://minnie65-phase3-nuclei/net-output"



if [ -z ${WORKDIR+x} ];
	then export WORKDIR="."; #"/import" ;
fi
echo "\n WORKDIR is set to '$WORKDIR' \n";

# DEBUGGING:
#ls -al $WORKDIR



export VISIBILITY_TIMEOUT="3800" # ~1800s w 4 parallel, 1350 w 3, on T4. 3400s w 3 on K80.
export QUEUE_NAME="chunkflow-shang"

export VISIBILITY_TIMEOUT="70" # "700"
export QUEUE_NAME="chunkflow-shang"







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
	chunkflow --verbose --mip 4 \
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


# cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 9 80 80 --name cutout-em \
# 	--patch-size 18 160 160 --patch-overlap 9 80 80 --output-key='nucleus' \
	#--patch-size 18 160 160 --patch-overlap 4 40 40 --output-key='nucleus' \