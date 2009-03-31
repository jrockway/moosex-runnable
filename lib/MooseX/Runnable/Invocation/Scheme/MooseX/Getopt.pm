package MooseX::Runnable::Invocation::Scheme::MooseX::Getopt;
use Moose::Role;

around validate_class => sub {
    return; # always valid
};

around create_instance => sub {
    my ($next, $self, $class, @args) = @_;

    local @ARGV = @args; # ugly!
    my $instance = $class->name->new_with_options();

    my $more_args = $instance->extra_argv;

    return ($instance, @$more_args);
};

1;
