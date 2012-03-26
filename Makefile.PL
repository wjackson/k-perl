use strict;
use warnings;
use inc::Module::Install;
use ExtUtils::Depends;

mkdir 'build';
my $pkg = ExtUtils::Depends->new('K');

my $c_o = defined $ENV{KOBJ} ? $ENV{KOBJ}
        : -f 'q/c.o'         ? 'q/c.o'
        :                      undef
        ;

if (!defined $c_o || !-f $c_o) {
    die q{*** Unable to find the required file c.o which is distributed by }
      . q{kx.com.  Set the environment variable KOBJ to the location of c.o }
      . q{or download the appropriate file and place it into the q }
      . q{directory. Find the correct file for you system here: }
      . q{http://kx.com/q. For example the url for the 32 bit linux file is }
      . q{http://kx.com/q/l32/c.o .}
      ;
}

checklibs(
    incpath => './q',
    header  => 'k.h',
);

$pkg->set_inc("-Iq");
$pkg->add_xs('K.xs');
$pkg->add_pm(
    './lib/K/Raw.pm' => '$(INST_LIBDIR)/K/Raw.pm',
    './lib/K.pm'     => '$(INST_LIBDIR)/K.pm',
);
$pkg->add_typemaps('typemap');
$pkg->save_config('build/IFiles.pm');

makemaker_args(
    $pkg->get_makefile_vars,
    OBJECT => "\$(O_FILES) $c_o", # link all the C files too
);

name 'K';
license 'Perl_5';
perl_version '5.010';
all_from 'lib/K/Raw.pm';
ppport;

configure_requires 'ExtUtils::Depends';
requires 'Sub::Exporter';
requires 'namespace::autoclean';
test_requires 'File::Which';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Test::TCP';
test_requires 'ok';

WriteAll;
