package Web::MachineX::TraitFor::Resource::JsonEncoder;

use Moo::Role;

use Module::Runtime 'use_module';

has _json_encoder => (
   is => 'lazy',
   builder => sub { use_module('JSON')->new->convert_blessed->utf8 }
   handles => {
      encode_json => 'encode',
      decode_json => 'decode',
   },
);


1;

