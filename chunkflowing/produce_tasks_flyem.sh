#!/bin/sh 


# nucleus detection
# flyEM test cube
#roughly at 120989, 64272, 4413 ,  101610, 67622, 4390
#Ouch, wrong order for block sizes, this turns out at 4385-4417_7168-8960_12032-15360.json rather the
# intended 4385-4417_6656-9984_12800-14592.json	or 4385-4417_6656-9984_11008-12800.json
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 4385 7168 12032 -b 32 1792 3328  -g 1 1 1 -q chunkflow-shang
#batch size 32 (increasing to 42 for fuller usage, should have increased patch size, also input had chunk size 1024...):
# 1797/1841 MiB GPU, 15.7GiB CPU @ cleanup2.  ...how did 182MiVol get to 16GiB??
#{'timer': {'cutout-em': 85.74626588821411, 'normalize-section-mu': 5.105987310409546, 'inference': 25.621536016464233, 'crop-margin': 0.000263214111328125, 'save-netoutput': 10.63872480392456, 'z-interpolate-blanks': 19.80544352531433, 'save0': 10.893895626068115, 'cleanup1': 48.5271852016449, 'save1': 11.018958806991577, 'cleanup2': 36.40321731567383, 'save2': 11.03130578994751}, 'output_bbox': '4385-4417_7168-8960_12032-15360', 'compute_device': 'TITAN X (Pascal)'}
#batch size 42: 2259 MiB GPU

#batch size 7xfull xy: 9373 MiB GPU


python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 4385 7168 12032 -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang
#345->
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 33 7168 17408 -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang
#-b 32 3328 1792, batchsize=1: 4945Mi GPU mem, 9Gi CPU mem, 5117Mi GPU on gcloud t4
#station1001: 2847MB GPU after inference {'timer': {'cutout-em': 24.219284296035767, 'normalize-section-mu': 18.16104245185852, 'inference': 34.53079128265381, 'crop-margin': 0.00020503997802734375, 'save-netoutput': 55.4175238609314, 'z-interpolate-blanks': 73.0675036907196, 'save0': 54.95623207092285, 'cleanup1': 117.38915610313416, 'save1': 54.59360909461975, 'cleanup2': 69.6131796836853, 'save2': 54.434311628341675}, 'output_bbox': '4977-5009_1792-5120_12544-14336', 'compute_device': 'TITAN X (Pascal)'}

# prob regions
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 2145 6656 16384
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4385 6656 14592
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 2177 6656 14592
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4385 6656 9216
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4385 9984 2048
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4385 9984 3840
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4417 6656 19968
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4449 0 14592 #16384
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4449 0 12800
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 5505 6656 18176
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4417 9984 27136
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4417 9984 28928
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 6977 9984 14592

# python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 7009 6656 12800 #14532, 6161, 7030
# python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 7009 6656 14592
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 7009 4608 12800 #14532, 6161, 7030
python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 7009 4608 14592
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 6881 7168 14592 #15901, 10436, 6888

python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -b 32 3328 1792  -g 1 1 1 -q chunkflow-shang -s 4977 1792 12544
#uploaded log:  {'timer': {'cutout-em': 35.611693382263184, 'normalize-section-mu': 2.859483003616333, 'inference': 24.222826719284058, 'crop-margin': 0.0009005069732666016, 'save-netoutput': 9.91407585144043}, 'output_bbox': '4977-5009_1792-5120_12544-14336', 'compute_device': 'TITAN X (Pascal)'}


#
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 1 0 2048 -b 32 3328 1792  -g 221 6 18 -q chunkflow-shang
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 1 0 2048 -b 32 3328 1792  -g 221 6 18 -q shang-generic

118


#Ouch, wrong order for block sizes
#python3 $HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py -s 1 0 2048 -b 32 1792 3328  -g 221 6 18 -q chunkflow-shang
# expand-margin-size 5 128 128
# At most 8.6GiB/9.09GiB RES mem usage seen in a kube pod, or local, on empty chunks.... actually did get to >14Gi

# but 85G Virt? 40G SHR?
# CF randomly dies???
# what even interactive bash dies with "command terminated with exit code 137"??? and encountering 800% CPU by chunkflow?