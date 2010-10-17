#!perl
use strict;
use warnings;

use Signal::Handler::Exit;
use Test::More;

sub ret{Signal::Handler::Exit::ret(@_);}
sub core{Signal::Handler::Exit::core(@_);}
sub sig_num{Signal::Handler::Exit::sig_num(@_);}

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
    Signal::Handler::Exit::exit_code(
      ret($value),
      core($value),
      sig_num($value),
    ),
    $value,
    "roundtrip for $value"
  );
}

my $standalone_tests = 1;

my @manual_values = (
  #value, ret, core, sig_num
  [130, 0, 1, 2], #SIGINT
  [143, 0, 1, 15], #SIGTERM
  [131, 0, 1, 3], #SIGQUIT
);

plan tests =>
  $test_value_count * @manual_values +
  $test_roundtrip_count * @manual_values +
  $standalone_tests
;

foreach (@manual_values) {
  test_value(@$_);
}

is(
  Signal::Handler::Exit::exit_code(12,0,127),
  Signal::Handler::Exit::exit_code(12,0,127+128),
  "Truncate sig_num to 7 bits"
);

foreach (@manual_values) {
  test_roundtrip($_->[0]);
}


