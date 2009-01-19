#!/usr/bin/sh

find `perl -e 'print join "\n", grep -d $_ && $_ ne ".", @INC'` \
    -type f -wholename '*Plagger*.pm' \
    | xargs grep -n '\->run_hook' \
    | perl -n -e '
        my ($f, $l, $m, $n, $args) = (/^(.+?):(\d+):.*?->run_hook(?:_([a-z]+))?\s*\(\s*(.+?(?=\s|,|\)))(?:.*?,\s*(.*?))?\s*\)\s*;$/);
        if ( $n ) {
            print $n;
            print "($m)" if $m;
            print "\n";
            print "\targs: $args\n";
            print "\tfile: $f:$l\n";
        } else {
            print "unparsable:\n\t$_";
        }
    '

