#!/bin/sh -
mkdir -p ~/bin/fura-utils
find "$(pwd -P)"/bin -type f -name "*.sh" -exec chmod +x "{}" \; -exec ln -s "{}" ~/bin/fura-utils/ \;
cp -r .config/furayoshi ~/.config/
echo "executables are installed in ~/bin/fura-utils/"
echo "configuration files are installed in ~/.config/furayoshi/"
echo "remember to add ~/bin/fura-utils to your PATH"
