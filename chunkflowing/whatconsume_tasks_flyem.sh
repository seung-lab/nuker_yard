#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc


export CONVNET_MODEL_NAME="net.py" #UNet.py"
export CONVNET_WEIGHT_NAME="flyem/model600000.chkpt"


#export BASE_PATH="gs://neuroglancer/drosophila_v0/image_v14_single_slices"
export BASE_PATH="gs://microns-seunglab/drosophila_v0"

export IMAGE_LAYER_PATH="$BASE_PATH/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02"  # in single slice chunks

export NETOUTPUT_PATH="$BASE_PATH/nucleus/v0"

export OUTPUT_PATH="$BASE_PATH/nucleus/v0_z_intp"

export OUTPUT1_LAYER_PATH="$BASE_PATH/nucleus/v0_z_intp_b1"
export OUTPUT2_LAYER_PATH="$BASE_PATH/nucleus/v0_z_intp_blur1"
export VISIBILITY_TIMEOUT="60" # "3600" # "700"
export QUEUE_NAME="chunkflow-shang"

export WORKDIR="/import"
#export WORKDIR="/net"
export CF_OPPROGRAM="$WORKDIR/cf_calls.py"

echo $OUTPUT_PATH

#seq 3 | parallel -j 11 --delay 120 --ungroup echo Starting worker {}\; time taskset -c {} chunkflow --verbose --mip 4 \


#: <<'disabled'
#seq 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {} on '$((2*{}))'-'$((2*{}+1))'\; taskset -c '$((2*{}))'-'$((2*{}+1))' \
#	custom-operator --name="normalize-section" --opprogram=CF_OPPROGRAM \
#		--args=\''TODO normalize(chunk, method="interp"'\' \


# Note normalize-section-shang was hacked to make chunk normalization.

	#generate-task --offset 17920 12096 12096 --shape 64 256 256 \
seq 3 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 3 \
	\
	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$OUTPUT_PATH" --expand-margin-size 0 0 0 --name cutout-netoutput \
	\
	copy-var --name="makecopy" --from-name='chunk' --to-name='chunkcopy' \
	\
	copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	custom-operator --name="cleanup1" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="blur"'\' \
	crop-margin save --name="save1" --volume-path="$OUTPUT1_LAYER_PATH" \
	copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	custom-operator --name="cleanup2" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="interp"'\' \
	crop-margin save --name="save2" --volume-path="$OUTPUT2_LAYER_PATH" \
	\
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  

	#custom-operator --name="z-interpolate-blanks" --opprogram=CF_OPPROGRAM \
	#	--args=\''TODO z_interpolate_blanks(chunk, method="interp"'\' \
#disabled

