# Furayoshi scripts

these are a series of scripts I created to aid in unusual or repetitive tasks.

Sharing so also others could benefit from.

# How to
### Auto
Open a terminal on the fura-utils directory and then run:

`chmod +x INSTALL.sh && ./INSTALL.sh`

### Manual
Scripts must be made executable `chmod +x <file.sh>`

I suggest inserting these scripts in a bin directory like `~/bin` and add it to your PATH. This can be accomplished adding symbolic links of all the scripts like so:

open a terminal on the fura-utils directory and use
```
find "$(pwd -P)"/bin -type f -name "*.sh" -exec chmod +x "{}" \; -exec ln -s "{}" </path/to/your/personal/bin/> \; && cp -r .config/furayoshi ~/.config/
```
replace `ln -s` with `cp` if you don't want symbolic links and remove `\;` at the end.

### Upgrades
unlink before every upgrade with
```
for script in <path/to/your/bin/*.sh>; do
	unlink $script;
done
```
or just delete the files.

# Uninstall
### Automatic
Open a terminal on the fura-utils directory and then run:

`chmod +x UNISTALL.sh && ./UNISTALL.sh`

### Manually
same as **Upgrades** but remove also from your PATH.

## Config file location

`~/.config/furayoshi/`

# Scripts explanation (wip)
## fura-video-hypercompress
It is a script to compress a #video to sub-mega sizes, which comes handy when used for previews or licensing where storage used is forever and expensive (like S3).

I personally use it to shasum and store into SafeCreative, where storage costs a lot, considering I'm gonna pay forever and more space = forever higher prices. (in case you are interested in SafeCreative, leave my 10% off: 9XZKH9)

# Support me
If you want to join others supporting my publications, head to the link below and choose your preferred way to support and thank you in advance!!

This will give me motivation and the chance to dedicate more time to the creation of scripts like these!

- https://furayoshi.com/support
