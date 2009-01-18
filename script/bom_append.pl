#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

our $root = '../root/src';
our $bom  = "\x{EF}\x{BB}\x{BF}";

process_dir($root);

sub process_dir {
    my $dir   = shift;
    my @files = glob( $dir . "/*" );
    foreach my $file (@files) {
        if ( -f $file && $file =~ /\.tt$/ ) {
            process_file($file);
        }
        elsif ( -d $file && $file !~ m|/\.svn| ) {
            process_dir($file);
        }
    }
}

sub process_file {
    my $name = my $file = shift;
    $name =~ s/^$root//;
    print sprintf( "Processing : %-50s", $name );
    local ( *FH, $/ );
    open( FH, '<:bytes', $file )
        or die "can't open $file: $!";
    my $a = <FH>;
    close FH;

    my $b = $a;
    $a =~ s/$bom//g;
    $a = $bom . $a;
    if ( $a ne $b ) {
        open( FH, '>:bytes', $file )
            or die "can't write to $file : $!";
        print FH $a;
        close FH
            or die "can't close file $file";
        print " ...Updated\n";
    }
    else {
        print "\n";
    }
}

