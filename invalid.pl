#!/usr/bin/perl
# 
#   This program warns when cert and key names are using invalid characters. 
#   Only valid characters are A-Za-z0-9._-
#   Corrective actions are inlcuded in the output.
#
#   Success = exit 0 - No invalid characters found.
#   Failure = exit 1 - Files needing correction are listed in the cli output.
#
#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
#
# Example output:
#
# # ca cert: CNA Issuing CA-SHA2.cer
# shell cd /nsconfig/ssl && cp -n "CNA Issuing CA-SHA2.cer" CNA_Issuing_CA-SHA2.cer
# update ssl certKey "CNA_Issuing_CA" -cert CNA_Issuing_CA-SHA2.cer
#
# 1 Files found with invalid characters:
# CNA Issuing CA-SHA2.cer
#

use strict;
use warnings;

# Extract certKey filenames from config
my @file_names = get_file_names_from_file('/nsconfig/ns.conf');

# Compare the SSL folder to the certKey list with a binary result
exit(check_files(@file_names));

sub get_file_names_from_file {
    my ($filename) = @_;
    unless (-e $filename) {
        die "File '$filename' does not exist.\n";
    }
    open(my $fh, '<', $filename) or die "Cannot open file '$filename': $!";
    my @file_names;
    while (my $line = <$fh>) {
        if ($line =~ /add ssl certKey (?|"([^"]*)"|(\S+)) -cert (?|"([^"]*)"|(\S+)) -key (?|"([^"]*)"|(\S+))($|\s)/) {
            push @file_names, $2, $3;
            my $cert = $2;
            my $key = $3;
            # If invalid characters are used, provide corrective commands
            if ( invalid_test($cert) || invalid_test($key) ) {
                # my $cert = invalid_test($2);
                print "# certkey: $1 c:$cert k:$key\n";
                if ( invalid_test($cert) ) { 
                    # certificate name needs changing
                    $cert = change_filename($cert);
                    print "shell cd /nsconfig/ssl && cp -n \"$2\" $cert \n";
                }
                if ( invalid_test($key) ) {
                    # keyname needs changing
                    $key = change_filename($key);
                    print "shell cd /nsconfig/ssl && cp -n \"$3\" $key \n";
                }
                # update ssl certKey <certkeyName> [-cert <string> [-password]] [-key <string> 
                if ( encryption_test($3) ) {
                    print "update ssl certKey \"$1\" -cert $cert -key $key -password #### \n# \n";
                } else {
                    print "update ssl certKey \"$1\" -cert $cert -key $key \n# \n";
                }
            }
        } elsif ($line =~ /add ssl certKey (?|"([^"]*)"|(\S+)) -cert (?|"([^"]*)"|(\S+))($|\s)/g) {
            push @file_names, $2;
            # If invalid characters are used in the CA Certificate, provide corrective commands
            if (invalid_test($2)) {
                my $cert = change_filename($2);
                print "# ca cert: $2 \n";
                print "shell cd /nsconfig/ssl && cp -n \"$2\" $cert \n";
                print "update ssl certKey \"$1\" -cert $cert \n# \n";
            }
        } 
    }
    close($fh);
    return @file_names;
}

sub encryption_test {
    my ($filename) = @_;
    my $encryption = `cd /nsconfig/ssl/ && grep -c ENCRYPTED $filename`;
    chomp $encryption;
    if ($encryption eq "1") {
        # file has encryption  
        return(1);
    } else { 
        # file does not has encryption  
        return(0);
    }
}

sub change_filename {
    my ($filename) = @_;
    if ($filename =~ /[^A-Za-z0-9._-]/) {
        # Strip file location information
        if ($filename =~ /\//) {
            ($filename) = $filename =~ m#([^/]+)$#;
            # check if a file of the same name already exists and warn 
            if (-e '/nsconfig/ssl/'.$filename) {
                # file already exists in 
                print "# \n# WARNING: /nsconfig/ssl/$filename already exists \n# \n"
            }
        }
        # Strip remaining invalid characters 
        $filename =~ s/[^A-Za-z0-9._-]+/_/g;
        return($filename);
    } else {
        # Valid characters in use
        return(0);
    }
}

sub invalid_test {
    my ($filename) = @_;
    if ($filename =~ /[^A-Za-z0-9._-]/) {
        return(1);
    } else {
        return(0);
    }
}

sub check_files {
    my (@file_array) = @_;
    my @invalid;
    foreach my $file (@file_array) {
        if ($file =~ /[^A-Za-z0-9._-]/) {
            # print "Invalid characters found in \$file.\n";
            push @invalid, $file;
        } 
    }
    # Return final results
    if (@invalid) {
        print "\n", scalar @invalid, " Files found with invalid characters:\n";
        print join("\n", @invalid), "\n";
        return(1);
    } else {
        print "\nAll ", scalar @file_array, " certKey files are using valid characters.\n";
        return(0);
    }
}
