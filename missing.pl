#!/usr/bin/perl
# 
#   This program warns when certKey files are missing from the /nsconfig/ssl folder.
#
#   Success = exit 0 - No ssl files are missing.
#   Failure = exit 1 - Missing file are listed in the cli output.
#
#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. Author disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
#
# > shell /var/tmp/missing.pl
#
# Files not found in the ssl folder:
# www.example.pfx
# ERROR:
# >
#
#
# > shell /var/tmp/missing.pl
#
# All files in the config were found in the ssl folder.
# Done.
# >
#
#
# Sample Config Job:
# put $program$ /var/tmp/$program$
# shell "chmod +x /var/tmp/$program$"
# shell "/var/tmp/$program$"
#
#
use strict;
use warnings;

# Extract certKey filenames from config
my @file_names = get_file_names_from_file('/nsconfig/ns.conf');

# Compare the SSL folder to the certKey list with a binary result
exit(compare_files_in_folder('/nsconfig/ssl', @file_names));


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


sub compare_files_in_folder {
    my ($folder, @file_array) = @_;

    # Check if the folder exists
    unless (-d $folder) {
        die "Folder '$folder' does not exist.\n";
    }

    # Initialize a hash to store the filenames in the folder
    my %folder_files;

    # Populate the hash with filenames in the folder
    opendir(my $dh, $folder) or die "Cannot open directory '$folder': $!";
    while (my $file = readdir($dh)) {
        next if ($file =~ /^\./); # Skip entries starting with '.'
        $folder_files{$file} = 1;
    }
    closedir($dh);

    # Compare the array of file names with the files in the folder
    my @not_found;    
    my @found;
    my @invalid;
    foreach my $file (@file_array) {
        if (exists $folder_files{$file}) {
            # print "$file: Found\n";
            push @found, $file;
        } else {
            push @not_found, $file;
        }
        #delete $folder_files{$file}; # Remove files found from the hash
    }
    
    # Return final results
    if (@not_found) {
        print "\nFiles not found in the ssl folder:\n";
        print join("\n", @not_found), "\n";
        return(1);
    } else {
        print "\nAll the SSL filenames in the config are found in the ssl folder.\n";
        return(0);
    }    
}