package MooseX::Runnable::Invocation::Plugin::Restart::Auto;
use Moose::Role;
use MooseX::Types;
use MooseX::Types::Moose qw(ArrayRef RegexpRef Any Str);
use MooseX::Types::Path::Class qw(Dir);
use File::ChangeNotify;
use namespace::autoclean;

# coerce ArrayRef[Dir], from ArrayRef[Any], via {[
#     map { warn $_; Path::Class::dir($_) } @$_,
# ]};

coerce RegexpRef, from Str, via { qr/$_/i };


with 'MooseX::Runnable::Invocation::Plugin::Restart::Base',
  'MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs';

has 'watch_regexp' => (
    is       => 'ro',
    isa      => RegexpRef,
    required => 1,
    coerce   => 1,
    default  => sub { qr/^[^.].+[.]pmc?$/i },
);

has 'watch_directories' => (
    is       => 'ro',
    isa      => ArrayRef[Dir],
    required => 1,
    coerce   => 1,
    default  => sub { [Path::Class::dir('.')] },
);

has 'watcher' => (
    is         => 'ro',
    isa        => 'File::ChangeNotify::Watcher',
    lazy_build => 1,
);

sub _build_initargs_from_cmdline {
    my ($self, @args) = @_;

    my $regexp;
    my @dirs;
    my $next_type;
    for my $arg (@args){
        # if($arg eq '--inc'){
        #     push @dirs, @INC;
        # }
        if($arg eq '--dir'){
            $next_type = 'dir';
        }
        elsif($arg eq '--regexp' || $arg eq '--regex'){
            # i call them regexps, other people call them "regexen" :P
            $next_type = 'regexp';
        }
        elsif($next_type eq 'dir'){
            push @dirs, $arg;
        }
        elsif($next_type eq 'regexp'){
            $regexp = $arg;
        }
        else {
            confess 'Invalid args passed to Restart::Auto';
        }
    }
    my %result;
    $result{watch_directories} = [map { Path::Class::dir($_) } @dirs] if @dirs;
    $result{watch_regexp} = $regexp if $regexp;
    return \%result;
}

sub _build_watcher {
    my $self = shift;
    my $w = File::ChangeNotify->instantiate_watcher(
        directories => [map { $_->stringify } @{$self->watch_directories}],
        filter      => $self->watch_regexp,
    );

    return $w;
}

sub run_parent_loop {
    my $self = shift;
    while(1){
        my @events = $self->watcher->wait_for_events();
        $self->restart;
    }
}

1;
