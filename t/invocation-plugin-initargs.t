use strict;
use warnings;
use Test::Exception;
use Test::More tests => 7;

use MooseX::Runnable::Invocation;

my $initargs;

{ package Class;
  use Moose;
  with 'MooseX::Runnable';
  sub run { 42 }
}

{ package Plugin;
  use Moose::Role;
  with 'MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs';

  has 'init' => ( is => 'ro', required => 1 );

  sub _build_initargs_from_cmdline {
      my $class = shift;
      $initargs = join ',', @_;
      return { init => 'args' };
  }
}

{ package Argless;
  use Moose::Role;
}

{ package Plugin2;
  use Moose::Role;
  with 'MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs';

  sub _build_initargs_from_cmdline {
      return { init => 'fails' };
  }
}

my $i;
lives_ok {
    $i = MooseX::Runnable::Invocation->new(
        class => 'Class',
        plugins => {
            '+Plugin' => [qw/foo bar baz/],
        },
    );
} 'created invocation without dying';

ok $i, 'created invocation ok';
ok $i->run, 'ran ok';
is $initargs, 'foo,bar,baz', 'got initargs';

throws_ok {
    MooseX::Runnable::Invocation->new(
        class => 'Class',
        plugins => {
            '+Argless' => ['args go here'],
        },
    );
} qr/Perhaps/, 'argless + args = error';

lives_ok {
    MooseX::Runnable::Invocation->new(
        class => 'Class',
        plugins => {
            '+Argless' => [],
        },
    );
} 'argless + no args = ok';

lives_ok {
    MooseX::Runnable::Invocation->new(
        class => 'Class',
        plugins => {
            '+Plugin' => [],
            '+Plugin2' => [],
        },
    );
} 'two plugins with args compose OK';
