#!/usr/bin/env python
import sys
from taskqueue import TaskQueue
import igneous.task_creation as tc
from cloudvolume.lib import Vec

layer_path = 'gs://neuroglancer/basil_v0/basil_full/nucleus/3d_v1/seg/mesh_mip_0_err_40'


with TaskQueue(queue_server='sqs',
               qurl='https://sqs.us-east-1.amazonaws.com/098703261575/shang-generic') as tq:
    if sys.argv[1] == 'consensus_downsample':
        tasks = tc.create_downsampling_tasks(layer_path, fill_missing=True)
    elif sys.argv[1] == 'meshing':
        tasks = tc.create_meshing_tasks(layer_path, mip=0, shape=Vec(448, 448, 448), fill_missing=True)
    elif sys.argv[1] == 'manifest':
        tasks = tc.create_mesh_manifest_tasks(layer_path)
    else:
        raise('need arg')
    tq.insert_all(tasks)
