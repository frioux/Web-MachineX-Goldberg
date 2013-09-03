use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use Web::Machine;

use lib 't/lib';
use A::Schema;
my $a = A::Schema->connect;

my $i = 1;
$a->resultset('Human')
  ->populate([[qw( id name )], map [$i++, $_], qw(frew frooh frioux)]);

my $d = D->new(schema => $a)->to_psgi_app;
test_psgi $d, sub {
   my $cb  = shift;
   my $res = $cb->(GET '/humans/');
   like $res->content, qr/Hello world!/, 'exception propagates';
   $res = $cb->(GET '/humans/data/1');
   like $res->content, qr/Hello world!/, 'exception propagates';
};

done_testing;

BEGIN {
   package D;
   use Web::Simple;

   has _schema => (
      is       => 'ro',
      required => 1,
      init_arg => 'schema',
   );

   sub dispatch_request {

      sub (/humans/...) {
         my $s = shift->_schema->resultset('Human');

         sub (/data/*) {
            Web::Machine->new(
               resource => 'R',
               resource_args => [
                  result => $s->find($_[1]),
                  writable => 1,
               ]
            )
         },
         sub (/) {
            Web::Machine->new(
               resource => 'S',
               resource_args => [
                  resultset => $s,
                  writable => 1,
               ]
            )
         },
      },
   }

   package R;
   use Moo;
   extends 'Web::Machine::Resource';
   with 'Web::MachineX::TraitFor::Resource::Rethrow',
        'Web::MachineX::TraitFor::Resource::JsonEncoder',
        'Web::MachineX::TraitFor::Resource::DBIC::Result';

   sub _x_render_item {
      return +{
         _id => $_[1]->id,
         name => $_[1]->name,
      }
   }
   sub content_types_provided { [ {'application/json' => '_x_to_json'} ] }
   sub content_types_accepted { [ {'application/json' => '_x_from_json'} ] }

   sub _x_to_json { $_[0]->_x_encode_json($_[0]->_x_render_item($_[0]->_x_result)) }

   sub _x_from_json {
      $_[0]->_x_update_resource(
         $_[0]->_x_decode_json(
            $_[0]->request->content
         )
      )
   }

   package S;
   use Moo;
   extends 'Web::Machine::Resource';
   with 'Web::MachineX::TraitFor::Resource::Rethrow',
        'Web::MachineX::TraitFor::Resource::JsonEncoder',
        'Web::MachineX::TraitFor::Resource::DBIC::ResultSet';

   sub _x_render_item {
      return +{
         _id => $_[1]->id,
         name => $_[1]->name,
      }
   }

   sub content_types_provided { [ {'application/json' => '_x_to_json'} ] }
   sub content_types_accepted { [ {'application/json' => '_x_from_json'} ] }

   sub _x_to_json { $_[0]->_x_encode_json($_[0]->_x_render_resultset) }

   sub _x_from_json {
      my $obj = $_[0]->_x_create_resource(
         $_[0]->_x_decode_json(
            $_[0]->request->content
         )
      );

      $_[0]->_x_redirect_to_new_resource($obj);
   }
}
