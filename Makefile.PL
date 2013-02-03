use inc::Module::Install;

name 'MooseX-Runnable';
all_from 'lib/MooseX/Runnable.pm';

requires 'Moose';
requires 'MooseX::Getopt'; # not really
requires 'MooseX::Types' => '0.10';
requires 'Path::Tiny';
requires 'MooseX::Types::Path::Tiny';
requires 'namespace::autoclean';
requires 'List::MoreUtils';
requires 'Params::Util';

build_requires 'Test::More';
build_requires 'ok';
build_requires 'Test::TableDriven';

install_script 'bin/mx-run';

WriteAll();
