#!/usr/bin/perl
# 
#   This program warns when cert and key names using invalid characters. 
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

# Examine each filename with a binary result
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
        if (contains_invalid_characters($file)) {
            # print "Invalid characters found in \$file.\n";
            push @invalid, $file;
        } 
    }
    # Return final results
    if (@invalid) {
        print "\nFiles found with invalid characters:\n";
        print join("\n", @invalid), "\n";
        return(1);
    } else {
        print "\nAll certKey files are using valid characters.\n";
        return(0);
    }
}

# Test for invalid characters
sub contains_invalid_characters {
    my ($input) = @_;
    return $input =~ /[^A-Za-z0-9._-]/;
}
