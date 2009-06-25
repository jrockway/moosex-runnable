use strict;
use warnings;
use Test::Exception;
use Test::More tests => 4;

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



