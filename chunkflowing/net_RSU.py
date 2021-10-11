import RSUNet


whateversize = [0,0,0]
in_out_spec = dict(whatever=(1,*whateversize))  # only used to determine number of channels
width = [16, 32, 64]

InstantiatedModel = RSUNet.Model(in_out_spec, in_out_spec, width=width)
if 0:
	InstantiatedModel.eval()


# def pre_process(input_numpy_patch):
# 	# This is a 2D net.
# 	# chunkflow+pytorch assumes 3D network with batch/channel/z/y/x blocks
# 	assert input_numpy_patch.ndim == 5 and input_numpy_patch.shape[1] == input_numpy_patch.shape[2] == 1
# 	input_numpy_patch = input_numpy_patch[:,:,0,...]

# 	return input_numpy_patch


def post_process(net_output):
	# the raw network output is a list of volumes and did not have sigmoid applied
	assert len(net_output)==1 or net_output.shape[0] == 1
	output_patch = net_output[0]
	output_patch = output_patch.sigmoid()  # perhaps I should let blending operate on the pre-sigmoid values..: tried, didn't help

	#import pdb; pdb.set_trace()
	# make 2D network output look like 3D network output
	# assert len(output_patch.shape) == 4
	# output_patch = output_patch[:, :, None, ...]

	return output_patch
