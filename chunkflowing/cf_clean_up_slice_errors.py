from chunkflow.flow.z_interpolate_blanks import clean_up_slice_errors


call = 'clean_up_slice_errors'

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

    was4d = False;
    if chunk.ndim == 4 and chunk.shape[0] == 1 and chunk.global_offset[0] == 0:  # this directly came from inference
        # NOT HANDLING MULTI-CHANNEL STUFF YET
        # Note chunkflow isn't "properly" implementing global_offset or slicing for global_offset
        chunk = chunk[0,...];
        chunk.global_offset = chunk.global_offset[1:];
        was4d = True;
    assert chunk.ndim == 3

    # I'll forego properly implementing this in a badly designed framework... or even precompiling this
    ca = call + '(chunk,' + args + ')'
    print(ca)
    out = eval(ca)
    if was4d:
        out = out[None, ...]
    return out
