#!/usr/bin/env perl
# $Id: initialize_cog_content.pl,v 1.1 2006/09/26 20:21:09 givans Exp givans $

use warnings;
use strict;
use Carp;
use HTML::Mason;
use Getopt::Std;
use Cwd;
use vars qw/ $opt_o $opt_a $opt_h $opt_v /;
use lib '/home/sgivan/projects/COGDB';

getopts('o:ahv');

my $usage = "usage:  initialize_cog_content.pl -o <project code>\n\nfor example:  initialize_cog_content.pl -o PU1002\n\n";

if ($opt_h) {

print <<HELP;

This script initializes content for the Marine Microbial Genomics COG tool

$usage
Command-line options:
-o	oganism code (ie, PU1062)
-a	initialize content for all organisms
           reads a file in current directory called "organisms.txt"
-v	verbose output to terminal

HELP

exit();

}

my $verbose = $opt_v;
my @organisms = ();
my $cd = cwd();
print "working directory = '$cd'\n" if ($verbose);

#
# verify or set-up file expected structure
#
if (!-e 'cog_content.comp') {
	print "creating link to cog_content.comp\n" if ($verbose);
	if (!symlink('/home/cgrb/cgrblib/cog_content/cog_content.comp','cog_content.comp')) {
		die("can't create link to cog_content.comp\n");
	} else {
		print "success\n" if ($verbose);
	}
}

my @reqdirs = ('content','mason');

foreach my $dir (@reqdirs) {

	if (!-e $dir) {
		print "creating '$dir' directory\n" if ($verbose);
		if (!mkdir($dir)) {
			die("can't create directory '$dir': $!");
		} else {
			print "success\n" if ($verbose);
		}
	} elsif (!-d $dir) {
		print "\nthis script needs to create a directory called '$dir', but it looks like there is a file 
with that same name. Please either remove that file or run this script in a new directory.\n\n";
	}
}

if ($opt_o) {
  push(@organisms,$opt_o);
} elsif ($opt_a) {

  open(ORGFILE,"organisms.txt") or die "can't open organisms.txt: $!";
  map { chomp($_); push(@organisms,$_) } (<ORGFILE>);
  die "can't close organisms.txt: $!" if (!close(ORGFILE));

} else {
  print $usage;
  exit();
}


my $path = '/cog_content.comp';
my $outbuf;
# my $interp = HTML::Mason::Interp->new(
# 					comp_root 	=>	'/home/cgrb/givans/projects/cog_content',
# 					data_dir	=>	'/home/cgrb/givans/projects/cog_content/mason',
# 					out_method	=>	\$outbuf,
# 					);
my $interp = HTML::Mason::Interp->new(
					comp_root 	=>	"$cd",
					data_dir	=>	"$cd/mason",
					out_method	=>	\$outbuf,
					);

foreach my $org (@organisms) {
  print "\n\ninitializing COG content for '$org'\n";

  print "initializing \"present\" COGs\n";
  $interp->exec($path, org => $org);

  print "initializing \"absent\" COGs\n";
  $interp->exec($path, org => $org, absent => 1);

  print "initializing \"novel\" COGs\n";
  $interp->exec($path, org => $org, novel => 1);

  print $outbuf;

}
