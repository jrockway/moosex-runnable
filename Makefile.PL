use inc::Module::Install;

name 'MooseX-Runnable';
all_from 'lib/MooseX/Runnable.pm';

requires 'Moose';
requires 'MooseX::Getopt'; # not really
requires 'MooseX::Types' => 0.11;
requires 'MooseX::Types::Path::Class';
requires 'namespace::autoclean';

build_requires 'Test::More';
build_requires 'ok';

install_script 'bin/mx-run';

WriteAll();
