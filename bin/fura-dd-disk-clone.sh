#!/bin/sh -
source ~/.config/furayoshi/config.sh

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}Usage${NC}: $scriptName <input_file> <output_file> [block_size]"
    echo -e "${YELLOW}if using sudo${NC}: add sudo -E at the start"
    echo "Please specify the input and output files."
    exit 1
fi

# Assign the first two arguments to variables
ddif="$1"
ddof="$2"

# Check if the third argument is provided, otherwise use the default
if [ "$3" ]; then
  DDBS=$3
fi

dd_command="dd if=\"$ddif\" of=\"$ddof\" bs=$DDBS conv=noerror,sync,notrunc iflag=fullblock oflag=sync status=progress"

# Display the command to the user
echo -e "${GREEN}Command to be executed:${NC}"
echo -e "  ${dd_command}"

# Prompt for confirmation
read -p "Do you want to proceed? (yes/no) [NO]: " confirm

# Set default value if no input is provided
if [ -z "$confirm" ]; then
  confirm="NO"
fi

# Check the user's response
if [[ "$confirm" =~ ^[Yy][Ee][Ss]$ ]]; then
  echo -e "${GREEN}Executing command...${NC}"
  eval "$dd_command"
else
  echo -e "${RED}Execution aborted.${NC}"
  exit 1
fi
