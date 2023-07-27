#!/bin/sh
#
#   This program deletes files IAW: 
#   https://docs.netscaler.com/en-us/citrix-application-delivery-management-service/networks/configuration-jobs/how-to-upgrade-adc-instances.html#clean-up-the-adc-disk-space
#
#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
rm -rf "/var/nstrace"/*
rm -rf "/var/log"/*
rm -rf "/var/nslog"/*
rm -rf "/var/tmp/support"/*
rm -rf "/var/core"/*
rm -rf "/var/crash"/*
rm -rf "/var/nsinstall"/*
rm -rf "/var/mastools/logs"/*
rm -rf "/var/ns_system_backup"/*