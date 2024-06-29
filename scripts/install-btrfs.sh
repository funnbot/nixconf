#!/bin/bash

# TODO: https://github.com/nix-community/disko/ except it doesnt support dual booting/preserving a partition
# WARNING: untested

# enable strict bash mode
set -euo pipefail

dry_run=false

# if dry_run is true, set a variable to echo the command instead of running it
if $dry_run; then
    run="echo"
else
    run=""
fi

# run most commands as with sudo
# ensure that all of the code is correct and complete
# ensure that there are checks to prevent the user from doing something that would break their system

function print_disk_info() {
    # print the information for all disks that is human readable formats, with partition labels and type, and size and usage, and mount points, if its mounted and identifiers.
    $run sudo lsblk -o NAME,LABEL,FSTYPE,SIZE,USAGE,MOUNTPOINT,UUID
}

function print_part_info() {
    # print the partition information for the partition passed as argument $1 that is human readable formats, with partition labels and type, and size and usage, and mount points, if its mounted and identifiers.
    $run sudo lsblk -o NAME,LABEL,FSTYPE,SIZE,USAGE,MOUNTPOINT,UUID $1
}

# generate the btrfs filesystem
function create_btrfs() {
    # print the disk information
    print_disk_info

    # ask the user for the partition to use for the btrfs filesystem and save it in the variable $main_part
    read -p "Enter the partition to use for the btrfs filesystem (e.g., /dev/sda1): " main_part

    # assert that the partition $main_part is not mounted
    if mount | grep -q "$main_part"; then
        echo "$main_part is already mounted. Please unmount before proceeding."
        exit 1
    fi

    # assert that the partition $main_part has over 16GB of total size
    part_size=$(sudo fdisk -l $main_part | grep "Disk $main_part" | awk '{print $5}')
    if [ "$part_size" -lt 17179869184 ]; then
        echo "$main_part is smaller than 16GB. Please choose a larger partition."
        exit 1
    fi

    # assert that the disk is GUID partition table
    if ! sudo gdisk -l ${main_part%[0-9]*} | grep -q "GPT"; then
        echo "The disk containing $main_part does not use a GUID partition table (GPT). Please convert it to GPT."
        exit 1
    fi

    # print the partition information of $main_part
    print_part_info $main_part

    # ask the user if the partition is correct and that it will be erased, if not exit
    $run read -p "All data on $main_part will be erased. Are you sure? (y/N): " confirmation
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 1
    fi

    # change the partition type of $main_part to "Linux filesystem"
    echo -e "t\n20\nw" | $run sudo fdisk $main_part

    # use sudo mkfs.btrfs on $main_part to create a btrfs filesystem, using -f to force, and -L with the label "NixOS"
    $run sudo mkfs.btrfs -f -L NixOS $main_part

    # make the mount point at /mnt
    echo "Creating mount point at /mnt, this happens even if dry-run is enabled."
    sudo mkdir -p /mnt

    # assert that /mnt is empty
    if [ "$(ls -A /mnt)" ]; then
        echo "/mnt is not empty. Please ensure /mnt is empty before proceeding."
        exit 1
    fi

    # assert that nothing is mounted at /mnt
    if mount | grep -q "/mnt"; then
        echo "Something is already mounted at /mnt. Please unmount before proceeding."
        exit 1
    fi

    # mount $main_part at /mnt
    $run sudo mount $main_part /mnt

    # create the subvolumes root, home, and nix
    $run sudo btrfs subvolume create /mnt/root
    $run sudo btrfs subvolume create /mnt/home
    $run sudo btrfs subvolume create /mnt/nix

    # finally, unmount /mnt
    $run sudo umount /mnt
}

function mount_btrfs() {
    # check if the btrfs partition was passed as the argument $1
    if [ -z "${1-}" ]; then
        print_disk_info
        # if not, prompt for a btrfs partition
        read -p "Enter the btrfs partition (e.g., /dev/sda1): " main_part
    else
        main_part=$1
    fi

    # assert that it has the label "NixOS"
    if ! sudo blkid $main_part | grep -q 'LABEL="NixOS"'; then
        echo "$main_part does not have the label 'NixOS'. Please choose the correct partition."
        exit 1
    fi

    # print the partition information and ask the user if it is correct
    print_part_info $main_part
    read -r -p "Is this the correct partition? (y/N): " confirmation
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 1
    fi

    # assert that the partition $main_part is btrfs
    if ! sudo blkid $main_part | grep -q 'TYPE="btrfs"'; then
        echo "$main_part is not a btrfs filesystem. Please choose a btrfs partition."
        exit 1
    fi

    # assert that the partition $main_part is not mounted
    if mount | grep -q "$main_part"; then
        echo "$main_part is already mounted. Please unmount before proceeding."
        exit 1
    fi

    # assert that the partition $main_part is at least 16GB in size
    part_size=$(sudo fdisk -l $main_part | grep "Disk $main_part" | awk '{print $5}')
    if [ "$part_size" -lt 17179869184 ]; then
        echo "$main_part is smaller than 16GB. Please choose a larger partition."
        exit 1
    fi

    # mount the subvolumes to /mnt, /mnt/home, and /mnt/nix
    $run sudo mount -o subvol=root $main_part /mnt
    $run sudo mkdir -p /mnt/{home,nix}
    $run sudo mount -o subvol=home $main_part /mnt/home
    $run sudo mount -o noatime,subvol=nix $main_part /mnt/nix
}