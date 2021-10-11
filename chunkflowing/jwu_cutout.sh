#!/bin/bash
export BASE_PATH="gs://microns-seunglab/minnie_v4/alignment/fine/sergiy_multimodel_v1/vector_fixer30_faster_v01/image_stitch_multi_block_v1"

export IMAGE_LAYER_PATH="gs://seunglab2/minnie_v1/alignment/fine/tmacrina_minnie10_serial/image"
export IMAGE_LAYER_PATH="$BASE_PATH"


chunkflow --verbose --mip 4 \
    generate-task --offset 17920 12096 12096 --shape 5 256 256 \
    cutout --volume-path="$IMAGE_LAYER_PATH" --expand-margin-size 5 128 128 \
    write-tif --file-name /tmp/shang_img.tif
