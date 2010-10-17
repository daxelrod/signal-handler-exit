use strict;
use warnings;
package Signal::Handler::Exit;
# ABSTRACT: signal handlers that exit with correct status


=sub status_for_sig_num SIG_NUM

Returns the numeric exit status for the signal with number SIG_NUM.

=cut

=sub exit_code RETURN_CODE, CORE_DUMP, SIG_NUM

Synthesize an exit code of the type in C<$?> or returned by the unix C<wait> call.

Inspired by Linux and BSD's macro C<W_EXITCODE>.

The bits of the return value will be the following, where each letter corresponds to an argument to this sub:
  RRRRRRRRCSSSSSSS

=over

=item RETURN_CODE

L<perlvar>, in C<$?> calls this the real exit value of the process.
C<W_EXITCODE> calls it "C<ret>".

Note that no attempt is made to limit this value to 8 bits.

=item CORE_DUMP

Whether or not there was a core dump.

=item SIG_NUM

The signal that ended the process.
C<W_EXITCODE calls it "C<sig>".

Only the lowest 7 bits of this value will be used.

=back

=cut
sub exit_code {
  my ($ret, $core, $sig_num) = @_;
  return ( ($ret << 8) | ($core ? 128 : 0) | ($sig_num & 127) );
}

=sub ret, core, sig_num

Each of these take an exit code of the type returned by L</exit_code>,
or in C<$?> or returned by the unix C<wait> call.

They extract the RETURN_CODE, CORE_DUMP, and SIG_NUM respectively,
using the tests from the L<perlvar> section about c<$?>.
See L</exit_code> for more info on what each of these values mean.

Note that the following test will always be true:
  $value == exit_code(ret($value), core(value), sig_num($value);

Also note that C<core> will always return 1 or 0.
=cut
sub ret {my $v = shift; $v >> 8;}
sub core {my $v = shift; $v &= 128; $v ? 1 : 0;}
sub sig_num {my $v =shift; $v & 127;}



1;
