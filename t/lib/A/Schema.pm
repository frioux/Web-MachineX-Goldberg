package A::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

sub connect {
   my $ret = shift->next::method('dbi:SQLite::memory:');

   $ret->storage->ensure_connected;

   $ret->storage->dbh->do(<<'SQL');
CREATE TABLE humans (
  id NOT NULL,
  name NOT NULL,
  PRIMARY KEY (id)
)
SQL

   $ret
}

__PACKAGE__->load_namespaces;

1;
