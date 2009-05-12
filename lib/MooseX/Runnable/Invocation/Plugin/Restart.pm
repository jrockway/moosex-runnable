package MooseX::Runnable::Invocation::Plugin::Restart;
use Moose::Role;
use MooseX::Types::Moose qw(Str);
use AnyEvent;
use namespace::autoclean;

with 'MooseX::Runnable::Invocation::Plugin::Restart::Base';

has 'completion_condvar' => (
    is       => 'ro',
    isa      => 'AnyEvent::CondVar',
    required => 1,
    default  => sub { AnyEvent->condvar },
);

has 'kill_signal' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    default  => sub { 'INT' },
);

has 'restart_signal' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    default  => sub { 'HUP' },
);

after '_restart_parent_setup' => sub {
    my $self = shift;

    my ($kw, $rw);
    $kw = AnyEvent->signal( signal => $self->kill_signal, cb => sub {
        $self->kill_child;
        undef $kw;
        $self->completion_condvar->send(0); # parent exit code
    });

    $rw = AnyEvent->signal( signal => $self->restart_signal, cb => sub {
        $rw = $rw; # closes over $rw and prevents it from being GC'd
        $self->restart;
    });
};

sub run_parent_loop {
    my $self = shift;
    print {*STDERR} "Control pid is $$\n";
    return $self->completion_condvar->wait;
}

1;
