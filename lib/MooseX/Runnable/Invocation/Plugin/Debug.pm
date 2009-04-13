package MooseX::Runnable::Invocation::Plugin::Debug;
use Moose::Role;
use Context::Preserve qw(preserve_context);

for my $method (qw/load_class apply_scheme validate_class create_instance start_application/){

    requires $method;

    before $method => sub {
        my ($self, @args);
        my $args = join ', ', @args;
        print "Calling $method($args)\n";
    };

    after $method => sub {
        my ($next, $self, @args) = @_;
        print "Returning from $method\n";
    };
}

1;
