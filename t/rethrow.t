use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use Web::Machine;

my $a = Web::Machine->new( resource => 'A' )->to_app;
test_psgi $a, sub {
   my $cb  = shift;
   my $res = $cb->(GET '/');
   like $res->content, qr/foo/, 'exception propagates';
};

my $b = Web::Machine->new( resource => 'B' )->to_app;
test_psgi $b, sub {
   my $cb  = shift;
   my $res = $cb->(GET '/');
   is $res->content, '', 'exception gets eaten';
};

done_testing;

BEGIN {
   package A;
   use Moo;
   extends 'Web::Machine::Resource';
   with 'Web::MachineX::TraitFor::Resource::Rethrow';
   sub content_types_provided { [{ 'text/html' => 'to_html' }] }
   sub to_html { die 'foo' }
}
BEGIN {
   package B;
   use base 'Web::Machine::Resource';
   sub content_types_provided { [{ 'text/html' => 'to_html' }] }
   sub to_html { die 'foo' }
}
