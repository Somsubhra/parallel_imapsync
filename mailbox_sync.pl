#!/usr/bin/perl

use strict;
use warnings;

my %opt;
use Getopt::Std;
my $opt_string = 'u:p:r:o:l:a:e:dt';
getopts( "$opt_string", \%opt ) or usage();

my $remote_username = $opt{u};
my $local_username = $opt{e};
my $remote_password = $opt{p};
my $remote_hostname = $opt{r};
my $remote_port = $opt{o};
my $local_hostname = $opt{l};
my $local_password = $opt{a};
my $debug = $opt{d};
my $test = $opt{t};

if ((!defined($remote_username)) or (!defined($local_username)) or (!defined($remote_password)) or (!defined($remote_hostname)) or (!defined($remote_port)) or (!defined($local_hostname)) or (!defined($local_password))) {
        print "usage: mailbox_sync.pl OPTIONS
        -u remote username
        -e local username
        -p remote password
        -a local password
        -r remote imap host
        -o remote imap port
        -l local imap host
        -d debug\n";

        syslog('info',"please read usage, insufficient parameters passed");

        exit 1
}

print "Running fake mailbox_sync on $remote_username:$local_username:$remote_password:$remote_hostname:$remote_port:$local_hostname:$local_password\n";