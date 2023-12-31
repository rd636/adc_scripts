These scripts support the care and feeding of SSL files by identifying systems in an undesirable state and facilitating cleanup.  Combine these with ADM  Certificate Management and configuration jobs for robust remediation.  Run these on both the primary and secondary devices.   The focus here is to address filesystem cleanup challenges which must stay aligned with what is defined in the configuration. 

## Read-only type scripts:
- invalid.pl - Confirm ssl files are not using invalid characters like spaces, asterisks, slashes, stored in a subfolder, etc.
  - This script will also provide corrective commands.
  - Use this script before using missing.pl or archive_old.pl.
- missing.pl - Confirm all in-use ssl files are in /nsconfig/ssl.
  - Using invalid characters messes with replication which impacts HA. Detect if you're about to have a bad day.
  - The output details the filenames it can not locate.
  - Use the invalid.pl script before trying to use this one.
- chk_dsk_space.sh - Confirm sufficient free space exists in /var and /flash IAW CTX237973.
  - ADM Upgrade prerequisite checking does this but now you can check fleet-wide before creating the upgrade job. 


## Scripts that delete stuff
- archive_old.pl - Archive ssl files not in use.
  - all those certKeys you deleted from the configuration likely left the associated files in the /nsconfig/ssl folder. This script will move those files into a single tar file you can delete or archive.
  - Third-party certificate management tools probably left behind old files which this will help remove.
- dsk_clean.sh - Free disk space in /var and /flash.
- storage_cleanup.sh - Run this script for periodic monitoring and cleanup of storage space.
  - This is a combination of chk_dsk_space and dsk_clean scripts.
  - Runs a cleanup of /var and /flash when needed.
  - Reports an error if the cleanup did not restore sufficient space.

  
## Run them as a Configuration Job
These scripts are meant to be run as ADM Config Jobs using the <b>local_script.json</b> configuration template.   The Read-only type return a "completed" execution status if the system complies, otherwise an "error" is returned.  Additional details can be seen if you run it from ssh.
- local_script.json - ADM config job for uploading and executing a script
    

![local_script.json](https://raw.githubusercontent.com/rd636/adc_scripts/master/image.gif)
