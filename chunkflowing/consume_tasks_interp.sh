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



export IMAGE_LAYER_PATH="gs://neuroglancer/basil_v0/son_of_alignment/v3.04_cracks_only_normalized_rechunked/"
export NETOUTPUT_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0"
#export OUTPUT_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0_z_interp"
export OUTPUT_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0_z_intp"
export OUTPUT1_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0_z_intp_intp"
export OUTPUT2_LAYER_PATH="gs://microns-seunglab/basil_v0/nucleus/v0_z_intp_blur"
export VISIBILITY_TIMEOUT="14800" # "700"
export QUEUE_NAME="chunkflow-shang"


#seq 3 | parallel -j 11 --delay 120 --ungroup echo Starting worker {}\; time taskset -c {} chunkflow --verbose --mip 4 \

: <<'disabled'
seq 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {} on '$((2*{}))'-'$((2*{}+1))'\; taskset -c '$((2*{}))'-'$((2*{}+1))' \
	chunkflow --verbose --mip 4 \
	generate-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 5 0 0 --name cutout-em --storage-var-name cutout-em \
	cutout --volume-path="$NETOUTPUT_LAYER_PATH" --expand-margin-size 5 0 0 \
	z-interpolate-blanks --refvol cutout-em --planar-dilation 3 \
	crop-margin save --volume-path="$OUTPUT_LAYER_PATH" \
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  
disabled

	#python -m pdb \
# parallel invokes another shell, so have to double quote/escape to preserve quotes and others in strings
seq 6 6 | parallel -j 11 --delay 360 --ungroup echo Starting worker {} on '$((2*{}))'-'$((2*{}+1))'\; taskset -c '$((2*{}))'-'$((2*{}+1))' \
	/opt/conda/bin/chunkflow --verbose --mip 4 \
	generate-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$OUTPUT_LAYER_PATH" --expand-margin-size 5 0 0 \
	copy-var --name="makecopy" --from-name='chunk' --to-name='chunkcopy' \
	custom-chunk-op --name="cleanup1" --opprogram="/import/cf_clean_up_slice_errors.py" --args=\''method="interp"'\' \
	crop-margin save --name="save1" --volume-path="$OUTPUT1_LAYER_PATH" \
	copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	custom-chunk-op --name="cleanup2" --opprogram="/import/cf_clean_up_slice_errors.py" --args=\''method="blur"'\' \
	crop-margin save --name="save2" --volume-path="$OUTPUT2_LAYER_PATH" \
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  

