#!/usr/bin/perl -w

#---------------------------------------------------------------------
# dumpinfo (C) 2011 Gokhan Atil http://www.gokhanatil.com
#---------------------------------------------------------------------

use strict;

print "\ndumpinfo (C) 2011 Gokhan Atil http://www.gokhanatil.com \n\n";

($#ARGV == 0) or die "Usage: dumpinfo.pl filename\n\n";

open FILE, $ARGV[0] or die "Couldn't open file: $!\n\n";
binmode FILE;

my $buffer = '';
read( FILE, $buffer, 600 );

my ($magic1) = unpack 'x477C', $buffer;
my ($magic2) = unpack 'x3C', $buffer;

if ($magic1 == 49 ) {

my ($filevermajor,$filevermin) = unpack 'CC', $buffer;
my ($year,$mon,$day,$hour,$min,$sec) = unpack 'x41nCCCCC', $buffer;
my ($version) = unpack 'x476a14', $buffer;
my ($platform) = unpack 'x132A30', $buffer;
my ($charset) = unpack 'x294A20', $buffer;
my ($blocksize) = unpack 'x37n', $buffer;
my ($jobname) = unpack 'x66A40', $buffer;
my ($filevernum) = unpack 'n', $buffer;
my ($charsetID) = unpack 'x40C', $buffer;
my ($mastertablepos) = unpack 'x57C', $buffer;
my ($mastertablelen) = unpack 'x62N', $buffer;
my ($jguid) = unpack 'x15H32', $buffer;

print " ........Filetype = Datapump dumpfile\n"; 
print " ......DB Version = $version \n";
print " File Version Str = $filevermajor.$filevermin \n";
print " File Version Num = $filevernum \n";
print " ........Job Guid = $jguid \n";
print " Master Table Pos = $mastertablepos \n";
print " Master Table Len = $mastertablelen \n";
print " ......Charset ID = $charsetID \n";
print " ...Creation date = $mon-$day-$year $hour:$min:$sec \n";
print " ........Job Name = $jobname \n";
print " ........Platform = $platform \n";
print " ........Language = $charset \n";
print " .......Blocksize = $blocksize \n";

} elsif ($magic2 == 69  ) {

my ($charset ) = unpack 'x2C', $buffer;
my ($exportdate) = unpack 'x106a23', $buffer;
my ($exportver) = unpack 'x11a8', $buffer;

print " ........Filetype = Classic Export file\n"; 
print " ..Export Version = $exportver \n";
print " .....Direct Path = 0 (Conventional Path) \n";
print " .Characterset ID = $charset \n";
print " ...Creation date = $exportdate \n";


} elsif ($magic2 == 68 ) {

my ($charset ) = unpack 'x2C', $buffer;
my ($exportdate) = unpack 'x105a23', $buffer;
my ($exportver) = unpack 'x13a8', $buffer;

print " ........Filetype = Classic Export file\n"; 
print " ..Export Version = $exportver \n";
print " .....Direct Path = 1 (Direct Path) \n";
print " .Characterset ID = $charset \n";
print " ...Creation date = $exportdate \n";


} else {

print " ..........Error = Unsupported File \n";

}

print "\n";

close FILE
