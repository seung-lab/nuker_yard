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


export CONVNET_MODEL_NAME="net.py" #UNet.py"
export CONVNET_WEIGHT_NAME="model250000.chkpt"


export BASE_PATH="gs://microns-seunglab/minnie_v4/alignment/fine/sergiy_multimodel_v1/vector_fixer30_faster_v01/image_stitch_multi_block_v1"

export IMAGE_LAYER_PATH="gs://seunglab2/minnie_v1/alignment/fine/tmacrina_minnie10_serial/image"
export IMAGE_LAYER_PATH="$BASE_PATH"


export NETOUTPUT_PATH="gs://microns-seunglab/minnie_v1/nucleus/v0"
export NETOUTPUT_PATH="$BASE_PATH/nucleus/v0"

#export OUTPUT_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0_z_interp"
export OUTPUT_PATH="$BASE_PATH/nucleus/v0_z_intp"

export OUTPUT1_LAYER_PATH="$BASE_PATH/nucleus/v0_z_intp_intp"
export OUTPUT2_LAYER_PATH="$BASE_PATH/nucleus/v0_z_intp_blur"
export VISIBILITY_TIMEOUT="14800" # "700"
export QUEUE_NAME="chunkflow-shang"

export CF_OPPROGRAM="/import/cf_calls.py"

echo $OUTPUT_PATH

#seq 3 | parallel -j 11 --delay 120 --ungroup echo Starting worker {}\; time taskset -c {} chunkflow --verbose --mip 4 \


#: <<'disabled'
#seq 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {} on '$((2*{}))'-'$((2*{}+1))'\; taskset -c '$((2*{}))'-'$((2*{}+1))' \
#	custom-operator --name="normalize-section" --opprogram=CF_OPPROGRAM \
#		--args=\''TODO normalize(chunk, method="interp"'\' \

#TODO: cloudvolume.exceptions.EmptyVolumeException: 64_64_40/1856-2880_-192-832_0-1


	#generate-task --offset 17920 12096 12096 --shape 64 256 256 \
seq 3 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 4 \
	\
	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 5 128 128 --name cutout-em \
	copy-var --name="makecopy-cutout-em" --from-name='chunk' --to-name='cutout-em' \
	\
	normalize-section-shang  --nominalmin "-1.0" --nominalmax 1.0 \
	\
	inference \
	\
	--convnet-model="/import/${CONVNET_MODEL_NAME}" --convnet-weight-path="/import/${CONVNET_WEIGHT_NAME}" \
	\
	--patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \
	--original-num-output-channels 1 --num-output-channels 1 \
	--framework='pytorch' --batch-size 32 \
	\
	copy-var --name="makecopy-netoutput" --from-name='chunk' --to-name='netoutput' \
	crop-margin save --name="save-netoutput" --volume-path="$NETOUTPUT_PATH" \
	\
	\
	copy-var --name="restorecopy-netoutput" --from-name='netoutput' --to-name='chunk' \
	z-interpolate-blanks --refvol cutout-em --planar-dilation 3 \
	\
	copy-var --name="makecopy" --from-name='chunk' --to-name='chunkcopy' \
	crop-margin save --name="save0" --volume-path="$OUTPUT_PATH" \
	\
	copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	custom-operator --name="cleanup1" --opprogram="/import/cf_clean_up_slice_errors.py" --args=\''method="interp"'\' \
	crop-margin save --name="save1" --volume-path="$OUTPUT1_LAYER_PATH" \
	copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	custom-operator --name="cleanup2" --opprogram="/import/cf_clean_up_slice_errors.py" --args=\''method="blur"'\' \
	crop-margin save --name="save2" --volume-path="$OUTPUT2_LAYER_PATH" \
	\
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  

	#custom-operator --name="z-interpolate-blanks" --opprogram=CF_OPPROGRAM \
	#	--args=\''TODO z_interpolate_blanks(chunk, method="interp"'\' \
#disabled

