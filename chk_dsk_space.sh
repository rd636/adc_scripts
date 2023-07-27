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
#

# /var Minimum free space in GB
min_free_space_var_gb=5

# Get available disk space in bytes for the /var partition
available_space_var=$(df -k /var | tail -n 1 | awk '{print $4}')

# Calculate the available space in GB
available_space_var_gb=$(echo "$available_space_var / (1024*1024)" | bc)

# Check if available space is less than the minimum
if [ "$available_space_var_gb" -lt "$min_free_space_var_gb" ]; then
    echo "Error: Not enough free disk space. Available space: ${available_space_var_gb}GB"
    exit 1
fi

echo "/var has sufficient free disk space: ${available_space_var_gb}GB"
exit 0