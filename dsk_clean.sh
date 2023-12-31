#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.

###
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
### Free Space in /flash IAW CTX133587
### Remove all /flash/*.gz files not listed as the kernel file in /flash/boot/loader.conf
###

# Get the current kernel version from /flash/boot/loader.conf
current_kernel=$(cat /flash/boot/loader.conf | grep kernel | sed -nr 's/kernel=\"\/(.*)\"/\1/p')
current_kernel="/flash/"$current_kernel".gz"

# Get the list of *.gz in /flash, which should only be boot loaders.
files="ls /flash/*.gz"
files="${files:3}"  # remove "ls " at the begining of the return string
echo $files

# Abort if there is only one *.gz file and therefore nothing to delete
words=( $files )    # convert string to array
if [[ ${#words[@]} -eq 1 ]]; then
  # Exit the script
  echo "no alternate kernel files found to delete." $files
  exit 0
fi

# Remove all /flash/*.gz files except the current kernel file
for file in $files; do # loop through all the /flash/*.gz files
    # Proceed only if we have a file matching loader.conf
    if [[ " ${current_kernel[@]} " =~ " ${file} " ]]; then
        # we have a match with loader.conf, now delete the rest
        # loop through all the /flash/*.gz files
        for file in $files; do 
            # Check if the file is not the current_kernel
            if ! [[ " ${current_kernel[@]} " =~ " ${file} " ]]; then
                # Delete the file since it is not the current kernel    
                rm -f "$file"
                echo "Deleted: $file"
            fi
        done
    fi
done
