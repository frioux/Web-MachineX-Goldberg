package Web::MachineX::TraitFor::Resource::DBIC::ResultSet;

use Moo::Role;

requires '_x_render_item';

has _x_resultset => (
   is => 'ro',
   required => 1,
   init_arg => 'resultset',
   handles => {
      _x_all_results => 'all',
   },
);

has _x_writable => (
   is => 'ro',
   init_arg => 'writable',
);

sub _x_post_redirect_template { $_[0]->request->request_uri . 'data/%i' }

sub _x_post_redirect {
   sprintf $_[0]->_x_post_redirect_template,
      map $_[1]->get_column($_),
         $_[1]->result_source->primary_columns
}

sub _x_redirect_to_new_resource {
   $_[0]->response->header(
      Location => $_[0]->_x_post_redirect($_[1])
   );
}

sub _x_create_resource { $_[0]->resultset->create($_[1]) }

sub allowed_methods {
   [
      qw(GET HEAD),
      ( $_[0]->_x_writable ) ? (qw(POST)) : ()
   ]
}

sub post_is_create { 1 }

sub create_path { "worthless" }

sub _x_render_resultset {
   my @data = $_[0]->_x_all_results;
   return +{
      data => [ map $_[0]->_x_render_item($_), @data ],
      total => scalar @data,
   },
}

1;

__END__

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

