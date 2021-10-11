import RSUNet3


whateversize = [0,0,0]
in_out_spec = dict(whatever=(1,*whateversize))  # only used to determine number of outputs and the number of channels each
width = [16, 32, 64, 128]

if 0:  # nope, errors out on loading states
	import torch
	torch.nn.BatchNorm3d = torch.nn.InstanceNorm3d
InstantiatedModel = RSUNet3.Model(in_out_spec, in_out_spec, width=width)
print('net.training = ', InstantiatedModel.training)
if 0:  # wait this is before loading the params, the mode is not part of the loaded state?
	InstantiatedModel.eval()
elif 0:  # ah momentum doesn't affect (current) normalization at all, and its value is the opposite of what a normal person would think
	import torch
	for m in InstantiatedModel.modules():
		if isinstance(m, torch.nn.BatchNorm3d):
			m.momentum = 0



# def pre_process(input_numpy_patch):
# 	# This is a 2D net.
# 	# chunkflow+pytorch assumes 3D network with batch/channel/z/y/x blocks
# 	assert input_numpy_patch.ndim == 5 and input_numpy_patch.shape[1] == input_numpy_patch.shape[2] == 1
# 	input_numpy_patch = input_numpy_patch[:,:,0,...]

# 	return input_numpy_patch

rootdir = '/import'

# def pre_process(input_numpy_patch):
# 	import tifffile
# 	print(input_numpy_patch.shape)
# 	for ii in range(input_numpy_patch.shape[0]):
# 		tifffile.imsave(rootdir + '/debugging_input_numpy_patch_{}.tif'.format(ii), input_numpy_patch[ii,0]);
# 		print('max min ', input_numpy_patch[ii,0].max(), input_numpy_patch[ii,0].min())

# 	return input_numpy_patch

def pre_process(input_numpy_patch):

	if 0:
		import torch
		print('len=', len([*InstantiatedModel.modules()]))
		testinput = torch.randn(1, 128, 2, 10, 10).cuda()
		for m in InstantiatedModel.modules():
			if isinstance(m, RSUNet3.OutputBlock) or isinstance(m, RSUNet3.BNReLUConv):
				bn = m.norm
				inorm = torch.nn.InstanceNorm3d(bn.num_features, affine=True)
				inorm.bias = bn.bias
				inorm.weight = bn.weight
				inorm.cuda()
				m.norm = inorm
				ti = testinput[:,0:bn.num_features,...]
				diff = bn(ti)-inorm(ti)
				print(diff.max(), diff.min())

		print('len=', len([*InstantiatedModel.modules()]))
		for m in InstantiatedModel.modules():
			if isinstance(m, torch.nn.BatchNorm3d):
				print('bn')
	elif 0:
		for m in InstantiatedModel.modules():
			if isinstance(m, RSUNet3.OutputBlock): #yes this alters result a little
			#if isinstance(m, RSUNet3.BNReLUConv): #yes this works
				m.eval()
	elif 0:
		InstantiatedModel.core.iconv.eval() #yes alters result a little


	return input_numpy_patch


def post_process(net_output):
	# the raw network output is a list of volumes and did not have sigmoid applied
	assert len(net_output)==1 or net_output.shape[0] == 1
	output_patch = net_output[0].sigmoid()  # perhaps I should let blending operate on the pre-sigmoid values..: tried on RSUNet, didn't help

	#import pdb; pdb.set_trace()
	# make 2D network output look like 3D network output
	# assert len(output_patch.shape) == 4
	# output_patch = output_patch[:, :, None, ...]

	if 0:
		import tifffile
		tifffile.imsave(rootdir + '/debugging_output_patch.tif', output_patch[0,0].cpu().detach().numpy());

	return output_patch