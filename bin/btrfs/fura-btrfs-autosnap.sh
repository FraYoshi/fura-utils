#!/bin/bash -
. ~/.config/furayoshi/autosnap/autosnap.sh

btrfs subvolume snapshot -r / /snaps/ROOT-$(date +"%Y%m%d-%H%M") && \
    echo "/snaps/ROOT-$(date +\"%Y%m%d-%H%M\")" >> ~/.cache/furayoshi/snaplog
btrfs subvolume snapshot -r /home /snaps/home-$(date +"%Y%m%d-%H%M") && \
    echo "/snaps/home-$(date +\"%Y%m%d-%H%M\")" >> ~/.cache/furayoshi/snaplog
btrfs subvolume snapshot -r /home/frayoshi /snaps/frayoshi-$(date +"%Y%m%d-%H%M") && \
    echo "/snaps/frayoshi-$(date +\"%Y%m%d-%H%M\")" >> ~/.cache/furayoshi/snaplog
btrfs subvolume snapshot -r /home/archive /mnt/snaps/archive/archive-$(date +"%Y%m%d-%H%M") &&
    echo "/mnt/snaps/archive/archive-$(date +\"%Y%m%d-%H%M\")" >> ~/.cache/furayoshi/snaplog
btrfs subvolume snapshot -r /home/archive/WORKING-desk /mnt/snaps/archive/WORKING-desk-$(date +"%Y%m%d-%H%M") &&
    echo "/mnt/snaps/archive/WORKING-desk-$(date +\"%Y%m%d-%H%M\")" >> ~/.cache/furayoshi/snaplog
btrfs subvolume snapshot -r /home/archive/export /mnt/snaps/archive/export-$(date +"%Y%m%d-%H%M") &&
    echo "/mnt/snaps/archive/WORKING-desk-$(date +\"%Y%m%d-%H%M\")" >> ~/.cache/furayoshi/snaplog


# ARCHIVE
#for subvol in ~/.config/furayoshi/autosnap/autosnap-root-list; do
#    btrfs subvolume snapshot -r $subvol $root
