#!/usr/bin/perl

use strict;
#use warnings;

use Sys::Syslog qw(:DEFAULT setlogsock);
setlogsock('unix');
openlog('mailbox_sync','','info');


my %opt;
my %accounts_list;
my ($serverid, $orderid,@report_data,$emailaddress, $key, $value, $mss_serverid,@command);

## Get the variables first
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

sub randomPassword {
    my $password;
    my $_rand;

    my $password_length = $_[0];
    if (!$password_length) {
        $password_length = 10;
    }

    my @chars = split(" ",
        "a b c d e f g h i j k l m n o p q r s t u v w x y z
        A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
        0 1 2 3 4 5 6 7 8 9");

    srand;

    for (my $i=0; $i <= $password_length ;$i++) {
        $_rand = int(rand 67);
        $password .= $chars[$_rand];
    }

    return $password;
}

my $ID = randomPassword(8);

## Is this guys gmail ?
if ( $remote_username =~ /\@gmail.com$/ ) {
        syslog('info',"$ID: the from address $remote_username is a google address");

        my @gmail_command = ('/usr/bin/imapsync','--host1','imap.gmail.com','--ssl1','--port1','993','--user1',"$remote_username",'--password1', "$remote_password",'--authmech1','LOGIN','--host2',"$local_hostname",'--port2','143','--user2',"$local_username","--password2","$local_password",'--delete2','--authmech2','LOGIN','--subscribe', '--exclude','All Mail', '--prefix2', 'oldmails/' , '--sep2', '/', '--regextrans2','s/\[Gmail\]//','--allowsizemismatch');

        syslog('info', "$ID: running /usr/bin/imapsync --host1 imap.gmail.com --ssl1 --port1 993 --user1 $remote_username --password1 $remote_password --authmech1 LOGIN --host2 $local_hostname --port2 143 --user2 $local_username --password2 $local_password --delete2 --authmech2 LOGIN --subscribe --exclude All Mail --prefix2 oldmails/ --sep2 / --regextrans2 s/\[Gmail\]// --allowsizemismatch");

        my $gmail_retval = system(@gmail_command);

        if ( $gmail_retval != 0 ) {
                syslog('info',"$ID: could not sync $remote_username with $local_username");
                exit 2;
                ## This means that syncing failed for this account for some damn reason
        } else {
                syslog('info',"$ID: successfully synced $remote_username with $local_username");
                exit $gmail_retval;
        }
}

## Lets try with default seperator
my @standard_command = ('/usr/bin/imapsync', '--host1', "$remote_hostname", '--user1', "$remote_username", '--port1', "$remote_port", '--password1', "$remote_password", '--authmech1', 'LOGIN', '--host2', "$local_hostname", '--port2', '143', '--user2', "$local_username",  '--password2', "$local_password",'--delete2', '--authmech2', 'LOGIN', '--subscribe', '--sep2', '/', '--prefix2', 'oldmails/', '--exclude', '^Shared Folder');

syslog('info',"$ID: standard command => /usr/bin/imapsync --host1 $remote_hostname --user1 $remote_username --port1 $remote_port --password1 $remote_password --authmech1 LOGIN --host2 $local_hostname --port2 143 --user2 $local_username --password2 $local_password --delete2 --authmech2 LOGIN --subscribe --sep2 / --prefix2 oldmails/");

my $standard_retval = system(@standard_command);

if ( $standard_retval != 0 ) {
syslog('info',"$ID: $remote_username mailbox could not be synced with $local_username default as seperator");
## This is some non standard server try with a seperator now
my @non_standard_command = ('/usr/bin/imapsync', '--host1', "$remote_hostname", '--user1', "$remote_username", '--port1', "$remote_port", '--password1',"$remote_password", '--authmech1', 'LOGIN', '--host2', "$local_hostname", '--port2', '143', '--user2', "$local_username",  '--password2', "$local_password", '--delete2', '--authmech2', 'LOGIN', '--subscribe', '--sep2', '/', '--prefix2', 'oldmails/' , '--sep1','/', '--prefix1', '');

syslog('info',"$ID: non default twisted command => /usr/bin/imapsync --host1 $remote_hostname --user1 $remote_username --port1 $remote_port --password1 $remote_password --authmech1 LOGIN --host2 $local_hostname --port2 143 --user2 $local_username --password2 $local_password --delete2 --authmech2 LOGIN --subscribe --sep2 / --prefix2 oldmails/ --sep1 / --prefix1");

        my $non_standard_retval = system(@non_standard_command);
        if ( $non_standard_retval != 0 ) {
                syslog('info',"$ID: $remote_username mailbox could not be synced with $local_username with / as seperator");
                exit 3;
                ## exit 3 means that we need to manually sync for this guy as the remote server seperator is neither default nor /
                ## This may also mean that we are unsure of the authmech or if the guy wants to use ssl or many other variable things
                ## Thus we may have to check this and add a new case for this provider
        }

        syslog('info',"$ID: successfully synced $remote_username with $local_username using the --sep1 option as /");
        exit $non_standard_retval;
}

syslog('info',"$ID successfully synced $remote_username with $local_username using default seperator");
exit $standard_retval;

