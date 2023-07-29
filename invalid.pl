#!/usr/bin/perl
# 
#   This program warns when cert or key names are using invalid characters. 
#   The only valid characters are A-Za-z0-9._-
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
        if ($line =~ /add ssl certKey .*? -cert (?|"([^"]*)"|(\S+)) -key (?|"([^"]*)"|(\S+))($|\s)/) {
            push @file_names, $1, $2;
        } elsif ($line =~ / -cert (?|"([^"]*)"|(\S+))($|\s)/g) {
            push @file_names, $1;
        } 
    }
    close($fh);
    return @file_names;
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
