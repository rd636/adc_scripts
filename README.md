## Read-only type scripts:
- invalid.pl - Confirm certKey files are not using invalid characters like spaces, asterisks, slashes, etc.
- missing.pl - Confirm all in-use ssl files are in /nsconfig/ssl
  - Using invalid characters messes with replication and impacts HA
- chk_dsk_space.sh - Check for sufficient free space in /var and /flash 


## Scripts that delete stuff
- archive_old.pl - Archive ssl files not in use
  - all those certKeys you thought were deleted may still be on the drive.
- dsk_clean.sh - Free disk space in /var

  
## Run them as a Configuration Job
- local_script.json - ADM config job for uploading and executing a script
  

![local_script.json](https://raw.githubusercontent.com/rd636/adc_scripts/master/image.gif)
