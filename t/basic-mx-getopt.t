use strict;
use warnings;
use Test::Exception;
use Test::More tests => 5;

use MooseX::Runnable::Invocation;
use ok 'MooseX::Runnable::Invocation::Scheme::MooseX::Getopt';

my $foo;

{ package Class;
  use Moose;
  with 'MooseX::Runnable', 'MooseX::Getopt';

  has 'foo' => (
      is       => 'ro',
      isa      => 'Str',
      required => 1,
  );

  sub run {
      my ($self, $code) = @_;
      $foo = $self->foo;
      return $code;
  }
}

my $invocation = MooseX::Runnable::Invocation->new(
    class => 'Class',
);

ok $invocation;

my $code;
lives_ok {
    $code = $invocation->run('--foo', '42', 0);
} 'run lived';

is $foo, '42', 'got foo from cmdline';

is $code, 0, 'exit status ok';
