# Furayoshi scripts
these are a series of scripts I created to aid in unusual or repetitive tasks.
Sharing so also others could benefit from.

# How to
**Auto**:
use INSTALL.sh or do it manually.
INSTALL.sh must be made executable.
in 1 command with a terminal opened in the fura-utils directory:
`chmod +x INSTALL.sh && ./INSTALL.sh`

**Manual**:
Scripts must be made executable `chmod +x <file.sh>`
I suggest inserting these scripts in a bin directory like `~/bin` and add it to your bin PATH. This can be accomplished adding symbolic links of all the scripts like so:
open a terminal on the fura-utils directory and use
`find "$(pwd -P)"/bin -type f -name "*.sh" -exec chmod +x "{}" \; -exec ln -s "{}" </path/to/your/personal/bin/> \; && cp -r .config/furayoshi ~/.config/`
replace `ln -s` with `cp` if you don't want symbolic links and remove `\;` at the end.
This has also made the scripts executable.

**Upgrades**
unlink before every upgrade with
```
for script in <path/to/your/bin/*.sh>; do
	unlink $script;
done
```
or just delete the files.

# Unistall
**Automatic**
use UNINSTALL.sh or do it manually.
UNINSTALL.sh must be made executable. `chmod +x UNINSTALL.sh`
in 1 command with a terminal opened in the fura-utils directory:
`chmod +x UNISTALL.sh && ./UNISTALL.sh`

**Manually**
same as Upgrades but remove also from your PATH.

## Config file location
`~/.config/furayoshi/`

# Support me

If you want to join others supporting my publications, head to the link above and choose your preferred way to support, thank you in advance!
This will give me motivation and the chance to dedicate more time to the creation of scripts like these!

- https://furayoshi.com/support
