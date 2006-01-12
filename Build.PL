use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::TAP::XML',
    license             => 'perl',
    dist_author         => 'Michael Peters <mpeters@plusthree.com>',
    dist_version_from   => 'lib/Test/TAP/XML.pm',
    build_requires => {
        'Test::More'        => 0,
        'Test::TAP::Model'  => 0.04,
        'XML::Simple'       => 0,
        'Test::LongString'  => 0,
        'Test::XML'         => 0,
    },
    add_to_cleanup      => [ 'Test-TAP-XML-*' ],
    create_makefile_pl  => 'passthrough',
    create_readme       => 1,
);

$builder->create_build_script();
