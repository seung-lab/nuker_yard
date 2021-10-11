#!/bin/sh 
#!/bin/bash 
# // Use bash for "time"

#source $HOME/.bashrc


export CONVNET_MODEL_NAME="net.py" #UNet.py"
export CONVNET_WEIGHT_NAME="flyem/model600000.chkpt"  #v0 (likely not the same fly3_label_v3_2 600k used by later ones)
export CONVNET_WEIGHT_NAME="flyem/model1500000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model3300000.chkpt"  #v2
export CONVNET_WEIGHT_NAME="flyem/model3800000.chkpt"
#export CONVNET_WEIGHT_NAME="flyem/model3000000.chkpt"
#export CONVNET_WEIGHT_NAME="flyem/model4100000.chkpt"
#export CONVNET_WEIGHT_NAME="flyem/model3781000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model7636000.chkpt"
#export CONVNET_WEIGHT_NAME="flyem/model5800000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model8940000.chkpt"  # singleton batch
#export CONVNET_WEIGHT_NAME="flyem/model9112000.chkpt"
#export CONVNET_WEIGHT_NAME="flyem/model9218000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model10560000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model12290000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model12510000.chkpt"
export CONVNET_WEIGHT_NAME="flyem/model12610000.chkpt"
#export CONVNET_WEIGHT_NAME="flyem/model12710000.chkpt"

#export CONVNET_WEIGHT_NAME="flyem/2model250000.chkpt"



#export BASE_PATH="gs://neuroglancer/drosophila_v0/image_v14_single_slices"
export BASE_PATH="gs://microns-seunglab/drosophila_v0"

export IMAGE_LAYER_PATH="$BASE_PATH/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02"  # in single slice chunks

export NETOUTPUT_PATH="$BASE_PATH/nucleus/v1" #  flyem/model3000000.chkpt
export NETOUTPUT_PATH="$BASE_PATH/nucleus/v2" #  flyem/model3300000.chkpt
export NETOUTPUT_PATH="$BASE_PATH/nucleus/v3" #7100kr6 8740kr7 8440kr7 8740kr7_2 9112 (last3 9440large)
#export NETOUTPUT_PATH="$BASE_PATH/nucleus/testing" # z0, + 7400kr6 # 9218k-512 9340k-512 9340k 9440k-512
# export NETOUTPUT_PATH="$BASE_PATH/nucleus/testing2"  #eval
# export NETOUTPUT_PATH="$BASE_PATH/nucleus/testing3"  #batchnorm (i.e., no eval)
# export NETOUTPUT_PATH="$BASE_PATH/nucleus/testingx" #  512 512 patch size on one volume, generally more overpredictions
export NETOUTPUT_PATH="$BASE_PATH/nucleus/testingy" #  ~flyem/model3300000.chkpt~ flyem/model4100000.chkpt model3781000 model3800000r6 5800kr6 6700kr6 7636kr6 8100kr7 9240k-512 9440 9540-512 9740-512(large in last 3-4 vol) 9840large 10040large 10240large.discarded 10140large 10440
#export NETOUTPUT_PATH="$BASE_PATH/nucleus/testingz" #  flyem/model3000000.chkpt   1 3584 2048
#export NETOUTPUT_PATH="$BASE_PATH/nucleus/testingk"  # 8440kr7 512 512 patch size. usually but not entirely better # 8940kr7 9112-512 9218-large 8940-512 9540forNucVol
export NETOUTPUT_PATH="gs://neuroglancer/drosophila_v0/nucleus/testa" #model10240000new, 10900 10940 11190 11790
#export NETOUTPUT_PATH="gs://neuroglancer/drosophila_v0/nucleus/testb" #model10340000 10540 10550 10560 10990
#export NETOUTPUT_PATH="gs://neuroglancer/drosophila_v0/nucleus/testc" #10810 11390 11590 12290 12510(retro)
export NUC_BASE_PATH="gs://neuroglancer/drosophila_v0/nucleus"
export NETOUTPUT_PATH="$NUC_BASE_PATH/v4"



# Ah I do need blank filling, or perhaps can I combine it into something? eg.z5507
export OUTPUT1_LAYER_PATH="$BASE_PATH/nucleus/v2__intp"
export OUTPUT2_LAYER_PATH="$BASE_PATH/nucleus/v2__blur"
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

#seq 3 | parallel -j 11 --delay 120 --ungroup echo Starting worker {}\; time taskset -c {} chunkflow --verbose --mip 4 \


#: <<'disabled'
#seq 3 | parallel -j 11 --delay 400 --ungroup echo Starting worker {} on '$((2*{}))'-'$((2*{}+1))'\; taskset -c '$((2*{}))'-'$((2*{}+1))' \
#	custom-operator --name="normalize-section" --opprogram=CF_OPPROGRAM \
#		--args=\''TODO normalize(chunk, method="interp"'\' \


# Note normalize-section-shang was hacked to make chunk normalization.

	#generate-task --offset 17920 12096 12096 --shape 64 256 256 \
	#--patch-size 1 1856 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
	#--patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \
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
	\
	--upload-log --nproc 0 cloud-watch delete-task-in-queue;  
	# \
	# copy-var --name="restorecopy" --from-name='netoutput' --to-name='chunk' \
	# custom-operator --name="cleanup1" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="interp"'\' \
	# crop-margin save --name="save1" --volume-path="$OUTPUT1_LAYER_PATH" \
	# copy-var --name="restorecopy" --from-name='netoutput' --to-name='chunk' \
	# custom-operator --name="cleanup2" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="blur"'\' \
	# crop-margin save --name="save2" --volume-path="$OUTPUT2_LAYER_PATH" \

	# --patch-size 1 3584 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
	# --framework='pytorch' --batch-size 1 \
	# 4935MiB GPU on station01, 5117MiB (or 781..) on gcloud T4

	# --patch-size 1 1856 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
	# --framework='pytorch' --batch-size 1 \
	# 3019MiB GPU (or 769MiB for empty) on gcloud T4

#  --patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \--framework='pytorch' --batch-size 32/42 \
	#--patch-size 1 3584 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
	#--framework='pytorch' --batch-size 2 \

	#custom-operator --name="z-interpolate-blanks" --opprogram=CF_OPPROGRAM \
	#	--args=\''TODO z_interpolate_blanks(chunk, method="interp"'\' \
#disabled

