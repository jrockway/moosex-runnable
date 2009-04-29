package MooseX::Runnable::Invocation::Plugin::Debug;
use Moose::Role;

# this is an example to cargo-cult, rather than a useful feature :)
has 'debug_prefix' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { "" },
);

sub _build_initargs_from_cmdline {
    my ($class, @args) = @_;
    confess 'Bad args passed to Debug plugin'
      unless @args % 2 == 0;

    my %args = @args;

    if(my $p = $args{'--prefix'}){
        return { debug_prefix => $p };
    }
    return;
}

for my $method (qw{
    load_class apply_scheme validate_class
    create_instance start_application
  }){
    requires $method;

    before $method => sub {
        my ($self, @args) = @_;
        my $args = join ', ', @args;
        print $self->debug_prefix, "Calling $method($args)\n";
    };

    after $method => sub {
        my $self = shift;
        print $self->debug_prefix, "Returning from $method\n";
    };
}

1;
