import slice_corrections as sc #z_interpolate_blanks
from z_interpolate_blanks import clean_up_slice_errors, z-interpolate-blanks


#call = 'clean_up_slice_errors'

def op_call(chunk, args):
    # import argparse
    # import inspect
    #import ConfigParser
    #spec = inspect.getfullargspec()
    #sig = inspect.signature()

    # parser = argparse.ArgumentParser()

    # parser.add_argument('exc', help='excutable.')
    # parser.add_argument('gpu', type=int, help='gpu device id.')
    # parser.add_argument('cfg', help='meta config.')

    # args = parser.parse_args()

    # I'll forego properly implementing this in a badly designed framework... or even precompiling this
    #return eval(call + '(chunk,' + args + ')')
    return eval(args)


def z_interpolate_blanks(self, refchunk_w_blanks, chunk, planar_dilation=0, debug=False):
    assert chunk.ndim == 3
    assert np.array_equal(refchunk_w_blanks.shape, chunk.shape)

    #print(chunk.global_offset)

    out = sc.z_interpolate_blanks(refchunk_w_blanks, chunk, planar_dilation=planar_dilation)
    
    return Chunk(out, global_offset=chunk.global_offset)
