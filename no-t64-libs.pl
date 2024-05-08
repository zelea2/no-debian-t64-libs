#!/usr/bin/perl 
# no-t64.pl

foreach my $deb ( <STDIN> )
{
  chomp( $deb );
  next if( $deb !~ /\.deb/ );
  next if( !repack( $deb ) );
  $deb =~ s/.*\///;
  print "$deb -> repacked\n";
}
exit;

sub repack
{
  my $deb = shift;
  mkdir "x";
  `dpkg -e $deb x/DEBIAN`; # expand package control files
  my $modified = 0;
  foreach my $file ( "control", "preinst", "postinst", "prerm", "postrm", "shlibs" )
  {
    $modified += replace( $file );
  }
  if( $modified )
  {
    `dpkg -x $deb x`; # expand the content of the package
    `dpkg -b x $deb`; # rebuild the package
  }
  `rm -rf x`;
  return $modified;
}

sub replace
{
  my $f = "x/DEBIAN/" . shift;
  open( IFILE, $f )         || return 0;
  open( OFILE, "> $f.tmp" ) || die "create $f.tmp - $!\n";
  while( <IFILE> )
  {
    $_ =~ s/(\s+lib\S+)t64/$1/g;
    print OFILE $_;
  }
  close( OFILE );
  close( IFILE );
  my ( $dev, $ino, $omode, $nlink, $uid, $gid, $rdev, $osize ) = stat( "$f" );
  my ( $dev, $ino, $nmode, $nlink, $uid, $gid, $rdev, $nsize ) =
      stat( "$f.tmp" );
  if( $osize == $nsize )
  {
    unlink "$f.tmp";
    return 0;
  }
  unlink "$f";
  rename "$f.tmp", "$f";
  chmod( $omode & 07777, "$f" );
  return 1;
}
