use strict;
use warnings;
package Signal::Handler::Exit;
# ABSTRACT: signal handlers that exit with correct status


=sub status_for_sig_num SIG_NUM

Returns the numeric exit status for the signal with number SIG_NUM.

=cut

=sub exitcode RETURN_CODE, CORE_DUMP, SIG_NUM

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
sub exitcode {
  my ($ret, $core, $sig_num) = @_;
  return ( ($ret << 8) | ($core ? 128 : 0) | ($sig_num & 127) );
}

1;
