# fura-btrfs-check

BTRFS filesystem management and monitoring tool.

## Install & Usage

```bash
git clone https://github.com/Ayanashi/fura-utils.git
cd fura-utils
chmod +x bin/btrfs/fura-btrfs-check.sh
sudo apt install btrfs-progs util-linux coreutils

./bin/btrfs/fura-btrfs-check.sh
./bin/btrfs/fura-btrfs-check.sh /mnt/btrfs
./bin/btrfs/fura-btrfs-check.sh scrub /mnt/btrfs
./bin/btrfs/fura-btrfs-check.sh scrub --priority /mnt/btrfs
./bin/btrfs/fura-btrfs-check.sh monitor /mnt/btrfs
./bin/btrfs/fura-btrfs-check.sh benchmark /mnt/btrfs
sudo ./bin/btrfs/fura-btrfs-check.sh optimize
./bin/btrfs/fura-btrfs-check.sh check-requirements
./bin/btrfs/fura-btrfs-check.sh help
