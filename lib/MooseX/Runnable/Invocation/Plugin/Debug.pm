package MooseX::Runnable::Invocation::Plugin::Debug;
use Moose::Role;

for my $method (qw{
    load_class apply_scheme validate_class
    create_instance start_application
  }){
    requires $method;

    before $method => sub {
        my ($self, @args) = @_;
        my $args = join ', ', @args;
        print "Calling $method($args)\n";
    };

    after $method => sub {
        print "Returning from $method\n";
    };
}

1;
