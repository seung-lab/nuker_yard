
from UNet import UNet, NormNet, NormUNet

USECUDA = True
use_bn = True
multi_label = False
n_classes = 1

net = UNet(n_classes = n_classes, cytoplasm = False, bn = use_bn, normlayer = False)
#if USECUDA:
#    net.cuda()

if 0:
	net.eval()
InstantiatedModel = net

def pre_process(input_numpy_patch):
	# This is a 2D net.
	# chunkflow+pytorch assumes 3D network with batch/channel/z/y/x blocks
	assert input_numpy_patch.ndim == 5 and input_numpy_patch.shape[1] == input_numpy_patch.shape[2] == 1
	input_numpy_patch = input_numpy_patch[:,:,0,...]

	return input_numpy_patch


def post_process(net_output):
	# the network output did not have sigmoid applied
	output_patch = net_output.sigmoid()

	#import pdb; pdb.set_trace()
	# make 2D network output look like 3D network output
	assert len(output_patch.shape) == 4
	output_patch = output_patch[:, :, None, ...]

	return output_patch
