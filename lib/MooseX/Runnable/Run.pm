package MooseX::Runnable::Run;
use strict;
use warnings;

use MooseX::Runnable::Invocation;

sub run_application($;@) {
    my ($app, @args) = @_;

    exit MooseX::Runnable::Invocation->new(
        class => $app,
    )->run(@args);
}

sub run_application_with_plugins($$;@){
    my ($app, $plugins, @args) = @_;
    exit MooseX::Runnable::Invocation->new(
        class => $app,
        plugins => $plugins,
    )->run(@args);
}

sub import {
    my ($class, $app) = @_;

    if($app){
        run_application $app, @ARGV;
    }
    else {
        my $c = caller;
        no strict 'refs';
        *{ $c. '::run_application' } = \&run_application;
        *{ $c. '::run_application_with_plugins' } = \&run_application_with_plugins;
    }
}

1;

__END__

=head1 NAME

MooseX::Runnable::Run - run a MooseX::Runnable class as an application

=head1 SYNOPSIS

Write an app:

   package MyApp;
   use Moose; with 'MooseX::Runnable';
   sub run { say 'Hello, world.'; return 0 } # (UNIX exit code)

Write a wrapper script, C<myapp.pl>.  With sugar:

   #!/usr/bin/env perl
   use MooseX::Runnable::Run 'MyApp';

Or without:

   #!/usr/bin/env perl
   use MooseX::Runnable::Run;

   run_application 'MyApp', @ARGV;

Then, run your app:

   $ ./myapp.pl
   Hello, world.
   $ echo $?
   0

=head1 DESCRIPTION

This is a utility module that runs a L<MooseX::Runnable|MooseX::Runnable> class with
L<MooseX::Runnable::Invocation|MooseX::Runnable::Invocation>.

=head1 SEE ALSO

L<mx-run>, a script that will run MooseX::Runnable apps, saving you
valuable seconds!

L<MooseX::Runnable>
