package Web::MachineX::SafeResource;

use Moo;

extends 'Web::Machine::Resource';

sub finish_request { die $_[1]->{exception} if $_[1]->{exception} }

1;
