#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
my %opt;
my $opt_string = "i:p";
getopts("$opt_string", \%opt) or usage();

my $input_file = $opt{i};
my $num_processes = $opt{p};

if(!defined($input_file)) {
	print "Usage: mass_mailbox_sync.pl -i <input_file> -p [max_processes]\n";
	print "CSV Format: <remote_username>,<local_username>,<remote_password>,<local_password>,<remote_imap_host>,<remote_imap_port>,<local_imap_host>\n";
	exit 1;
}

if(!(defined($num_processes))) {
	$num_processes = 10;
	print "Using default value for number of maximum processes: 10\n";
}

print "Number of maximum processes chosen: $num_processes\n";

use Parallel::ForkManager;

my $pm = Parallel::ForkManager->new($num_processes);

sub get_logging_time {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my $nice_timestamp = sprintf("%04d/%02d/%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
    return $nice_timestamp;
}

open(my $lh, ">>status.log");

$pm->run_on_finish(sub {
	my ($pid, $exit_code, $ident) = @_;
	my $timestamp = get_logging_time();
	print $lh "[$timestamp] Process with pid $pid exited with code $exit_code\n";
});

$pm->run_on_start(sub {
	my ($pid, $ident) = @_;
	my $timestamp = get_logging_time();
	print $lh "[$timestamp] Process started with pid $pid\n";
});

open(my $fh, '<', "$input_file") or die $!;

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
	system("/usr/bin/perl mailbox_sync.pl -u $remote_username -e $local_username -p $remote_password -a $local_password -r $remote_imap_host -o $remote_imap_port -l $local_imap_host");
	$pm->finish;
}

$pm->wait_all_children;