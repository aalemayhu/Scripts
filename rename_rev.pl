#!/usr/bin/perl

# This is a tool to help review variable rename patches. The goal is
# to strip out the automatic sed renames and the white space changes
# and leaves the interesting code changes.
#
# Example 1: A patch renames openInfo to open_info:
#     cat diff | rename_review.pl openInfo open_info
#
# Example 2: A patch swaps the first two arguments to some_func():
#     cat diff | rename_review.pl \
#                    -e 's/some_func\((.*?),(.*?),/some_func\($2, $1,/'
#
# Example 3: A patch removes the xkcd_ prefix from some but not all the
# variables.  Instead of trying to figure out which variables were renamed
# just remove the prefix from them all:
#     cat diff | rename_review.pl -ea 's/xkcd_//g'
#
# Example 4: A patch renames 20 CamelCase variables.  To review this let's
# just ignore all case changes and all '_' chars.
#     cat diff | rename_review -ea 'tr/[A-Z]/[a-z]/' -ea 's/_//g'
#
# The other arguments are:
# -nc removes comments
# -ns removes '\' chars if they are at the end of the line.

use strict;
use File::Temp qw/ :mktemp  /;

sub usage() {
    print "usage: cat diff | $0 old new old new old new...\n";
    print "   or: cat diff | $0 -e 's/old/new/g'\n";
    print " -a : auto";
    print " -e : execute on old lines\n";
    print " -ea: execute on all lines\n";
    print " -nc: no comments\n";
    print " -nb: no unneeded braces\n";
    print " -ns: no slashes at the end of a line\n";
    print " -pull: for function pull.  deletes context.\n";
    print " -r <recipe>: NULL, bool";
    exit(1);
}
my @subs;
my @strict_subs;
my @cmds;
my $strip_comments;
my $strip_braces;
my $strip_slashes;
my $pull_context;
my $auto;

sub filter($) {
    my $_ = shift();
    my $old = 0;
    if ($_ =~ /^-/) {
        $old = 1;
    }
    # remove the first char
    s/^[ +-]//;
    if ($strip_comments) {
        s/\/\*.*?\*\///g;
        s/\/\/.*//;
    }
    foreach my $cmd (@cmds) {
        if ($old || $cmd->[0] =~ /^-ea$/) {
            eval $cmd->[1];
        }
    }
    foreach my $sub (@subs) {
        if ($old) {
            s/$sub->[0]/$sub->[1]/g;
        }
    }
    foreach my $sub (@strict_subs) {
        if ($old) {
            s/\b$sub->[0]\b/$sub->[1]/g;
        }
    }

    # remove the newline so we can move curly braces here if we want.
    s/\n//;
    return $_;
}

while (my $param1 = shift()) {
    if ($param1 =~ /^-a$/) {
        $auto = 1;
        next;
    }
    if ($param1 =~ /^-nc$/) {
        $strip_comments = 1;
        next;
    }
    if ($param1 =~ /^-nb$/) {
        $strip_braces = 1;
        next;
    }
    if ($param1 =~ /^-ns$/) {
        $strip_slashes = 1;
        next;
    }
    if ($param1 =~ /^-pull$/) {
        $pull_context = 1;
        next;
    }
    my $param2 = shift();
    if ($param2 =~ /^$/) {
        usage();
    }
    if ($param1 =~ /^-e(a|)$/) {
        push @cmds, [$param1, $param2];
        next;
    }
    if ($param1 =~ /^-r$/) {
        if ($param2 =~ /bool/) {
            push @cmds, ["-e", "s/== true//"];
            push @cmds, ["-e", "s/true ==//"];
            push @cmds, ["-e", "s/([a-zA-Z\-\>\._]+) == false/!\$1/"];
            next;
        } elsif ($param2 =~ /NULL/) {
            push @cmds, ["-e", "s/ != NULL//"];
            push @cmds, ["-e", "s/([a-zA-Z\-\>\._0-9]+) == NULL/!\$1/"];
            next;
        } elsif ($param2 =~ /BIT/) {
            push @cmds, ["-e", 's/1[uUlL]* *<< *(\d+)/BIT($1)/'];
            push @cmds, ["-e", 's/\(1 *<< *(\w+)\)/BIT($1)/'];
            push @cmds, ["-e", 's/\(BIT\((.*?)\)\)/BIT($1)/'];
            next;
        }
        usage();
    }

    push @subs, [$param1, $param2];
}

my ($oldfh, $oldfile) = mkstemp("/tmp/oldXXXXX");
my ($newfh, $newfile) = mkstemp("/tmp/newXXXXX");

my @input = <STDIN>;

# auto works on the observation that the - line comes before the + line when we
# rename variables.  Take the first - line.  Find the first + line.  Find the
# one word difference.  Test that the old word never occurs in the new text.
if ($auto) {
    my %c_keywords = (  auto => 1,
                        break => 1,
                        case => 1,
                        char => 1,
                        const => 1,
                        continue => 1,
                        default => 1,
                        do => 1,
                        double => 1,
                        else => 1,
                        enum => 1,
                        extern => 1,
                        float => 1,
                        for => 1,
                        goto => 1,
                        if => 1,
                        int => 1,
                        long => 1,
                        register => 1,
                        return => 1,
                        short => 1,
                        signed => 1,
                        sizeof => 1,
                        static => 1,
                        struct => 1,
                        switch => 1,
                        typedef => 1,
                        union => 1,
                        unsigned => 1,
                        void => 1,
                        volatile => 1,
                        while => 1);
    my %old_words;
    my %new_words;
    my %added_cmds;
    my @new_subs;

    my $inside = 0;
    foreach my $line (@input) {
        if ($line =~ /^(---|\+\+\+)/) {
            next;
        }

        if ($line =~ /^@/) {
            $inside = 1;
        }
        if ($inside && !(($_ =~ /^[- @+]/) || ($_ =~ /^$/))) {
            $inside = 0;
        }
        if (!$inside) {
            next;
        }

        if ($line =~ /^-/) {
            s/-//;
            my @words = split(/\W+/, $line);
            foreach my $word (@words) {
                $old_words{$word} = 1;
            }
        } elsif ($line =~ /^\+/) {
            s/\+//;
            my @words = split(/\W+/, $line);
            foreach my $word (@words) {
                $new_words{$word} = 1;
            }
        }
    }

    my $old_line;
    my $new_line;
    $inside = 0;
    foreach my $line (@input) {
        if ($line =~ /^(---|\+\+\+)/) {
            next;
        }

        if ($line =~ /^@/) {
            $inside = 1;
        }
        if ($inside && !(($_ =~ /^[- @+]/) || ($_ =~ /^$/))) {
            $inside = 0;
        }
        if (!$inside) {
            next;
        }


        if ($line =~ /^-/ && !$old_line) {
            s/^-//;
            $old_line = $line;
            next;
        } elsif ($old_line && $line =~ /^\+/) {
            s/^\+//;
            $new_line = $line;
        } else {
            next;
        }

        my @old_words = split(/\W+/, $old_line);
        my @new_words = split(/\W+/, $new_line);
        my @new_cmds;

        my $i;
        my $diff_count = 0;
        for ($i = 0; ; $i++) {
            if (!defined($old_words[$i]) && !defined($new_words[$i])) {
                last;
            }
            if (!defined($old_words[$i]) || !defined($new_words[$i])) {
                $diff_count = 1000;
                last;
            }
            if ($old_words[$i] eq $new_words[$i]) {
                next;
            }
            if ($c_keywords{$old_words[$i]}) {
                $diff_count = 1000;
                last;
            }
            if ($new_words{$old_words[$i]}) {
                $diff_count++;
            }
            push @new_cmds, [$old_words[$i], $new_words[$i]];
        }
        if ($diff_count <= 2) {
            foreach my $sub (@new_cmds) {
                if ($added_cmds{$sub->[0] . $sub->[1]}) {
                    next;
                }
                $added_cmds{$sub->[0] . $sub->[1]} = 1;
                push @new_subs, [$sub->[0] , $sub->[1]];
            }
        }

        $old_line = 0;
    }

    if (@new_subs) {
        print "RENAMES:\n";
        foreach my $sub (@new_subs) {
            print "$sub->[0] => $sub->[1]\n";
            push @strict_subs, [$sub->[0] , $sub->[1]];
        }
        print "---\n";
    }
}

my $output;

#recreate an old file and a new file
my $inside = 0;
foreach (@input) {
    if ($pull_context && !($_ =~ /^[+-@]/)) {
        next;
    }

    if ($_ =~ /^(---|\+\+\+)/) {
        next;
    }

    if ($_ =~ /^@/) {
        $inside = 1;
    }
    if ($inside && !(($_ =~ /^[- @+]/) || ($_ =~ /^$/))) {
        $inside = 0;
    }
    if (!$inside) {
        next;
    }

    $output = filter($_);

    if ($strip_braces && $_ =~ /^(\+|-)\W+{/) {
        $output =~ s/^[\t ]+(.*)/ $1/;
    } else {
        $output = "\n" . $output;
    }

    if ($_ =~ /^-/) {
        print $oldfh $output;
        next;
    }
    if ($_ =~ /^\+/) {
        print $newfh $output;
        next;
    }
    print $oldfh $output;
    print $newfh $output;

}
print $oldfh "\n";
print $newfh "\n";
# git diff puts a -- and version at the end of the diff.  put the -- into the
# new file as well so it's ignored
if ($output =~ /\n-/) {
    print $newfh "-\n";
}

my $hunk;
my $old_txt;
my $new_txt;

open diff, "diff -uw $oldfile $newfile |";
while (<diff>) {
    if ($_ =~ /^(---|\+\+\+)/) {
        next;
    }

    if ($_ =~ /^@/) {

        if ($strip_comments) {
            $old_txt =~ s/\/\*.*?\*\///g;
            $new_txt =~ s/\/\*.*?\*\///g;
        }
        if ($strip_braces) {
            $old_txt =~ s/{([^;{]*?);}/$1;/g;
            $new_txt =~ s/{([^;{]*?);}/$1;/g;
            # this is a hack because i don't know how to replace nested
            # unneeded curly braces.
            $old_txt =~ s/{([^;{]*?);}/$1;/g;
            $new_txt =~ s/{([^;{]*?);}/$1;/g;
        }

        if ($old_txt ne $new_txt) {
            print $hunk;
            print $_;
        }
        $hunk = "";
        $old_txt = "";
        $new_txt = "";
        next;
    }

    $hunk = $hunk . $_;

    if ($strip_slashes) {
        s/\\$//;
    }

    if ($_ =~ /^-/) {
        s/-//;
        s/[ \t\n]//g;
        $old_txt = $old_txt . $_;
        next;
    }
    if ($_ =~ /^\+/) {
        s/\+//;
        s/[ \t\n]//g;
        $new_txt = $new_txt . $_;
        next;
    }
    if ($_ =~ /^ /) {
        s/^ //;
        s/[ \t\n]//g;
        $old_txt = $old_txt . $_;
        $new_txt = $new_txt . $_;
    }
}

if ($old_txt ne $new_txt) {
    if ($strip_comments) {
        $old_txt =~ s/\/\*.*?\*\///g;
        $new_txt =~ s/\/\*.*?\*\///g;
    }
    if ($strip_braces) {
        $old_txt =~ s/{([^;{]*?);}/$1;/g;
        $new_txt =~ s/{([^;{]*?);}/$1;/g;
        $old_txt =~ s/{([^;{]*?);}/$1;/g;
        $new_txt =~ s/{([^;{]*?);}/$1;/g;
    }

    print $hunk;
}

unlink($oldfile);
unlink($newfile);

print "\ndone.\n";
