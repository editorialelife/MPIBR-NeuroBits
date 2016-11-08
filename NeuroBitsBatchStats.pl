#!/usr/bin/perl

use warnings;
use strict;

sub ParseNeuroTreeFile($$);
sub ParsePunctaStatsFile($$);
sub PrintCustomTable($);
sub PolygonArea($$$);

my $path_name = shift;
my %hash = ();

# get list of file names
my @neuroTreeFiles = glob("$path_name/*_neuroTree_*.txt");
my @punctaStatsFiles = glob("$path_name/punctaStats*.txt");

# loop through list
foreach my $ntFile (@neuroTreeFiles)
{
    my $name = $ntFile =~ m/$path_name\/?(.*)\_neuroTree\_.*.txt/ ? $1 : "<unknown>";
    my @tmp = grep {/\_$name\_/} @punctaStatsFiles;
    my $psFile = $tmp[0];
    
    ParseNeuroTreeFile($ntFile, \%{$hash{$name}});
    ParsePunctaStatsFile($psFile, \%{$hash{$name}});
}
PrintCustomTable(\%hash);



### sub-routines
sub ParseNeuroTreeFile($$)
{
    my $file = $_[0];
    my $hash_ref = $_[1];
    
    my $record = "";
    open(my $fh, "<", $file) or die $!;
    while (<$fh>)
    {
        $record .= $_;
        
        if ($_ =~ m/^\s$/)
        {
            # parse header
            if ($record =~ m/^file_path/)
            {
                my $name = $record =~ m/file_name=([^\s.]*)/ ? $1 : "<unknown>";
                
                $hash_ref->{"name"} = $name;
            }
            
            
            # parse record
            if ($record =~ m/^branch/)
            {
                my $depth = $record =~ m/depth=([0-9]+)/ ? $1 : -1;
                my $span = $record =~ m/span=([0-9\.]+)/ ? $1 : -1;
                
                if ($depth == 0)
                {
                    my $x_list = $record =~ m/x=([0-9\,\.]+)/ ? $1 : -1;
                    my @x_array = split(",", $x_list);
                    push(@x_array,$x_array[0]);
                    
                    my $y_list = $record =~ m/y=([0-9\,\.]+)/ ? $1 : -1;
                    my @y_array = split(",", $y_list);
                    push(@y_array, $y_array[0]);
                    
                    my $nodes = $record =~ m/nodes=([0-9]+)/ ? $1 : 0;
                    
                    my $area = PolygonArea(\@x_array, \@y_array, $nodes + 1);
                    
                    $hash_ref->{"span"}{$depth} = $area;
                    
                }
                elsif ($depth > 0)
                {
                    $hash_ref->{"span"}{$depth} = exists($hash_ref->{"span"}{$depth}) ? $hash_ref->{"span"}{$depth} + $span : $span;
                }
            }
            
            $record = "";
            
        }
        
        
    }
    close($fh);
    
}

sub ParsePunctaStatsFile($$)
{
    my $file = $_[0];
    my $hash_ref = $_[1];
    
    open(my $fh, "<", $file) or die $!;
    while (<$fh>)
    {
        next if($_ =~ m/^#/);
        
            chomp($_);
        
        my @line = split("\t", $_);
        
        my $depth = $line[2];
        
        $hash_ref->{"puncta"}{$depth} = exists($hash_ref->{"puncta"}{$depth}) ? $hash_ref->{"puncta"}{$depth} + 1 : 1;
    }
    close($fh);
}

sub PrintCustomTable($)
{
    my $hash_ref = $_[0];
    
    
    # print header
    print "#file\tSoma.Area\tSoma.Puncta";
    for (my $k = 1; $k < 10; $k++)
    {
        print "\tOrder.$k.Span\tOrder.$k.Puncta";
    }
    print "\tArbor.Span\tArbor.Puncta";
    print "\n";
    
    # print data
    foreach my $file (keys %{$hash_ref})
    {
        print $hash_ref->{$file}{"name"},"\t";
        
        my $arbor_span = 0;
        my $puncta_count = 0;
        for (my $depth = 0; $depth < 10; $depth++)
        {
            my $span = exists($hash_ref->{$file}{"span"}{$depth}) ? $hash_ref->{$file}{"span"}{$depth} : 0;
            $arbor_span += $span if($depth > 0);
            
            my $count = exists($hash_ref->{$file}{"puncta"}{$depth}) ? $hash_ref->{$file}{"puncta"}{$depth} : 0;
            $puncta_count += $count if($depth > 0);
            
            print $span,"\t",$count,"\t";
        }
        print $arbor_span,"\t",$puncta_count;
        
        print "\n";
        
    }
    
}


sub PolygonArea($$$)
{
    my $X = $_[0];
    my $Y = $_[1];
    my $points = $_[2];
    
    my $area = 0.0;
    my $j = $points - 1;
    
    for(my $i = 0; $i < $points; $i++)
    {
        $area += ($X->[$j] + $X->[$i]) * ($Y->[$j] - $Y->[$i]);
        $j = $i;
    }
    
    return abs($area * 0.5);
}

