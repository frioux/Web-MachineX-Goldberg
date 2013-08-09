package Web::MacineX::TraitFor::Resource::DBIC::Result;

use Moo::Role;

requires '_x_render_item';

has _x_item => (
   is => 'ro',
   required => 1,
   init_arg => 'item',
   handles => {
      delete_resource => 'delete',
      _x_update_resource => 'update',
   },
);

has _x_writable => (
   is => 'ro',
   init_arg => 'writable',
);

sub resource_exists { !! $_[0]->_x_item }

sub allowed_methods {
   [
      qw(GET HEAD),
      $_[0]->_x_writable ? (qw(PUT DELETE)) : ()
   ]
}

1;

__END__

sub content_types_provided { [ {'application/json' => '_x_to_json'} ] }
sub content_types_accepted { [ {'application/json' => '_x_from_json'} ] }

sub _x_to_json { $_[0]->_x_encode_json($_[0]->_x_render_item($_[0]->_x_item)) }

sub _x_from_json {
   $_[0]->_x_update_resource(
      $_[0]->_x_decode_json(
         $_[0]->request->content
      )
   )
}

