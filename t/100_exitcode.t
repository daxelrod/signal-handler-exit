#!perl
use strict;
use warnings;

use Signal::Handler::Exit;
use Test::More;

#From perlvar:
sub ret {my $v = shift; $v >> 8;}
sub core {my $v = shift; $v &= 128; $v ? 1 : 0} #Have to force conversion to boolean, since is() doesn't use boolean context
sub sig_num {my $v =shift; $v & 127;}

my $test_value_count = 3;
sub test_value{
  my ($value, $ret, $core, $sig_num) = @_;
  is(ret($value), $ret, "ret for $value");
  is(core($value), $core, "core for $value");
  is(sig_num($value), $sig_num, "sig_num for $value");
}

my $test_roundtrip_count = 1;
sub test_roundtrip{
  my $value = shift;
  is(
    Signal::Handler::Exit::exitcode(
      ret($value),
      core($value),
      sig_num($value),
    ),
    $value,
    "roundtrip for $value"
  );
}

my @manual_values = (
  #value, ret, core, sig_num
  [130, 0, 1, 2], #SIGINT
  [143, 0, 1, 15], #SIGTERM
  [131, 0, 1, 3], #SIGQUIT
);

plan tests =>
  $test_value_count * @manual_values +
  $test_roundtrip_count * @manual_values
;

foreach (@manual_values) {
  test_value(@$_);
}

foreach (@manual_values) {
  test_roundtrip($_->[0]);
}
