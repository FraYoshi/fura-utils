#!/bin/bash
source "$HOME"/.config/furayoshi/config.sh

# Configuration
OBS_CONFIG_FILE="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/user.ini"
OBS_PROFILES_DIR="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/basic/profiles"
OBS_SCENES_DIR="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/basic/scenes"

# Check if directories and config file exist
if [[ ! -d "$OBS_PROFILES_DIR" ]]; then
    echo -e "${RED}Error: Profiles directory not found at $OBS_PROFILES_DIR${NC}"
    exit 1
fi

if [[ ! -d "$OBS_SCENES_DIR" ]]; then
    echo -e "${RED}Error: Scenes directory not found at $OBS_SCENES_DIR${NC}"
    exit 1
fi

if [[ ! -f "$OBS_CONFIG_FILE" ]]; then
    echo -e "${RED}Error: Config file not found at $OBS_CONFIG_FILE${NC}"
    exit 1
fi

# Get current selections from config file
current_profile=$(grep "^Profile=" "$OBS_CONFIG_FILE" | cut -d'=' -f2)
current_scene=$(grep "^SceneCollection=" "$OBS_CONFIG_FILE" | cut -d'=' -f2)

# Get list of profiles
mapfile -t profiles < <(ls -d "$OBS_PROFILES_DIR"/*/ 2>/dev/null | xargs -n1 basename | sort)

if [[ ${#profiles[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No profiles found in $OBS_PROFILES_DIR${NC}"
    exit 1
fi

# Get list of scenes
mapfile -t scenes < <(ls "$OBS_SCENES_DIR"/*.json 2>/dev/null | xargs -n1 basename -s .json | sort -u)

if [[ ${#scenes[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No scene collections found in $OBS_SCENES_DIR${NC}"
    exit 1
fi

# Display profiles menu
echo "=== OBS Profile Selection ==="
echo -e "Current profile: ${YELLOW}[$current_profile]${NC}"
echo ""
echo "Available profiles:"
for i in "${!profiles[@]}"; do
    if [[ "${profiles[$i]}" == "$current_profile" ]]; then
        echo -e "  $((i+1)). ${YELLOW}${profiles[$i]} ◄${NC}"
    else
        echo "  $((i+1)). ${profiles[$i]}"
    fi
done

# Prompt for profile selection
read -p "Select profile number (or press Enter to skip): " profile_selection

# Validate and update profile if provided
if [[ -n "$profile_selection" ]]; then
    if ! [[ "$profile_selection" =~ ^[0-9]+$ ]] || ((profile_selection < 1 || profile_selection > ${#profiles[@]})); then
        echo -e "${RED}Invalid profile selection${NC}"
        exit 1
    fi
    selected_profile="${profiles[$((profile_selection-1))]}"
else
    selected_profile=""
fi

# Display scenes menu
echo ""
echo "=== OBS Scene Collection Selection ==="
echo -e "Current scene collection: ${YELLOW}[$current_scene]${NC}"
echo ""
echo "Available scene collections:"
for i in "${!scenes[@]}"; do
    if [[ "${scenes[$i]}" == "$current_scene" ]]; then
        echo -e "  $((i+1)). ${YELLOW}${scenes[$i]} ◄${NC}"
    else
        echo "  $((i+1)). ${scenes[$i]}"
    fi
done

# Prompt for scene selection
read -p "Select scene collection number (or press Enter to skip): " scene_selection

# Validate and update scene if provided
if [[ -n "$scene_selection" ]]; then
    if ! [[ "$scene_selection" =~ ^[0-9]+$ ]] || ((scene_selection < 1 || scene_selection > ${#scenes[@]})); then
        echo -e "${RED}Invalid scene collection selection${NC}"
        exit 1
    fi
    selected_scene="${scenes[$((scene_selection-1))]}"
else
    selected_scene=""
fi

# Update config file if selections were made
if [[ -z "$selected_profile" && -z "$selected_scene" ]]; then
    echo ""
    echo "No changes made."
    exit 0
fi

# Create backup if not already done in this session
if [[ ! -f "${OBS_CONFIG_FILE}.bak" ]] || [[ "${OBS_CONFIG_FILE}.bak" -ot "$OBS_CONFIG_FILE" ]]; then
    cp "$OBS_CONFIG_FILE" "${OBS_CONFIG_FILE}.bak"
fi

# Update profile if selected
if [[ -n "$selected_profile" ]]; then
    sed -i "/^Profile=/s/=.*/=$selected_profile/" "$OBS_CONFIG_FILE"
fi

# Update scene collection if selected
if [[ -n "$selected_scene" ]]; then
    sed -i "/^SceneCollection=/s/=.*/=$selected_scene/" "$OBS_CONFIG_FILE"
    sed -i "/^SceneCollectionFile=/s/=.*/.${selected_scene}.json/" "$OBS_CONFIG_FILE"
fi

# Display summary
echo ""
echo "=== Configuration Updated ==="
if [[ -n "$selected_profile" ]]; then
    echo -e "Profile: ${GREEN}$selected_profile${NC}"
fi
if [[ -n "$selected_scene" ]]; then
    echo -e "Scene Collection: ${GREEN}$selected_scene${NC}"
    echo -e "Scene Collection File: ${GREEN}${selected_scene}.json${NC}"
fi
echo "Backup saved to: ${OBS_CONFIG_FILE}.bak"
