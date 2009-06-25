package MooseX::Runnable::Invocation::Role::WithParsedArgs;
use Moose::Role;
use MooseX::Runnable::Util::ArgParser;

has 'parsed_args' => (
    is       => 'ro',
    isa      => 'MooseX::Runnable::Util::ArgParser',
    required => 1,
);

1;
