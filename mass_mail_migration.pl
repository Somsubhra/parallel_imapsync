#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw(GetOptions);
my $num_processes;

GetOptions('j=s' => \$num_processes);

if(!(defined($num_processes))) {
	$num_processes = 10;
	print "Using default value for number of maximum processes: 10\n";
}

print "Number of maximum processes chosen: $num_processes\n";

use Parallel::ForkManager;

my $pm = Parallel::ForkManager->new($num_processes);

open(my $fh, '<', "data.csv") or die $!;

while(my $data = <$fh>) {
	my @literals = split /,/, $data, 7;

	my $remote_username = $literals[0];
	my $local_username = $literals[1];
	my $remote_password = $literals[2];
	my $local_password = $literals[3];
	my $remote_imap_host = $literals[4];
	my $remote_imap_port = $literals[5];
	my $local_imap_host = $literals[6];

	my $pid = $pm->start and next;
	print system("/usr/bin/perl mailbox_sync.pl -u $remote_username -e $local_username -p $remote_password -a $local_password -r $remote_imap_host -o $remote_imap_port -l $local_imap_host");
	$pm->finish;
}