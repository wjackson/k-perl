use strict;
use warnings;
use inc::Module::Install;
use ExtUtils::Depends;

mkdir 'build';
my $pkg = ExtUtils::Depends->new( 'K::Raw', 'XS::Object::Magic' );

my $q_home    = '/home/wjackson/q';
my $q_include = "$q_home/include";
my $q_lib     = "$q_home/lib";

checklibs(
    libpath => $q_lib,
    incpath => $q_include,
    lib     => 'k',
    header  => 'k.h',
);

$pkg->set_inc("-I$q_include");
$pkg->set_libs("-L$q_lib -lk");
$pkg->add_xs('K.xs');
$pkg->add_pm(
    './lib/K/Raw.pm' => '$(INST_LIBDIR)/Raw.pm',
);
$pkg->add_typemaps('typemap');
$pkg->save_config('build/IFiles.pm');

makemaker_args(
    $pkg->get_makefile_vars,
);

name 'K-Raw';
license 'Perl_5';
perl_version '5.010';
all_from 'lib/K/Raw.pm';
ppport;


configure_requires 'ExtUtils::Depends';
configure_requires 'XS::Object::Magic' => '0.04';
requires 'Sub::Exporter';
requires 'XS::Object::Magic';
test_requires 'File::Which';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Test::TCP';

WriteAll;
