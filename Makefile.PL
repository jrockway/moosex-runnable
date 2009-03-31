use inc::Module::Install;

name 'MooseX-Runnable';
all_from 'lib/MooseX/Runnable.pm';

build_requires 'Catalyst::Runtime';
build_requires 'Test::WWW::Mechanize::Catalyst';
build_requires 'Test::More';
build_requires 'ok';

install_script 'bin/mx-run';

WriteAll();
