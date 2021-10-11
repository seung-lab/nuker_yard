#!/usr/bin/env python
import sys
from taskqueue import TaskQueue
import igneous.task_creation as tc
from cloudvolume.lib import Vec

layer_path = 'gs://neuroglancer/basil_v0/basil_full/nucleus/3d_v1/seg'
layer_path = 's3://minnie65-phase3-nuclei/seg'
layer_path = 's3://minnie65-phase2-nuclei/seg'
layer_path = 'gs://neuroglancer/drosophila_v0/nucleus/v5_z_intp_intp/seg'


with TaskQueue(#queue_server='sqs',
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
