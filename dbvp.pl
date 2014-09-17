#!/usr/bin/perl -w

#---------------------------------------------------------------------
# dbvp (C) 2012 Gokhan Atil http://www.gokhanatil.com
#---------------------------------------------------------------------

use strict;
use POSIX;
use threads;

print "\ndbvp (C) 2012 Gokhan Atil http://www.gokhanatil.com \n\n";

($#ARGV == 1) or die "Usage: dbvp.pl <filename> <parallelism>\n\n";

my $filename = $ARGV[0];
my $number_of_threads = $ARGV[1];

open FILE, $filename or die "Couldn't open file: $!\n\n";
binmode FILE;

my $buffer = '';
read( FILE, $buffer, 100 );

my ($size) = unpack 'x24V', $buffer;
my ($blocks) = floor($size/$number_of_threads);

my $start = 1;
my $end = $blocks;

close FILE;

system( "rm /tmp/dbv3-*.log" );

sub dbv{ 
  system( @_ ); 
}


my @thr;

for (my $count = 1; $count <= $number_of_threads ; $count++) {
   if ($count < $number_of_threads) {
   $thr[$count] = threads->create('dbv',"dbv file=$filename logfile=/tmp/dbv3-$count.log start=$start end=$end 2>/dev/null"); $end += $blocks;  $start += $blocks;
   } else 
	{
   $thr[$count] = threads->create('dbv',"dbv file=$filename logfile=/tmp/dbv3-$count.log start=$start 2>/dev/null"); 
	}

}

for (my $count = 1; $count <= $number_of_threads ; $count++) {
   $thr[$count]->join();
}

my %log;

$log{'Highest block SCN'} = 0;

for (my $count = 1; $count <= $number_of_threads ; $count++) {

	open LOGFILE, "</tmp/dbv3-$count.log ";

	<LOGFILE> for 1 ..9; # skip first 9 lines

	while (<LOGFILE>) {
	    chomp;                  # no newline
	    s/^\s+//;               # no leading white
	    s/\s+$//;               # no trailing white
	    next unless length;     # anything left?
	    my ($var, $value) = split(/\s*:\s*/, $_, 2); 
            
	    if ($var eq 'Highest block SCN') {
 			$value =~ s/\(.*\)//; 

                if ($value > $log{$var}) { $log{$var} = $value };

	    }  else 
	    { $log{$var} += $value; }
	}

	close LOGFILE;

}

print "Total Pages Examined         : $log{'Total Pages Examined'} \n";
print "Total Pages Processed (Data) : $log{'Total Pages Processed (Data)'} \n";
print "Total Pages Failing   (Data) : $log{'Total Pages Failing   (Data)'} \n";
print "Total Pages Processed (Index): $log{'Total Pages Processed (Index)'} \n";
print "Total Pages Failing   (Index): $log{'Total Pages Failing   (Index)'} \n";
print "Total Pages Processed (Other): $log{'Total Pages Processed (Other)'} \n";
print "Total Pages Processed (Seg)  : $log{'Total Pages Processed (Seg)'} \n";
print "Total Pages Failing   (Seg)  : $log{'Total Pages Failing   (Seg)'} \n";
print "Total Pages Empty            : $log{'Total Pages Empty'} \n";
print "Total Pages Marked Corrupt   : $log{'Total Pages Marked Corrupt'} \n";
print "Total Pages Influx           : $log{'Total Pages Influx'} \n";
print "Total Pages Encrypted        : $log{'Total Pages Encrypted'} \n";
print "Highest block SCN            : $log{'Highest block SCN'} \n";

