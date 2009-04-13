package MooseX::Runnable::Invocation::Plugin::PAR;
use Moose::Role;

use Module::ScanDeps ();
use App::Packer::PAR ();
use MooseX::Runnable::Run;

use File::Temp qw(tempfile);

my $mk_scanner = sub {
    my $class = Moose::Meta::Class->create_anon_class( superclasses => ['Moose::Object'] );

    for my $m (qw/set_file set_options calculate_info
                  go scan_deps add_deps _find_in_inc/){
        $class->add_method( $m => sub { warn "$m @_" } );
    }
    $class->add_method( get_files => sub { warn 'get_files'; [ keys %INC ] } );
    my $name = $class->name;
    $name =~ s{::}{/}g;
    $INC{ "$name.pm" } = 1;
    return $class;
};

around run => sub {
    my ($next, $self, @args) = @_;
    print "Creating a PAR instead of runing the app.\n";

    { # pre-load as much as possible
        my $class = $self->load_class;
        $self->apply_scheme($class);
        eval {
            # this is probably not possible, but we might as well try
            $self->validate_class($class);
        };
    }

    my $inc = join " ",
      map { "require '$_';\n" }
        keys %INC;
    my $plugins = join ', ', map { "'$_'" } grep { $_ ne 'PAR' } @{$self->plugins};
    my $app = $self->class;
    my $script = <<"END";
use MooseX::Runnable::Run;
use MooseX::Runnable::Invocation;
require Params::Validate; # XXX!
$inc
exit MooseX::Runnable::Invocation->new(
    class   => '$app',
    plugins => [$plugins],
)->run(@ARGV);
END

    $app =~ s/::/_/g;
    $app = lc $app;

    my $opt = { e => $script, o => $app, vvv => 1 };

    App::Packer::PAR->new(
        frontend  => 'Module::ScanDeps',
        backend   => 'PAR::Packer',
        frontopts => $opt,
        backopts  => $opt,
        args      => [],
    )->go;

    return 0;
};

1;
