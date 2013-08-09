package Web::MachineX::TraitFor::Resource::DBIC::ResultSet;

use Moo::Role;

requires '_render_item';

has _resultset => (
   is => 'ro',
   required => 1,
   init_arg => 'resultset',
);

has _writable => (
   is => 'ro',
   init_arg => 'writable',
);

sub _post_redirect_template { $_[0]->request->request_uri . 'data/%i' }

sub _post_redirect {
   sprintf $_[0]->_post_redirect_template,
      map $_[1]->get_column($_),
         $_[1]->result_source->primary_columns
}

sub _redirect_to_new_resource {
   $_[0]->response->header(
      Location => $_[0]->_post_redirect($_[1])
   );
}

sub _create_resource { $_[0]->resultset->create($_[1]) }

sub allowed_methods {
   [
      qw(GET HEAD),
      ( $_[0]->writable ) ? (qw(POST)) : ()
   ]
}

sub post_is_create { 1 }

sub create_path { "worthless" }

1;

__END__

sub content_types_provided { [ {'application/json' => '_to_json'} ] }
sub content_types_accepted { [ {'application/json' => '_from_json'} ] }

sub _to_json {
   my @data = $_[0]->_resultset->all;
   $_[0]->_encode_json({
      data => [ map $_[0]->_render_item($_), @data ],
      total => scalar @data,
   })
}

sub _from_json {
   my $obj = $_[0]->_create_resource(
      $_[0]->_decode_json(
         $_[0]->request->content
      )
   );

   $_[0]->_redirect_to_new_resource($obj);
}

