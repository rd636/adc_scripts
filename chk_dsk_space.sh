#!/bin/sh
#
#   This program checks /var for sufficient space IAW CTX237973
#
#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
# EXAMPLE:
#
#> shell /var/chk_dsk_space.sh
# Error: Not enough free disk space in /flash.
# Need: 250MB
# Avail: 127MB
# ERROR:
# >
# > shell /var/chk_dsk_space.sh
# sufficient free disk space exists.
# /var: 9GB
# /flash: 1284MB
#  Done
# >
#
#

# Minimum free space
min_free_space_var_gb=5
min_free_space_flash_mb=250

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
