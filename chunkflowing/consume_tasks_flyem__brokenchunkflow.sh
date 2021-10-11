#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc


export CONVNET_MODEL_NAME="net.py" #UNet.py"
export CONVNET_WEIGHT_NAME="flyem/model600000.chkpt"


#export BASE_PATH="gs://neuroglancer/drosophila_v0/image_v14_single_slices"
export BASE_PATH="gs://microns-seunglab/drosophila_v0"

export IMAGE_LAYER_PATH="$BASE_PATH/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02"  # in single slice chunks

export NETOUTPUT_PATH="$BASE_PATH/nucleus/v1"

export OUTPUT_PATH="$BASE_PATH/nucleus/v1_z_intp"

export OUTPUT1_LAYER_PATH="$BASE_PATH/nucleus/v1_z_intp_intp"
export OUTPUT2_LAYER_PATH="$BASE_PATH/nucleus/v1_z_intp_blur"
export VISIBILITY_TIMEOUT="70" # "3600" # "60"
export QUEUE_NAME="chunkflow-shang"

if [ -z ${WORKDIR+x} ];
	then export WORKDIR="."; #"/import" ;
fi
echo "\n WORKDIR is set to '$WORKDIR' \n";
#export WORKDIR="/import"
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
seq 8 8 | parallel -j 11 --delay 150 --ungroup echo Starting worker {}\; \
	chunkflow --verbose --mip 3 \
	\
	fetch-task --queue-name="$QUEUE_NAME" --visibility-timeout=$VISIBILITY_TIMEOUT \
	cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 5 128 128 --name cutout-em \
	copy-var --name="makecopy-cutout-em" --from-name='chunk' --to-name='cutout-em' \
	\
	normalize-section-shang  --nominalmin "-1.0" --nominalmax 1.0 \
	\
	inference \
	\
	--convnet-model="$WORKDIR/${CONVNET_MODEL_NAME}" --convnet-weight-path="$WORKDIR/${CONVNET_WEIGHT_NAME}" \
	\
	--input-patch-size 1 3584 2048 --output-patch-overlap 0 128 128 --patch-num 1 1 1 \
 	--framework='pytorch' --batch-size 1 \
	--num-output-channels 1 \
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
	custom-operator --name="cleanup1" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="interp"'\' \
	crop-margin save --name="save1" --volume-path="$OUTPUT1_LAYER_PATH" \
	copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	custom-operator --name="cleanup2" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="blur"'\' \
	crop-margin save --name="save2" --volume-path="$OUTPUT2_LAYER_PATH" \
	\
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  

#  --patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \--framework='pytorch' --batch-size 32/42 \
	#--patch-size 1 3584 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
	#--framework='pytorch' --batch-size 2 \

	#custom-operator --name="z-interpolate-blanks" --opprogram=CF_OPPROGRAM \
	#	--args=\''TODO z_interpolate_blanks(chunk, method="interp"'\' \
#disabled

