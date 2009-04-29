package MooseX::Runnable::Util::ArgParser;
use Moose;
use MooseX::Types::Moose qw(HashRef ArrayRef Str Bool);
use MooseX::Types::Path::Class qw(Dir);
use List::MoreUtils qw(first_index);

use namespace::autoclean -also => ['_look_for_dash_something', '_delete_first'];

has 'argv' => (
    is         => 'ro',
    isa        => ArrayRef,
    required   => 1,
    auto_deref => 1,
);

has 'class_name' => (
    is         => 'ro',
    isa        => Str,
    lazy_build => 1,
);

has 'modules' => (
    is         => 'ro',
    isa        => ArrayRef[Str],
    lazy_build => 1,
    auto_deref => 1,
);

has 'include_paths' => (
    is         => 'ro',
    isa        => ArrayRef[Dir],
    lazy_build => 1,
    auto_deref => 1,
);

has 'plugins' => (
    is         => 'ro',
    isa        => HashRef[ArrayRef[Str]],
    lazy_build => 1,
);

has 'app_args' => (
    is         => 'ro',
    isa        => ArrayRef[Str],
    lazy_build => 1,
    auto_deref => 1,
);

has 'is_help' => (
    is       => 'ro',
    isa      => Bool,
    lazy_build => 1,
);


sub _build_class_name {
    my $self = shift;
    my @args = $self->argv;

    my $next_is_it = 0;
    my $need_dash_dash = 0;

  ARG:
    for my $arg (@args) {
        if($next_is_it){
            return $arg;
        }

        if($arg eq '--'){
            $next_is_it = 1;
            next ARG;
        }

        next ARG if $arg =~ /^-[A-Za-z]/;

        if($arg =~ /^[+]/){
            $need_dash_dash = 1;
            next ARG;
        }

        return $arg unless $need_dash_dash;
    }

    if($next_is_it){
        confess 'Parse error: expecting ClassName, got EOF';
    }
    if($need_dash_dash){
        confess 'Parse error: expecting --, got EOF';
    }

    confess "Parse error: looking for ClassName, but can't find it; perhaps you meant '--help' ?";
}

sub _look_for_dash_something($@) {
    my ($something, @args) = @_;
    my @result;

    my $rx = qr/^-$something(.*)$/;
  ARG:
    for my $arg (@args) {
        last ARG if $arg eq '--';
        last ARG unless $arg =~ /^-/;
        if($arg =~ /$rx/){
            push @result, $1;
        }
    }

    return @result;
}

sub _build_modules {
    my $self = shift;
    my @args = $self->argv;
    return [ _look_for_dash_something 'M', @args ];
}

sub _build_include_paths {
    my $self = shift;
    my @args = $self->argv;
    return [ map { Path::Class::dir($_) } _look_for_dash_something 'I', @args ];
}

sub _build_is_help {
    my $self = shift;
    my @args = $self->argv;
    return
      (_look_for_dash_something 'h', @args) ||
      (_look_for_dash_something '\\?', @args) ||
      (_look_for_dash_something '-help', @args) ;;
}

sub _build_plugins {
    my $self = shift;
    my @args = $self->argv;
    $self->class_name; # causes death when plugin syntax is wrong

    my %plugins;
    my @accumulator;
    my $in_plugin = undef;

  ARG:
    for my $arg (@args) {
        if(defined $in_plugin){
            if($arg eq '--'){
                $plugins{$in_plugin} = [@accumulator];
                @accumulator = ();
                return \%plugins;
            }
            elsif($arg =~ /^[+](.+)$/){
                $plugins{$in_plugin} = [@accumulator];
                @accumulator = ();
                $in_plugin = $1;
                next ARG;
            }
            else {
                push @accumulator, $arg;
            }
        }
        else { # once we are $in_plugin, we can never be out again
            if($arg eq '--'){
                return {};
            }
            elsif($arg =~ /^[+](.+)$/){
                $in_plugin = $1;
                next ARG;
            }
        }
    }

    if($in_plugin){
        confess "Parse error: expecting arguments for plugin $in_plugin, but got EOF. ".
          "Perhaps you forgot '--' ?";
    }

    return {};
}

sub _delete_first($\@) {
    my ($to_delete, $list) = @_;
    my $idx = first_index { $_ eq $to_delete } @$list;
    splice @$list, $idx, 1;
    return;
}

# this is a dumb way to do it, but i forgot about it until just now,
# and don't want to rewrite the whole class ;) ;)
sub _build_app_args {
    my $self = shift;
    my @args = $self->argv;

    return [] if $self->is_help; # LIES!!11!, but who cares

    # functional programmers may wish to avert their eyes
    _delete_first $_, @args for map { "-M$_" } $self->modules;
    _delete_first $_, @args for map { "-I$_" } $self->include_paths;

    my %plugins = %{ $self->plugins };

  PLUGIN:
    for my $p (keys %plugins){
        my $vl = scalar @{ $plugins{$p} };
        my $idx = first_index { $_ eq "+$p" } @args;
        next PLUGIN if $idx == -1; # HORRIBLE API!

        splice @args, $idx, $vl + 1;
    }

    if($args[0] eq '--'){
        shift @args;
    }

    if($args[0] eq $self->class_name){
        shift @args;
    }
    else {
        confess 'Parse error: Some residual crud was found before the app name: '.
          join ', ', @args;
    }

    return [@args];
}

1;

__END__

=head1 NAME

MooseX::Runnable::Util::ArgParser - parse @ARGV for mx-run

=head1 SYNOPSIS

    my $parser = MooseX::Runnable::Util::ArgParser->new(
        argv => \@ARGV,
    );

    $parser->class_name;
    $parser->modules;
    $parser->include_paths;
    $parser->plugins;
    $parser->is_help;
    $parser->app_args;

