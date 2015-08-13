#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw(GetOptions);
my $email_address;

GetOptions("e=s" => \$email_address);

if(!(defined($email_address))) {
	print("Usage: mailbox_sync.pl -e <email_address>\n");
	exit 1;
}

print "Running fake mailbox_sync on $email_address\n";