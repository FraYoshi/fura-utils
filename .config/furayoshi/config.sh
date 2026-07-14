#!/bin/bash -
set -a

# colorizations
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# basename the $0
scriptName=$(basename "$0")

PIC_HYPERCOMPRESS=4%
PIC_HYPERCOMPRESS_FORMAT=webp
PIC_HYPERCOMPRESS_SUFFIX=-lic

PIC_PREVIEWCOMPRESS=20%
PIC_PREVIEWCOMPRESS_FORMAT=webp
PIC_PREVIEWCOMPRESS_SUFFIX=-preview

# V4L2 LOOPBACK
CARDLABEL=v4l2-loop
V4L2WIDTH=1920
V4L2HEIGHT=1080
V4L2NUMBER=5
V4L2PIXELFORMAT=YUYV

# DD
DDBS=1G

# Blender
BLENDER_BETA_DOWNLOAD_DIR="/tmp/blender5a-download"
BLENDER_BETA_INSTALL_DIR="/opt/blender/blender5a"
BLENDER_BETA_BIN_LOCATION="/usr/local/bin"
BLENDER_BETA_BIN_NAME="blender5a"

BLENDER_BETA_DOWNLOAD_DIR="/tmp/blender5-download"
BLENDER_BETA_INSTALL_DIR="/opt/blender/blender5"
BLENDER_BETA_BIN_LOCATION="/usr/local/bin"
BLENDER_BETA_BIN_NAME="blender5"

BLENDER_RC_DOWNLOAD_DIR="/tmp/blender5-download"
BLENDER_RC_INSTALL_DIR="/opt/blender/blender5"
BLENDER_RC_BIN_LOCATION="/usr/local/bin"
BLENDER_RC_BIN_NAME="blender5"

# OBS
OBS_CONFIG_FILE="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/user.ini"
OBS_PROFILES_DIR="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/basic/profiles"
OBS_SCENES_DIR="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/basic/scenes"

# OBSIDIAN FIND ORPHANED
#OBSIDIAN_ORPH_VAULT="/path/to/your/vault"
## comma separated values
OBSIDIAN_ORPH_EXCLUDE_DIRS=".trash,.obsidian,.git"
OBSIDIAN_ORPH_EXCLUDE_EXT=".md,.base,.gitignore,.gitattributes"
OBSIDIAN_ORPH_EXCLUDE_FILES=".gitignore,.gitattributes,.gitmodules"
## if set, only these extensions and directories will be part of the search.
#OBSIDIAN_ORPH_ONLY_DIRS="media"
#OBSIDIAN_ORPH_ONLY_EXT=".png,.jpg,.jpeg,.jxl,.webp,.gif,.svg,.pdf,.mp4,.webm,.mov,.mp3,.wav,.flac,.ogg,.opus"

set +a
