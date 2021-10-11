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

export OUTPUT1_LAYER_PATH="$BASE_PATH/nucleus/v0_z_intp_intp"
export OUTPUT2_LAYER_PATH="$BASE_PATH/nucleus/v0_z_intp_blur"
export VISIBILITY_TIMEOUT="1" # "3600" # "60"
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
seq 1 | parallel -j 1 --delay 150 --ungroup echo Starting worker {}\; \
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
       --patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \
	--framework='pytorch' --batch-size 42 \
	--original-num-output-channels 1 --num-output-channels 1 \
	\
	;
	# copy-var --name="makecopy-netoutput" --from-name='chunk' --to-name='netoutput' \
	# crop-margin  \
	# \
	# \
	# copy-var --name="restorecopy-netoutput" --from-name='netoutput' --to-name='chunk' \
	# z-interpolate-blanks --refvol cutout-em --planar-dilation 3 \
	# \
	# copy-var --name="makecopy" --from-name='chunk' --to-name='chunkcopy' \
	# crop-margin  \
	# \
	# copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	# custom-operator --name="cleanup1" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="interp"'\' \
	# crop-margin  \
	# copy-var --name="restorecopy" --from-name='chunkcopy' --to-name='chunk' \
	# custom-operator --name="cleanup2" --opprogram="$WORKDIR/cf_clean_up_slice_errors.py" --args=\''method="blur"'\' \
	# crop-margin  \
	# \
	# cloud-watch delete-task-in-queue;  

#  --patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \--framework='pytorch' --batch-size 32/42 \
	#--patch-size 1 3584 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
	#--framework='pytorch' --batch-size 2 \

	#custom-operator --name="z-interpolate-blanks" --opprogram=CF_OPPROGRAM \
	#	--args=\''TODO z_interpolate_blanks(chunk, method="interp"'\' \
#disabled

#       --patch-size 1 3584 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
#	--framework='pytorch' --batch-size 42 \
#CUDA out of memory. Tried to allocate 18.38 GiB (GPU 0; 11.17 GiB total capacity; 1.18 GiB already allocated; 9.67 GiB free; 3.03 MiB cached)

#        --patch-size 1 3584 2048 --patch-overlap 0 128 128 --output-key='nucleus' \
# 	--framework='pytorch' --batch-size 1 \

# 	4639MiB

# 	og submitted to cloud watch:  {'timer': {'cutout-em': 65.28483176231384, 'normalize-section-mu': 2.9362242221832275, 'inference': 72.54439353942871, 'crop-margin': 7.772445678710938e-05, 'z-interpolate-blanks': 20.879236221313477, 'cleanup1': 44.526843309402466, 'cleanup2': 34.12650418281555}, 'output_bbox': '4385-4417_7168-10496_12032-13824', 'compute_device': 'Tesla K80'}
# deleted task AQEBx+CU2CEhQw/3fvAbsN9WJyIz5ZBoxYC9eddqWad5NUPmXYTaUhwWTehETxmm1qbMhRUzdAEeXv89BDWFt0orxsRttGtfOtrC9/MiH7cycihuqke0XQ01pK0zqFbQeh59TJ52ra4qLouDxiwK8Piy2bS8Yr8OGW5SXoHnEA8sCB7WYgTe2HYn2CdvlLbekNtIS0cBpnY4xECAeqU3BeqzCfhl/OUAB8fqFBUQFoKKo3DEotDcyK/uWvMmjMX5kDEPYhxA//roy8C1cx7bqujzZp/zjF4l1ZA9/5npccdD53AAKIsPjKnQMurVcs0wNxinlQo0cAhBI63EmRj3BGdgpT716tyQY3c3+MSzjg1qQ3qwqAPeMNxZ7bL+ZcD/YKLOTPQOoC+BEAptRrCXEQg7CA== in queue: <chunkflow.lib.aws.sqs_queue.SQSQueue object at 0x7fc004ee1518>


# 	--framework='pytorch' --batch-size 2 \
## 	8925MiB



 #       --patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \
	# --framework='pytorch' --batch-size 42 \

	# 6768MiB
    
 #       --patch-size 1 512 512 --patch-overlap 0 128 128 --output-key='nucleus' \
	# --framework='pytorch' --batch-size 10 \
	# --original-num-output-channels 1 --num-output-channels 1 \
	# \
	# 1059/1035 local1001
	#
	# --batch-size 21 \
	# 1491 local1001
	# --batch-size 42 \
	# 2259/2307 local1001  (3-4 python procs?)