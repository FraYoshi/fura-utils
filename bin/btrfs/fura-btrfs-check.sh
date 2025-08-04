#!/bin/bash -

show_btrfs_info() {
  local mount_point="$1"
  echo "=== BTRFS Filesystem: $mount_point ==="
  btrfs filesystem show "$mount_point"
  echo $(yes ─ | head -n10)
  btrfs device stats "$mount_point"
  echo $(yes ─ | head -n10)
  btrfs filesystem df "$mount_point"
  echo $(yes ─ | head -n10)
  btrfs device usage "$mount_point"
  echo $(yes ─ | head -n10)
  btrfs filesystem usage "$mount_point"
  echo $(yes ─ | head -n10)
  btrfs scrub status "$mount_point"
  echo
}

# If an argument is provided, use that
if [ $# -eq 1 ]; then
  show_btrfs_info "$1"
else
  # Otherwise show info for all mounted BTRFS filesystems
  mount | grep btrfs | while read -r line; do
    mount_point=$(echo "$line" | awk '{print $3}')
    show_btrfs_info "$mount_point"
  done

  # If no BTRFS filesystems are found
  if ! mount | grep -q btrfs; then
    echo "Error: No mounted BTRFS filesystem found"
    echo "Usage: $0 [mount_point]"
    exit 1
  fi
fi
