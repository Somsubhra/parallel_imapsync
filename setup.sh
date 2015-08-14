#!/bin/sh
apt-get install -y build-essential
cpan File::Copy::Recursive
cpan Digest::HMAC_SHA1
cpan Mail::IMAPClient
cpan Parallel::ForkManager
