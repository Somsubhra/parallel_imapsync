#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw(GetOptions);
my $num_threads;

GetOptions('j=s' => \$num_threads);

if(!(defined($num_threads))) {
	$num_threads = 10;
	print "Using default value for number of threads: 10\n";
}

print "Number of threads chosen: $num_threads\n";