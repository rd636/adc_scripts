#
#   This program checks for sufficient file sytem space and 
#   runs a cleanup of /var and /flash when needed.
#   Run this for periodic monitoring and cleanup of storage space. 
#
#   This is a combination of chk_dsk_space and dsk_clean scripts.
#
#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
#   EXAMPLE #1 var:
#        root@ADC-131# /var/storage_cleanup.sh
#        Error: Not enough free disk space in /var.
#        Need: 5GB
#        Avail: 2GB
#        Removing files.
#        sufficient free disk space exists.
#        /var: 9GB
#        /flash: 1283MB
#
#   EXAMPLE #2 flash:
#       root@ADC-131# /var/storage_cleanup.sh
#       Error: Not enough free disk space in /flash.
#       Need: 250MB
#       Avail: 182MB
#       Removing files.
#       /flash/delme.gz /flash/delme2.gz /flash/ns-13.1-42.47.gz
#       Deleted: /flash/delme.gz
#       Deleted: /flash/delme2.gz
#       sufficient free disk space exists.
#       /var: 9GB
#       /flash: 1283MB
#
#   EXAMPLE #3 flash:
#       root@ADC-131# /var/storage_cleanup.sh
#       Error: Not enough free disk space in /flash.
#       Need: 250MB
#       Avail: 182MB
#       Removing files.
#       /flash/ns-13.1-42.47.gz
#       no alternate kernel files found to delete. /flash/ns-13.1-42.47.gz
#

# Minimum free space
min_free_space_var_gb=5
min_free_space_flash_mb=250

##
## First time for remediatoin
## 

# Get available disk space in bytes for the /var partition
available_space_var=$(df -k /var | tail -n 1 | awk '{print $4}')
available_space_flash=$(df -k /flash | tail -n 1 | awk '{print $4}')

# Calculate the available space in GB
available_space_var_gb=$(echo "$available_space_var / (1024*1024)" | bc)
available_space_flash_mb=$(echo "$available_space_flash / (1024)" | bc)

# Check if available space is less than the minimum /var
if [ "$available_space_var_gb" -lt "$min_free_space_var_gb" ]; then
    echo "Error: Not enough free disk space in /var."
    echo "Need: ${min_free_space_var_gb}GB"
    echo "Avail: ${available_space_var_gb}GB"
    echo "Removing files."
    ### Free space in /var
    rm -rf "/var/nstrace"/*
    rm -rf "/var/log"/*
    rm -rf "/var/nslog"/*
    rm -rf "/var/tmp/support"/*
    rm -rf "/var/core"/*
    rm -rf "/var/crash"/*
    rm -rf "/var/nsinstall"/*
    rm -rf "/var/mastools/logs"/*
    rm -rf "/var/ns_system_backup"/*
fi

# Check if available space is less than the minimum /flash
if [ "$available_space_flash_mb" -lt "$min_free_space_flash_mb" ]; then
    echo "Error: Not enough free disk space in /flash."
    echo "Need: ${min_free_space_flash_mb}MB"
    echo "Avail: ${available_space_flash_mb}MB"
    echo "Removing files."
    ### Free Space in /flash
    # Get the current kernel version from /flash/boot/loader.conf
    current_kernel=$(cat /flash/boot/loader.conf | grep kernel | sed -nr 's/kernel=\"\/(.*)\"/\1/p')
    current_kernel="/flash/"$current_kernel".gz"

    # Get the list of *.gz in /flash, which should only be boot loaders.
    files="ls /flash/*.gz"
    files="${files:3}"  # remove "ls " at the begining of the return string
    echo $files
    words=( $files ) # convert string to array

    # Abort if there is only one *.gz file and therefore nothing to delete
    if [[ ${#words[@]} -eq 1 ]]; then
        # only 1 .gz file exists in /flash so aboart
        echo "no alternate kernel files found to delete. " $files
        exit 1
    fi

    # Remove all /flash/*.gz files except the current kernel file
    for file in $files; do # loop through all the /flash/*.gz files
        # Proceed only with at least 1 filename matching whats in loader.conf
        if [[ " ${current_kernel[@]} " =~ " ${file} " ]]; then
            # we have a match with loader.conf, so proceed.
            # loop through all the /flash/*.gz files
            for file in $files; do 
                # Make sure the file is not the current_kernel
                if ! [[ " ${current_kernel[@]} " =~ " ${file} " ]]; then
                    # Delete the file since it is not the current kernel    
                    rm -f "$file"
                    echo "Deleted: $file"
                fi
            done
        fi
    done
fi

##
## Second time for verification.
## 

# Get available disk space in bytes for the /var partition
available_space_var=$(df -k /var | tail -n 1 | awk '{print $4}')
available_space_flash=$(df -k /flash | tail -n 1 | awk '{print $4}')

# Calculate the available space in GB
available_space_var_gb=$(echo "$available_space_var / (1024*1024)" | bc)
available_space_flash_mb=$(echo "$available_space_flash / (1024)" | bc)

# Check if available space is less than the minimum /var
if [ "$available_space_var_gb" -lt "$min_free_space_var_gb" ]; then
    echo "Error: Not enough free disk space in /var."
    echo "Need: ${min_free_space_var_gb}GB"
    echo "Avail: ${available_space_var_gb}GB"
    error=1
fi

# Check if available space is less than the minimum /flash
if [ "$available_space_flash_mb" -lt "$min_free_space_flash_mb" ]; then
    echo "Error: Not enough free disk space in /flash."
    echo "Need: ${min_free_space_flash_mb}MB"
    echo "Avail: ${available_space_flash_mb}MB"
    error=1
fi

# check if error condition was detected
if [ "$error" = 1 ]; then
    exit 1
fi

# exit normally when no errors occur
echo "sufficient free disk space exists."
echo "/var: ${available_space_var_gb}GB"
echo "/flash: ${available_space_flash_mb}MB"
exit 0