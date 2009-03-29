package MooseX::Runnable::Run;
use strict;
use warnings;

use Class::MOP;

use Sub::Exporter -setup => {
    exports => ['run_as_application'],
    groups  => {
        default => ['run_as_application'],
    },
};

sub run_as_application($;@){
    my ($app, @args) = @_;

    eval 'package main; use FindBin qw($Bin); use lib "$Bin/../lib"; 1;' or die;

    Class::MOP::load_class($app);
    die "$app is not runnable" unless $app->does('MooseX::Runnable');
    $app->run_as_application(@args);
}

1;
