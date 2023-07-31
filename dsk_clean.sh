#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
### Free space in /var
### IAW https://docs.netscaler.com/en-us/citrix-adc/current-release/system/troubleshooting-citrix-adc/how-to-free-space-on-var-directory.html
###
rm -rf "/var/nstrace"/*
rm -rf "/var/log"/*
rm -rf "/var/nslog"/*
rm -rf "/var/tmp/support"/*
rm -rf "/var/core"/*
rm -rf "/var/crash"/*
rm -rf "/var/nsinstall"/*
rm -rf "/var/mastools/logs"/*
rm -rf "/var/ns_system_backup"/*
###
### Free Space in the /flash IAW CTX133587
###
# Define the current kernel in use
current_kernel=$(cat /flash/boot/loader.conf | grep kernel | sed -nr -E 's/kernel=\"\/(.*)\"/\1/p')
current_kernel="/flash/"$current_kernel".gz"

# Get list of kernels in /flash
files="ls /flash/*.gz"

# Loop through the files in the directory
for file in $files; do
    # Check if the file is not the current_kernel
    if ! [[ " ${current_kernel[@]} " =~ " ${file} " ]]; then
        if ! [[ " ${file} " =~ "ls" ]]; then
        # Delete the file
        rm -f "$file"
        echo "Deleted: $file"
        fi
    fi
done
