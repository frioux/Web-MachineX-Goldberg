package Web::MachineX::TraitFor::Resource::Rethrow;

use Moo::Role;

sub finish_request { die $_[1]->{exception} if $_[1]->{exception} }

1;
