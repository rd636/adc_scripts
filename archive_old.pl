#!/usr/bin/perl
# 
#   This program archives not-in-use files in the /nsconfig/ssl folder.
#
#   Use 'P' to restore the archive from the shell 
#   # cd /nsconfig/ssl
#   # tar -xvPf archive.tar 
#
#    This code is provided to you as is with no representations, 
#    warranties or conditions of any kind. You may use, modify and 
#    distribute it at your own risk. CSG disclaims all warranties 
#    whatsoever, express, implied, written, oral or statutory, including 
#    without limitation warranties of merchantability, fitness for a 
#    particular purpose, title and noninfringement.
#
#
use strict;
use warnings;
use File::Copy;
use Archive::Tar;

# 0 = Archive without deleteing; 1 = Delete after archiving
my $delete = 0;

# Extract filenames from config
my @file_names = get_file_names_from_conf('/nsconfig/ns.conf');

# Path to the folder containing files to be moved
my $source_folder = '/nsconfig/ssl';

# Path to the archive file
my $archive_file = '/nsconfig/ssl/archive.tar';

# create an array of files in the ssl folder
my @folder_files = get_ssl_folder_files($source_folder);

# Check if ssl folder file was found in the config
my @unused_files;
my %hash_of_certKeys;
foreach my $file (@file_names) {    # create hash of certKey files
    $hash_of_certKeys{$file} = 1;
}
foreach my $file (@folder_files) { # test $_ against the certKey hash (files from config)
    if (exists $hash_of_certKeys{$file}) { 
        # filename is referenced in config
    } else {
        push @unused_files, $file;
    }
}

# Create the archive object
my $archive = Archive::Tar->new();

# Move files to the archive
foreach my $file (@unused_files) {
    archive_file($file, $delete);
}

# Save the archive
$archive->write($archive_file) or die "Failed to write the archive: $!";
print "Archive created successfully: $archive_file\n";
exit(0);

### Subroutines ###

sub archive_file {  # Move files not in @file_array to the archive
    my ($file, $delete) = @_;
    $file = $source_folder.'/'.$file;
    if (-e $file) {
        $archive->add_files($file) or die "Failed to add $file to the archive: $!";
        print "Added $file to the archive.\n";
        # Remove the original file
        if ($delete) {
            unlink $file or warn "Failed to remove $file: $!";
            print "Removed $file.\n";
        }
    } else {
        warn "$file does not exist. Skipping...\n";
    }

}

sub get_file_names_from_conf {
    my ($filename) = @_;
    unless (-e $filename) {
        die "File '$filename' does not exist.\n";
    }
    open(my $fh, '<', $filename) or die "Cannot open file '$filename': $!";
    my @file_names;
    while (my $line = <$fh>) {
        if ($line =~ / -cert (?|"([^"]*)"|(\S+)) -key (?|"([^"]*)"|(\S+))($|\s)/g) {
            push @file_names, $1, $2;
            print "$line";
        } elsif ($line =~ / -cert (?|"([^"]*)"|(\S+))($|\s)/g) {
            push @file_names, $1;
            print "$line";
        }       
    }
    close($fh);
    return @file_names;
}

sub get_ssl_folder_files {
    my ($folder) = @_;
    my @file_names;
    # Populate the array with filenames in the folder
    opendir(my $dh, $folder) or die "Cannot open directory '$folder': $!";
    while (my $file = readdir($dh)) {
        next if ($file =~ /^\./); # Skip entries starting with '.'
        push @file_names, $file
    }
    closedir($dh);
    return @file_names;
}
