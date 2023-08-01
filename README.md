These scripts support the care and feeding of SSL files by identifying systems in an undesirable state and facilitating cleanup.  Combine with ADM SSL Certificate Management and configuration jobs for robust remediation.  Run these on both the primary and secondary devices.

## Read-only type scripts:
- invalid.pl - Confirm ssl files are not using invalid characters like spaces, asterisks, slashes, etc.
- missing.pl - Confirm all in-use ssl files are in /nsconfig/ssl.
  - Using invalid characters messes with replication which impacts HA. Detect if you're about to have a bad day.
- chk_dsk_space.sh - Check for sufficient free space in /var and /flash IAW CTX237973.
  - ADM Upgrade prerequisite checking does this but now you can check fleet-wide before creating the upgrade job. 


## Scripts that delete stuff
- archive_old.pl - Archive ssl files not in use.
  - all those certKeys you thought were deleted may still be in the /nsconfig/ssl folder. This script will move those files into an archive you can download. 
- dsk_clean.sh - Free disk space in /var and /flash.

  
## Run them as a Configuration Job
These scripts are meant to be run as ADM Config Jobs using the <b>local_script.json</b> configuration template.   The Read-only type return a "completed" execution status if the system complies, otherwise an "error" is returned.  Additional details can be seen if you run it from ssh.
- local_script.json - ADM config job for uploading and executing a script
    

![local_script.json](https://raw.githubusercontent.com/rd636/adc_scripts/master/image.gif)
