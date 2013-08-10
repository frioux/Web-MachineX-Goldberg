use strict;
use warnings;

use Test::More;
use Test::Deep;

use JSON qw( encode_json decode_json );

ok my $a = A->new, 'instantiate';
is $a->_x_encode_json([1,2,3]), encode_json([1,2,3]), 'encode';
cmp_deeply $a->_x_decode_json('[1,2,3]'), decode_json('[1,2,3]'), 'decode';

done_testing;

BEGIN {
   package A;

   use Moo;

   with 'Web::MachineX::TraitFor::Resource::JsonEncoder';
}
