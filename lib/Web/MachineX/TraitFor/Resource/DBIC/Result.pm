package Web::MacineX::TraitFor::Resource::DBIC::Result;

use Moo::Role;

requires '_render_item';

has _item => (
   is => 'ro',
   required => 1,
   init_arg => 'item',
   handles => {
      delete_resource => 'delete',
      _update_resource => 'update',
   },
);

has _writable => (
   is => 'ro',
   init_arg => 'writable',
);

sub resource_exists { !! $_[0]->_item }

sub allowed_methods {
   [
      qw(GET HEAD),
      $_[0]->_writable ? (qw(PUT DELETE)) : ()
   ]
}

1;

__END__

sub content_types_provided { [ {'application/json' => '_to_json'} ] }
sub content_types_accepted { [ {'application/json' => '_from_json'} ] }

sub _to_json { $_[0]->_encode_json($_[0]->_render_item($_[0]->_item)) }

sub _from_json {
   $_[0]->_update_resource(
      $_[0]->_decode_json(
         $_[0]->request->content
      )
   )
}

