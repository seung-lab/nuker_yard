
from unet3d import model

InstantiatedModel = unet3d.model.UNet3D( in_channels, out_channels, final_sigmoid, f_maps=64, layer_order='crg', num_groups=8,
                 **kwargs)

InstantiatedModel.training = False  # apply final_activation
'''
From unet3d.model:
 if not self.training:
            x = self.final_activation(x)
'''

def pre_process(input_numpy_patch):
	input_numpy_patch *= 255   # chunkflow scales integer values to [0,1]
	return input_numpy_patch


# def post_process(net_output):
# 	# the network output did not have sigmoid applied
# 	output_patch = net_output.sigmoid()

# 	return output_patch


QUESTION TO ALLEN:
XYZ ORDER?

cv[23,3,43]