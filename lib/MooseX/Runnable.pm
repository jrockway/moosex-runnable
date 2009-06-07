package MooseX::Runnable;
use Moose::Role;

our $VERSION = '0.00_02';

requires 'run';

1;

__END__

=head1 NAME

MooseX::Runnable - tag a class as a runnable application

=head1 SYNOPSIS

Create a class, tag it runnable, and provide a C<run> method:

    package App::HelloWorld;
    use feature 'say';
    use Moose;

    with 'MooseX::Runnable';

    sub run {
       my ($self,$name) = @_;
       say "Hello, $name.";
       return 0; # success
    }

Then you can run this class as an application with the included
C<mx-run> script:

    $ mx-run App::HelloWorld jrockway
    Hello, jrockway.
    $

C<MooseX::Runnable> supports L<MooseX::Getopt|MooseX::Getopt>, and
other similar systems (and is extensible, in case you have written
such a system).

=head1 DESCRIPTION

MooseX::Runnable is a framework for making classes runnable
applications.  This role doesn't do anything other than tell the rest
of the framework that your class is a runnable application that has a
C<run> method which accepts arguments and returns the process' exit
code.

This is a convention that the community has been using for a while.
This role tells the computer that your class uses this convention, and
let's the computer abstract away some of the tedium this entails.

=head1 REQUIRED METHODS

=head1 THINGS YOU GET

=head2 C<mx-run>

This is a script that accepts a C<MooseX::Runnable> class and tries to
run it, using C<MooseX::Runnable::Run>.

The syntax is:

  mx-run Class::Name

  mx-run <args for mx-run> -- Class::Name <args for Class::Name>

for example:

  mx-run -Ilib App::HelloWorld --args --go --here

or:

  mx-run -Ilib +Persistent --port 8080 -- App::HelloWorld --args --go --here

=head2 C<MooseX::Runnable::Run>

If you don't want to invoke your app with C<mx-run>, you can write a
custom version using L<MooseX::Runnable::Run|MooseX::Runnable::Run>.
