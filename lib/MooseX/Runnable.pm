package MooseX::Runnable;
use Moose::Role;

our $VERSION = '0.02';

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

=head2 run

Your class must implement C<run>.  It accepts the commandline args
(that were not consumed by another parser, if applicable) and returns
an integer representing the UNIX exit value.  C<return 0> means
success.

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

=head1 ARCHITECTURE

C<MX::Runnable> is designed to be extensible; users can run plugins
from the command-line, and application developers can add roles to
their class to control behavior.

For example, if you consume L<MooseX::Getopt|MooseX::Getopt>, the
command-line will be parsed with C<MooseX::Getopt>.  Any recognized
args will be used to instantiate your class, and any extra args will
be passed to C<run>.

=head1 BUGS

Many of the plugins shipped are unstable; they may go away, change,
break, etc.  If there is no documentation for a plugin, it is probably
just a prototype.

=head1 REPOSITORY

L<http://github.com/jrockway/moosex-runnable>

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2009 Jonathan Rockway

This module is Free Software, you can redistribute it under the same
terms as Perl itself.
