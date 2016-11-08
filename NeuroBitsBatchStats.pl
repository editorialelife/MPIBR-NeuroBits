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
    # extranct name for neuroTree file
    my $name = $ntFile =~ m/$path_name\/?(.*)\_neuroTree\_.*.txt/ ? $1 : "<unknown>";
    
    # find corresponding punctaStats file
    my $psFile = "<unknown>";
    my $nsQry = $name;
    $nsQry =~ s/[^A-Za-z0-9\_\-]//g;
    foreach my $psQry (@punctaStatsFiles)
    {
        my $tmp = $psQry;
        $tmp =~ s/$path_name\///;
        $tmp =~ s/\.txt//;
        $tmp =~ s/[^A-Za-z0-9\_\-]//g;
        
        $psFile = $psQry if($tmp =~ m/.*\_$name\_.*/);
    }
    
    # process files
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
        my $distance = $line[5];
        
        $hash_ref->{"puncta"}{$depth} = exists($hash_ref->{"puncta"}{$depth}) ? $hash_ref->{"puncta"}{$depth} + 1 : 1;
        push(@{$hash_ref->{"distance"}{$depth}}, $distance);
    }
    close($fh);
}

sub PrintCustomTable($)
{
    my $hash_ref = $_[0];
    
    # print header
    print "#file";
    print "\tDensity.Total"; # puncta.(arbor + soma)/ (span.arbor + area.soma)
    print "\tPuncta.Soma\tArea.Soma\tDensity.Soma"; # puncta.soma / area.soma
    print "\tPuncta.Arbor\tSpan.Arbor\tDensity.Arbor"; # puncta.arbor / span.arbor
    print "\tRatio.Puncta.(Arbor/Soma)"; # puncta.arbor / puncta.soma
    print "\tRatio.Area.(Arbor/Soma)"; # span.arbor / area.soma
    print "\tRatio.Density.(Arbor/Soma)"; # density.arbor / density.soma
    for (my $k = 1; $k < 10; $k++)
    {
        print "\tPuncta.Order.$k";
        print "\tSpan.Order.$k";
        print "\tDensity.Order.$k";
        print "\tPuncta.Previous.$k";
        print "\tDistance.$k";
    }
    print "\n";
    
    # print data
    foreach my $file (keys %{$hash_ref})
    {
        # file
        my $file_name = $hash_ref->{$file}{"name"};
        
        # soma
        my $area_soma = exists($hash_ref->{$file}{"span"}{0}) ? $hash_ref->{$file}{"span"}{0} : 0;
        my $puncta_soma = exists($hash_ref->{$file}{"puncta"}{0}) ? $hash_ref->{$file}{"puncta"}{0} : 0;
        my $density_soma = ($area_soma > 0) ? ($puncta_soma / $area_soma) : "NaN";
        
        # arbor
        my $span_arbor = 0;
        my $puncta_arbor = 0;
        my @span_branch_list = (0) x 9;
        my @puncta_branch_list = (0) x 9;
        my @density_branch_list = ("NaN") x 9;
        my @distance_branch_list = ();
        my @prev_puncta_list = (0) x 9;
        my $prev_puncta_arbor = $puncta_soma;
        
        for (my $depth = 1; $depth < 10; $depth++)
        {
            # current branch data
            my $span_branch = exists($hash_ref->{$file}{"span"}{$depth}) ? $hash_ref->{$file}{"span"}{$depth} : 0;
            my $puncta_branch = exists($hash_ref->{$file}{"puncta"}{$depth}) ? $hash_ref->{$file}{"puncta"}{$depth} : 0;
            my $density_branch = ($span_branch > 0) ? ($puncta_branch / $span_branch) : "NaN";
            
            for(my $i = $depth; $i < 10; $i++)
            {
                my @distance_branch = exists($hash_ref->{$file}{"distance"}{$i}) ? @{$hash_ref->{$file}{"distance"}{$i}} : ();
                push(@{$distance_branch_list[$depth - 1]}, @distance_branch);
            }
            
            
            # update lists
            $span_branch_list[$depth - 1] = $span_branch;
            $puncta_branch_list[$depth - 1] = $puncta_branch;
            $density_branch_list[$depth - 1] = $density_branch;
            
            # accumulate arbor span and puncta
            $span_arbor += $span_branch;
            $puncta_arbor += $puncta_branch;
            
        }
        
        my $density_arbor = ($span_arbor > 0) ? ($puncta_arbor / $span_arbor) : "NaN";
        my $ratio_density = ($density_soma eq "NaN" || $density_arbor eq "NaN" || $density_soma == 0) ? "NaN" : ($density_arbor / $density_soma);
        
        # output
        
        print $file_name;
        print "\t",($puncta_soma + $puncta_arbor)/($area_soma + $span_arbor); # puncta.(arbor + soma)/ (span.arbor + area.soma)
        print "\t",$puncta_soma,"\t",$area_soma,"\t",$density_soma; # puncta.soma / area.soma
        print "\t",$puncta_arbor,"\t",$span_arbor,"\t",$density_arbor; # puncta.arbor / span.arbor
        print "\t",$puncta_arbor / $puncta_soma; # puncta.arbor / puncta.soma
        print "\t",$span_arbor / $area_soma; # span.arbor / area.soma
        print "\t",$ratio_density; # density.arbor / density.soma
        for (my $k = 1; $k < 10; $k++)
        {
            print "\t",$puncta_branch_list[$k - 1];
            print "\t",$span_branch_list[$k - 1];
            print "\t",$density_branch_list[$k - 1];
            print "\t",scalar(@{$distance_branch_list[$k - 1]});
            print "\t",join(";", sort({$a <=> $b} @{$distance_branch_list[$k - 1]}));
        }
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

