#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc


export CONVNET_MODEL_NAME="net.py" #UNet.py"

if [ -z ${CONVNET_WEIGHT_PATH+x} ];   # defined in kubedeploy.yml
	then export CONVNET_WEIGHT_NAME="flyem/model12610000.chkpt"  # running locally
	else export CONVNET_WEIGHT_NAME="model12610000.chkpt"  # running from kubedeploy.yml
fi


#export BASE_PATH="gs://neuroglancer/drosophila_v0/image_v14_single_slices"
export BASE_PATH="gs://microns-seunglab/drosophila_v0"
#"matrix://minnie65/aligned_image

export IMAGE_LAYER_PATH="$BASE_PATH/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02"  # in single slice chunks

export NUC_BASE_PATH_G="gs://neuroglancer/drosophila_v0/nucleus"
#export NUC_BASE_PATH="matrix://fafbv14-aff/nucleus"
export NUC_BASE_PATH="$NUC_BASE_PATH_G"
export NETOUTPUT_PATH="$NUC_BASE_PATH/v5"

export OUTPUT_PATH="$NUC_BASE_PATH/v5_z_intp"

export OUTPUT1_LAYER_PATH="$NUC_BASE_PATH/v5_z_intp_intp"
export OUTPUT1_LAYER_PATH2="$NUC_BASE_PATH_G/v5_z_intp_intp"
export OUTPUT2_LAYER_PATH="$NUC_BASE_PATH/v5_z_intp_blur"
export VISIBILITY_TIMEOUT="700" # "3600" # "60"
#export QUEUE_NAME="chunkflow-shang"
export QUEUE_NAME="shang-generic"  ###what's the queue retention time??? - verified

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
	--patch-size 1 1856 2048  --patch-overlap 0 128 128 --output-key='nucleus' \
	--framework='pytorch' --batch-size 1 \
	--original-num-output-channels 1 --num-output-channels 1 \
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

#	 save --name="save1.5" --volume-path="$OUTPUT1_LAYER_PATH2" \

	#custom-operator --name="z-interpolate-blanks" --opprogram=CF_OPPROGRAM \
	#	--args=\''TODO z_interpolate_blanks(chunk, method="interp"'\' \
#disabled

#2847MB GPU after inference {'timer': {'cutout-em': 24.219284296035767, 'normalize-section-mu': 18.16104245185852, 'inference': 34.53079128265381, 'crop-margin': 0.00020503997802734375, 'save-netoutput': 55.4175238609314, 'z-interpolate-blanks': 73.0675036907196, 'save0': 54.95623207092285, 'cleanup1': 117.38915610313416, 'save1': 54.59360909461975, 'cleanup2': 69.6131796836853, 'save2': 54.434311628341675}, 'output_bbox': '4977-5009_1792-5120_12544-14336', 'compute_device': 'TITAN X (Pascal)'}
