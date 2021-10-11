#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import os
import sys

import torch
torch.backends.cudnn.benchmark=True

from ptflops import get_model_complexity_info

from pytorch_model.model import load_model as load_deepem_model


def load_model(chkpt_path: str):
    d = dict()

    # first make it a cpu model, the model will be loaded to GPU in chunkflow later if there is a GPU device.
    d['gpu_ids'] = []
    d['model'] = "rsunet_act"
    d['width'] = [16,32,64,128]
    d['in_spec'] = {'input': (1,20,256,256)}
    d['out_spec'] = {'affinity': (3,16,192,192), 'myelin': (1,16,192,192)}
    d['scan_spec'] = {'affinity': (3,16,192,192), 'myelin': (1,16,192,192)}
    d['cropsz'] = None
    d['pretrain'] = True
    d['precomputed'] = False
    d['edges'] = [(0,0,1),(0,1,0),(1,0,0)]
    d['overlap'] = (0,0,0)
    d['bump'] = None

    from types import SimpleNamespace
    opt = SimpleNamespace(**d)
    
    with torch.no_grad():
        model = load_deepem_model(opt, chkpt_path)
    
    model = model.half()

    if torch.cuda.is_available():
        model.cuda()

    # jit trace to accelerate
    input_patch = torch.rand((1, 1,20,256,256), dtype=torch.float16, 
                             device=torch.device('cuda'))
    print('input patch date type: ', input_patch.dtype)
    
    flops, params = get_model_complexity_info(model, (1, 20, 256, 256), as_strings=True, print_per_layer_stat=True)
    print('{:<30}  {:<8}'.format('Computational complexity: ', flops))
    print('{:<30}  {:<8}'.format('Number of parameters: ', params))

    #with torch.no_grad():
    #    with torch.jit.optimized_execution(should_optimize=True):
    #        model = torch.jit.trace(model, (input_patch))

    return model
