#!/bin/bash -
btrfs filesystem show $1
echo $(yes ─ | head -n10)
btrfs device stats $1
echo $(yes ─ | head -n10)
btrfs filesystem df $1
echo $(yes ─ | head -n10)
btrfs device usage $1
echo $(yes ─ | head -n10)
btrfs filesystem usage $1
echo $(yes ─ | head -n10)
btrfs scrub status $1

# yes solution from https://stackoverflow.com/a/5799335/6021526
