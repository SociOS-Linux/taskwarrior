#! /usr/bin/perl
################################################################################
## taskwarrior - a command line task list manager.
##
## Copyright 2006 - 2011, Paul Beckingham, Federico Hernandez.
## All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the
##
##     Free Software Foundation, Inc.,
##     51 Franklin Street, Fifth Floor,
##     Boston, MA
##     02110-1301
##     USA
##
################################################################################

use strict;
use warnings;
use Test::More tests => 18;

# Create the rc file.
if (open my $fh, '>', 'op.rc')
{
  print $fh "data.location=.\n",
            "confirmation=no\n";
  close $fh;
  ok (-r 'op.rc', 'Created op.rc');
}

# Setup: Add a task
qx{../src/task rc:op.rc add one   project:A priority:H};
qx{../src/task rc:op.rc add two   project:A           };
qx{../src/task rc:op.rc add three           priority:H};
qx{../src/task rc:op.rc add four                      };

# Test the 'xor' operator.
my $output = qx{../src/task rc:op.rc ls project:A xor priority:H};
unlike ($output, qr/one/,   'ls project:A priority:H --> !one');
like   ($output, qr/two/,   'ls project:A priority:H --> two');
like   ($output, qr/three/, 'ls project:A priority:H --> three');
unlike ($output, qr/four/,  'ls project:A priority:H --> !four');

$output = qx{../src/task rc:op.rc ls project:A xor priority=H};
unlike ($output, qr/one/,   'ls project:A priority=H --> !one');
like   ($output, qr/two/,   'ls project:A priority=H --> two');
like   ($output, qr/three/, 'ls project:A priority=H --> three');
unlike ($output, qr/four/,  'ls project:A priority=H --> !four');

$output = qx{../src/task rc:op.rc ls project=A xor priority:H};
unlike ($output, qr/one/,   'ls project=A priority:H --> !one');
like   ($output, qr/two/,   'ls project=A priority:H --> two');
like   ($output, qr/three/, 'ls project=A priority:H --> three');
unlike ($output, qr/four/,  'ls project=A priority:H --> !four');

$output = qx{../src/task rc:op.rc ls project=A xor priority=H};
unlike ($output, qr/one/,   'ls project=A priority=H --> !one');
like   ($output, qr/two/,   'ls project=A priority=H --> two');
like   ($output, qr/three/, 'ls project=A priority=H --> three');
unlike ($output, qr/four/,  'ls project=A priority=H --> !four');

# Cleanup.
unlink qw(pending.data completed.data undo.data backlog.data synch.key op.rc);
ok (! -r 'pending.data'   &&
    ! -r 'completed.data' &&
    ! -r 'undo.data'      &&
    ! -r 'backlog.data'   &&
    ! -r 'synch.key'      &&
    ! -r 'op.rc', 'Cleanup');

exit 0;

