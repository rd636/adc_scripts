#!/usr/bin/perl
# 
#   This program warns when cert and key names are using invalid characters. 
#   Only valid characters are A-Za-z0-9._-
#   Corrective actions are included in the output.
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
use strict;
use warnings;

# Extract certKey filenames from config
my @file_names = get_file_names_from_file('/nsconfig/dns.conf');

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
            # If invalid characters are used in the certificate, provide corrective commands
            if (invalid_test($2)) {
            my $cert = invalid_test($2);
                print "# cert: $2 \n";
                print "shell cd /nsconfig/ssl && cp -n \"$2\" $cert \n";
                print "update ssl certKey \"$1\" -cert $cert \n# \n";
            }
            # If invalid characters are used in the key, provide corrective commands
            if (invalid_test($3)) {
                my $key = invalid_test($3);
                print "# key $3 \n";
                print "shell cd /nsconfig/ssl && cp -n \"$3\" $key \n";
                print "update ssl certKey \"$1\" -key $key \n# \n";
            }          
        } elsif ($line =~ /add ssl certKey (?|"([^"]*)"|(\S+)) -cert (?|"([^"]*)"|(\S+))($|\s)/g) {
            push @file_names, $2;
            # If invalid characters are used in the CA Certificate, provide corrective commands
            if (invalid_test($2)) {
                my $cert = invalid_test($2);
                print "# ca cert: $2 \n";
                print "shell cd /nsconfig/ssl && cp -n \"$2\" $cert \n";
                print "update ssl certKey \"$1\" -cert $cert \n# \n";
            }
        } 
    }
    close($fh);
    return @file_names;
}

sub invalid_test {
    my ($filename) = @_;
    if ($filename =~ /[^A-Za-z0-9._-]/) {
        # Strip file location information
        if ($filename =~ /\//) {
            ($filename) = $filename =~ m#([^/]+)$#;
            # To prevent a conflict, check if a file of the same name already exists
            if (-e '/nsconfig/ssl/'.$filename) {
                # file already exists in 
                print "# \n# ERROR: /nsconfig/ssl/$filename already exists \n# \n"
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
