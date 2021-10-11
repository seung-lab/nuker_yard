from cloudvolume import CloudVolume, Bbox
import cloudvolume

import numpy as np


IMAGE_LAYER_PATH = "gs://microns-seunglab/drosophila_v0/alignment/vector_fixer30_faster_v01/v4/image_stitch_v02" 
#IMAGE_LAYER_PATH = precomputed://gs://seunglab_minnie_phase3/sergiy/final_fine_x4/image_stitch_dd200_mip1_final
IMAGE_LAYER_PATH = "https://s3-hpcrc.rc.princeton.edu/minnie65/aligned_image"
IMAGE_LAYER_PATH = "gs://microns-seunglab/minnie_v4/alignment/fine/sergiy_multimodel_v1/vector_fixer30_faster_v01/image_stitch_multi_block_v1/nucleus/3d_test3"
OUTPUT_LAYER_PATH="s3://minnie65-phase3-nuclei/net-output-test"
#shang-scratch/minnie_nuc_test
mip = 4
mip = (64,64,40)


#These are mip0 coords
pt_mip = 0
locations = [
#vol	vol start			description
 	('mine', [194630, 194441, 17945], 'zyx: 17920, 12096 12096'),
 	('minnie2020', [159410*2, 101845*2, 14992], ''),
 	#('p3 vessel/pia', [22549*16, 16*5984, 25026], ''),  #22620*16, 5845*16, 25024], ''),  #22699*16, 6397*16, 25024], ''),
	('p3 vessel/pia #1 part2', [22236*16, 16*6259, 25024], ''),
	('p3 vessel/pia #1 part1', [22236*16, 16*(6259-896), 25024], ''),

	('vol001A', [269065,227856,19908], 'myelin near dendrite with fold. axon unmyelinates'),
	('vol002A', [266928,228848,19908], 'even closer to blood vessel & with light track mark'),
	('vol003A', [268018,223442,19908], 'myelin near cell body'),
	('vol004A', [264976,223040,19908], 'invaginations, big and small, and myelin'),
	('vol001B', [269065,227856,19946], 'myelin near dendrite with fold. axon unmyelinates'),
	('vol002B', [266928,228848,19946], 'even closer to blood vessel & with light track mark'),
	('vol003B', [268018,223442,19946], 'myelin near cell body'),
	('vol004B', [264976,223040,19946], 'invaginations, big and small, and myelin'),
	('vol001', [269065,227856,19908], 'myelin near dendrite with fold. axon unmyelinates'),
	('vol002', [266928,228848,19908], 'even closer to blood vessel & with light track mark'),
	('vol003', [268018,223442,19908], 'myelin near cell body'),
	('vol004', [264976,223040,19908], 'invaginations, big and small, and myelin'),
	('vol005', [270194,220341,19908], 'weird invagination-like structure'),
	('vol006', [261502,228016,19908], 'cell body invagination'),
	('vol007', [267399,230254,19908], 'bunch of strange invaginations'),
	('vol008', [219564,316749,19908], 'white matter'),
	('vol009', [223068,304430,19908], 'white matter'),
	('vol010', [266396,226427,19908], 'gnarly cell body interface'),
	('vol011', [191150,142526,19908], 'strange invagination in L1'),
	('vol012', [192242,148654,19908], 'basket cell synapses in L1'),
	('vol013', [262355,222126,19908], 'myelin-myelin invagination'),
	('vol014', [199423,142412,19908], 'strange invagination in L1'),
	('vol015', [193057,140957,19908], 'blood vessel in L1'),
	('vol016', [265166,278408,20990], 'dendrite-dendrite merger caused by poor membrane'),
	('vol017', [266348,283055,20746], 'small folds around blood vessel cause mergers'),
	('vol018', [288222,258309,21070], 'broken axon caused by fold'),
	('vol019', [262983,293156,20952], 'white matter soma-soma merger'),
	('vol020', [289924,255775,21092], 'axon-axon merger caused by difficult membranes'),
	('vol021', [265849,185808,20794], 'axon-dendrite merger caused by difficult membranes'),
	('vol022', [259093,159369,20602], 'fold breaks a spine'),
	('vol023', [257965,157263,20882], 'super small invagination breaks off a bouton'),
	('vol024', [264578,268194,20712], 'one volume to rule them all - soma, nuclear envelope, myelin, folds, and blood vessel (meant for worst-case testing and validation)'),
	('vol025', [280057,270777,20789], 'oblique end of blood vessel'),
	('vol026', [273370,223150,20584], 'tricky parallel boundaries'),
	('vol027', [279913,138405,20814], 'crazy invagination in L1'),
	('vol028', [294552,213060,20917], 'soma-soma merger caused by invagination'),
	('vol029', [289368,231505,20749], 'messy axon initial segment'),
	('vol030', [186707,163382,17644], 'phase 3 semantic volume 0'),
	('vol031', [186594,160048,17636], 'phase 3 semantic volume 1'),
# 	'a',( ([near,blood,vessel], ''),
# #	'b',( ([proximal,,' ), #synapses'inhibitory]
	('vol025', [258837,159113,20584], 'fold breaks a spine'),
	('vol026', [257965,157263,20882], 'super small invagination breaks off a bouton'),
	('vol027', [289668,255263,21074], 'axon-axon merger caused by difficult membranes'),
	('c', [284180,207677,21077], 'black hole near fold causes dendrite-dendrite merger'),
	('d', [286817,194993,21024], 'black splotch near blood vessel & fold causes dendrite-dendrite merger'),
	('e', [286055,204061,20452], 'dendrite-blood vessel mergers'),
	('f', [258990,197453,20488], 'glia-dendrite merger caused by a fold'),
]


cv = CloudVolume(IMAGE_LAYER_PATH, mip=mip)

# also generate n random locations
#p3_roi = Bbox([26385, 30308, 14850], [218809, 161359, 27858]) mip1
p3_roi = Bbox((3298, 3788, 14850),(27351, 20169, 27858)) #mip4
#actual (chunk aligned?): 14837-27871 in z
my_roi = Bbox((6000, 5000, 14850),(22528, 17698, 27858)) #mip4
my_roi = cv.bbox_to_mip(my_roi, mip=4, to_mip=pt_mip)
print(p3_roi.minpt)
for ii in range(60,80): #range(20):
	coord = [np.random.randint(my_roi.minpt[jj], my_roi.maxpt[jj]) for jj in range(3)]
	locations += [('rand-{}'.format(ii), coord, '')]


def get_chunkaligned_coords(cv, pt, pt_mip = None, pt_cv = None):
	if pt_mip is not None:
		if pt_cv is None:
			pt_cv = cv
		pt = pt_cv.point_to_mip(pt, pt_mip, pt_cv.mip)
	bbox = Bbox(pt,pt);
	return bbox.expand_to_chunk_size(cv.chunk_size, cv.voxel_offset).minpt.astype('int')

def get_block_for_chunkflow(cv, pt, blocksz, pt_mip = None, pt_cv = None):
	pt = get_chunkaligned_coords(cv, pt, pt_mip=pt_mip, pt_cv=pt_cv)
	return (pt, pt + blocksz)

print('chunk size: ', cv.chunk_size)

blocksz = [896, 896, 128]
target_cv = cv
blocksz = [2048, 2048, 128]
target_cv = CloudVolume(OUTPUT_LAYER_PATH, mip=mip)
for key,pt,note in locations:
	pt = get_chunkaligned_coords(target_cv, cv.point_to_mip(pt, mip=pt_mip, to_mip=cv.mip)) # pt, pt_mip=pt_mip)
	print(pt[::-1], key, note)

# NG annotation im/export format
for key,pt,note in locations:
	block = get_block_for_chunkflow(target_cv, cv.point_to_mip(pt, mip=pt_mip, to_mip=cv.mip), blocksz)
	print('"{}","{}",,,{},,,AABB,'.format(tuple(block[0]), tuple(block[1]), key))

		#"(14333, 5237, 7018)","(15356, 6262, 7019)",,,w Nuc. yet,,,AABB,
