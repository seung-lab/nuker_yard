#!/bin/sh 

BLOCK_SIZE='64 2048 2048'

BLOCK_SIZE='128 896 896'
#BLOCK_SIZE='64 256 256'  # 176-32 patches
#BLOCK_SIZE='64 640 640'  # 160-32 patches
QUEUE=chunkflow-shang

PRODUCE="$HOME/workspace/chunkflow/chunkflow/flow/produce_tasks.py"
# 17920 12096 12096 --shape 128 2048 2048 \


CMDLINE="python3 $PRODUCE -g 1 1 1 -q $QUEUE -b $BLOCK_SIZE -s "

# $CMDLINE 17920 12096 12096  # mine zyx: 17920, 12096 12096
# $CMDLINE 14976 12608 19904  #minnie2020 
$CMDLINE 25024  5952 22464 #p3 vessel/pia   #25024  5824 22592  # p3 vessel/pia 
# $CMDLINE 25024  6208 22208 # p3 vessel/pia #1 part2 
# $CMDLINE 25024  5312 22208 # p3 vessel/pia #1 part1 

# # $CMDLINE 19904 14144 16704  # vol001A myelin near dendrite with fold. axon unmyelinates
# # $CMDLINE 19904 14272 16576  # vol002A even closer to blood vessel & with light track mark
# # $CMDLINE 19904 13888 16704  # vol003A myelin near cell body
# # $CMDLINE 19904 13888 16448  # vol004A invaginations, big and small, and myelin
# # $CMDLINE 19904 14144 16704  # vol001B myelin near dendrite with fold. axon unmyelinates
# # $CMDLINE 19904 14272 16576  # vol002B even closer to blood vessel & with light track mark
# # $CMDLINE 19904 13888 16704  # vol003B myelin near cell body
# # $CMDLINE 19904 13888 16448  # vol004B invaginations, big and small, and myelin
# # $CMDLINE 19904 14144 16704  # vol001 myelin near dendrite with fold. axon unmyelinates
# # $CMDLINE 19904 14272 16576  # vol002 even closer to blood vessel & with light track mark
# # $CMDLINE 19904 13888 16704  # vol003 myelin near cell body
# # $CMDLINE 19904 13888 16448  # vol004 invaginations, big and small, and myelin
# # $CMDLINE 19904 13760 16832  # vol005 weird invagination-like structure
# # $CMDLINE 19904 14144 16320  # vol006 cell body invagination
# # $CMDLINE 19904 14272 16704  # vol007 bunch of strange invaginations
# # $CMDLINE 19904 19776 13632  # vol008 white matter
# # $CMDLINE 19904 19008 13888  # vol009 white matter
# # $CMDLINE 19904 14144 16576  # vol010 gnarly cell body interface
# # $CMDLINE 19904  8896 11840  # vol011 strange invagination in L1
# # $CMDLINE 19904  9280 11968  # vol012 basket cell synapses in L1
# # $CMDLINE 19904 13760 16320  # vol013 myelin-myelin invagination
# # $CMDLINE 19904  8896 12352  # vol014 strange invagination in L1
# # $CMDLINE 19904  8768 11968  # vol015 blood vessel in L1
# # $CMDLINE 20928 17344 16448  # vol016 dendrite-dendrite merger caused by poor membrane
# # $CMDLINE 20736 17600 16576  # vol017 small folds around blood vessel cause mergers
# # $CMDLINE 21056 16064 17984  # vol018 broken axon caused by fold
# $CMDLINE 20928 18240 16320  # vol019 white matter soma-soma merger
# # $CMDLINE 21056 15936 18112  # vol020 axon-axon merger caused by difficult membranes
# # $CMDLINE 20736 11584 16576  # vol021 axon-dendrite merger caused by difficult membranes
# # $CMDLINE 20544  9920 16192  # vol022 fold breaks a spine
# # $CMDLINE 20864  9792 16064  # vol023 super small invagination breaks off a bouton
# $CMDLINE 20672 16704 16448  # vol024 one volume to rule them all - soma, nuclear envelope, myelin, folds, and blood vessel (meant for worst-case testing and validation)
# # $CMDLINE 20736 16832 17472  # vol025 oblique end of blood vessel
# # $CMDLINE 20544 13888 16960  # vol026 tricky parallel boundaries
# # $CMDLINE 20800  8640 17472  # vol027 crazy invagination in L1
# $CMDLINE 20864 13248 18368  # vol028 soma-soma merger caused by invagination
# # $CMDLINE 20736 14400 17984  # vol029 messy axon initial segment
# # $CMDLINE 17600 10176 11584  # vol030 phase 3 semantic volume 0
# # $CMDLINE 17600  9920 11584  # vol031 phase 3 semantic volume 1
# # $CMDLINE 20544  9920 16064  # vol025 fold breaks a spine
# # $CMDLINE 20864  9792 16064  # vol026 super small invagination breaks off a bouton
# # $CMDLINE 21056 15936 17984  # vol027 axon-axon merger caused by difficult membranes
# # $CMDLINE 21056 12864 17728  # c black hole near fold causes dendrite-dendrite merger
# # $CMDLINE 20992 12096 17856  # d black splotch near blood vessel & fold causes dendrite-dendrite merger
# # $CMDLINE 20416 12736 17856  # e dendrite-blood vessel mergers
# # $CMDLINE 20480 12224 16064  # f glia-dendrite merger caused by a fold

# $CMDLINE 19840  7488 19136 	# rand-0 
# $CMDLINE 21120 12992 15296 	# rand-1 
 $CMDLINE 19904 10944 22208 	# rand-2  5801 made error 5823 better
# $CMDLINE 21568  6464  7360 	# rand-3 
# # $CMDLINE 16832  5312  7488 	# rand-4 pia region
# $CMDLINE 20288 11584 19520 	# rand-5 
# $CMDLINE 15296  7616 11712 	# rand-6   perhaps try adjacent too 
# $CMDLINE 19136 12480 11712 	# rand-7 
# $CMDLINE 15360 13888  9280 	# rand-8 
# $CMDLINE 18176  7232  8128 	# rand-9 
 $CMDLINE 15360 15040 13248 	# rand-10  white matter faint nuc errors
 $CMDLINE 15296 16320 17728 	# rand-11  white matter
# $CMDLINE 25344  7232 11328 	# rand-12 
# $CMDLINE 14912 12352 10944 	# rand-13 
# $CMDLINE 26368 10176  7488 	# rand-14 
# $CMDLINE 24768  6208 17856 	# rand-15 
# # $CMDLINE 17920  5184  9920 	# rand-16 pia region
# $CMDLINE 21824 12480 12736 	# rand-17 
 $CMDLINE 20736 11072 15680 	# rand-18 5801 made error, 5823 worse...what was wrong...
# $CMDLINE 21568  6208 15168 	# rand-19 

 $CMDLINE 15168 17472  7360 # rand-0 white matter
# $CMDLINE 14912  7872 12736 # rand-1 
# $CMDLINE 20672  9792 20672 # rand-2 
 $CMDLINE 18240 10688 11840 # rand-3  5505 made error
# $CMDLINE 16768 13760  8128 # rand-4 
# $CMDLINE 19840  5568 21568 # rand-5 
# $CMDLINE 25856 17472 11200 # rand-6 white matter, mostly blank
# $CMDLINE 24768  8768 22464 # rand-7 
# $CMDLINE 16448  6848 16960 # rand-8 
# #  $CMDLINE 20480  5312  9536 # rand-9  # pia region
# $CMDLINE 21376  9024 11968 # rand-10 
# $CMDLINE 23744  5824  8000 # rand-11 
# $CMDLINE 15744 12224 19392 # rand-12 
 $CMDLINE 17536 10176 19264 # rand-13 # has the m2_5728 underpred
# $CMDLINE 16512  5568 12864 # rand-14 
# #$CMDLINE 27392 16448  7872 # rand-15 blank
# $CMDLINE 19840 12096 18752 # rand-16 
# $CMDLINE 18496 16960 11200 # rand-17 white matter and closeby merger
# $CMDLINE 25344  7744 10432 # rand-18 
# $CMDLINE 25728 13248 12480 # rand-19 

# $CMDLINE 20096 16960 14656 # rand-40 white matter
# $CMDLINE 15232 12608  8768 # rand-41 
$CMDLINE 25024  7488 22208 # rand-42 # large nuc-alike endothelial non-nuc. aslo folding nuc error
# $CMDLINE 17472  8768 17344 # rand-43 
# $CMDLINE 20736  6336 20672 # rand-44 
# $CMDLINE 20416  9792  7616 # rand-45 
# $CMDLINE 21056 15552  8128 # rand-46 
$CMDLINE 17920  7104 19392 # rand-47  # nets had trouble next to blood vessel w dark stains
# $CMDLINE 18944 12096 19904 # rand-48 
$CMDLINE 17088  7232 10048 # rand-49  # 5801 made error
$CMDLINE 19776 16832 21568 # rand-50  # nets had trouble with faint nucs in dark mylin
# $CMDLINE 19072 13120 15936 # rand-51 
# $CMDLINE 24320 10688 11584 # rand-52 
# $CMDLINE 20160  9024 19776 # rand-53 
# $CMDLINE 15552  8000 19008 # rand-54 
# $CMDLINE 23168  8000 12096 # rand-55 
# $CMDLINE 23040  9664  7488 # rand-56 
# $CMDLINE 17600 10560  8768 # rand-57 
# $CMDLINE 24640 10176 13760 # rand-58 
$CMDLINE 14848 16448  9664 # rand-59  mylin region faint nucs
