#!/usr/bin/perl 
# lists-t64.pl
#

die "This program must be run as root\n" if( $UID != 0 );
$dir = "/var/lib/apt/lists";
opendir( $dh, $dir );
@files = grep { /Packages$/ } readdir( $dh );
closedir $dh;
foreach my $pkg ( @files )
{
  print "$pkg\n";
  relist( $pkg );
}
#`rm -f /var/cache/apt/*.bin`;
`apt-cache -g pkgnames`;
exit;

sub relist
{
  my $pkg = shift;
  open( IFILE, "$dir/$pkg" )       || die "open $pkg - $!\n";
  open( OFILE, "> $dir/$pkg.new" ) || die "create $pkg.new - $!\n";
  while( <IFILE> )
  {
    $_ =~ s/lib(\S+)t64/lib$1/g if( $_ !~ /^Filename:/ );
    print OFILE $_;
  }
  close( OFILE );
  close( IFILE );
  unlink "$dir/$pkg";
  rename "$dir/$pkg.new", "$dir/$pkg";
}

