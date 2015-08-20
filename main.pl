#! /usr/bin/perl

use strict;
use v5.10;
use Data::Dumper;

my $linkregex = /href\=(\"|\')(?<file>[^\"\']*)(\"|\')/;

my $extensionregex = qr/\.(jpeg|JPG|jpg|png|PNG|css|icon)(\"|\')/;

my $httpRequestOk = qr/HTTP\s+request\s+sent,\s+awaiting\s+response(\.)*\s+200\s+OK/;

my $argc= $#ARGV;

unless ($argc <= 0){
    say 'Usage: ./main.pl my_domain_name.com';     
    exit -1;
}

my @parents = ();
push @parents, $ARGV[0];

my $json_result = {};
my $path= $ARGV[0];

while ($#parents >= 0){

    my $current_parent = pop @parents;
    my $wget = `wget $current_parent 2>&1`;
    unless ($wget =~ $httpRequestOk)
    {
        say $wget;
        my $wget = `wget -q $path.$current_parent 2>&1`;
        unless ($wget =~ $httpRequestOk)
        {
            say 'current path was not retrieve!';
            say $current_parent.' or this path '.$path.$current_parent;
            next;
        }
    }
    
    my $linewget = `echo '$wget' | grep "$linkregex"`;
    say 'line get is : '.$linewget;
    my @lines = split(/\n/, $linewget);
    say    Dumper(@lines); 

    if ($#lines < 0)
    {
        last;
    }
    foreach my $line (@lines){
        my $currentParent = $ARGV[0];
        $line =~ s/(\t|\s)*//g;

        unless($line =~ $linkregex)
        {
            say 'No href has been found on this line';
            say 'Abnormal behavior';
            say $line;
            last;
        }

        my $matchLink = {%+};
        say 'value';
        say Dumper($matchLink);
        
        my $element;
        if ($line =~ $extensionregex){
            $json_result->{$currentParent}->{$line} = 'FILE';
        }
        else{
            $json_result->{$currentParent}->{$line} = "LINK";
            push @parents, $matchLink;
        }
    }
}
say Dumper($json_result);
