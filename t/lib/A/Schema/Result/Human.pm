package A::Schema::Result::Human;

use DBIx::Class::Candy -autotable => v1;

primary_column id => {
   data_type => 'int',
   is_auto_increment => 1,
};

column 'name';

1;
