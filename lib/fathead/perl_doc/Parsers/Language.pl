#!/usr/bin/env perl
use strict;
use warnings;
binmode STDOUT, ":utf8";
use IO::All;
use Mojo::DOM;
use Data::Dumper;
use Term::ProgressBar;
use Cwd qw( getcwd );
#use Utils qw( write_row );

my @pages = glob(getcwd(). "/../download/language/*.html");

foreach my $page (@pages){
    my $html < io($page);

    my $dom = Mojo::DOM->new($html);

    my $title = $dom->at('title')->text;
    $title =~ s/\s-\s.*//;
    warn Dumper $title;

    # iterate through page
    my $nodes = $dom->find('p, h1')->map('text');
    my $headings = $dom->find('a[name]')->map(attr => 'name');
    $_ =~ s/-/ /g for @$headings;

    my $capture = 0;
    my $description;
    foreach my $n (@{$nodes}){
        if($n eq "DESCRIPTION"){
            $capture = 1;
            next;
        }

        last if ($capture && grep $_ eq $n, @$headings);

        $description .= $n if $capture;

    }

    # trim description
    my @desc = split /\s/, $description;

    my @final_desc;
    if(scalar @desc >= 250){
        @final_desc = splice(@desc, 0, 249);

        foreach my $word (@final_desc){
            my $last;
            if($word =~ /\.$|\?$|\!$/){
                $last = 1;
            }
            push @final_desc, $word;
            last if $last;
        }
    }
    else{
        @final_desc = @desc;
    }

    my $abs = join ' ', @final_desc;

    warn $abs;
}