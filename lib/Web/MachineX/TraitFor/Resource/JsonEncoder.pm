package Web::MachineX::TraitFor::Resource::JsonEncoder;

use Moo::Role;

use Module::Runtime 'use_module';

has _x_json_encoder => (
   is => 'lazy',
   builder => sub { use_module('JSON')->new->convert_blessed->utf8 },
   handles => {
      _x_encode_json => 'encode',
      _x_decode_json => 'decode',
   },
);


1;

