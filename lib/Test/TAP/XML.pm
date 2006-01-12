package Test::TAP::XML;
use base 'Test::TAP::Model';
use XML::Simple qw(:strict);

use warnings;
use strict;

=head1 NAME

Test::TAP::XML - Output test results as XML

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Test::TAP::XML

    my $t = Test::TAP::XML->new();

    $t->run_tests(qw( t/foo.t t/bar.t );

    print $t->xml;

=head1 DESCRIPTION

Test::TAP::XML is a subclass of L<Test::TAP::Model> (which in turn is a subclass of 
L<Test::Harness::Straps>). This means it is trivial to add XML output support to an
existing test harness based on L<Test::Harness>.

=head1 OBJECT METHODS

All of the L<Test::TAP::Model> methods are avaialable along with the following
methods:

=head2 xml

This method will return the XML text that contains the information output
by the tests.

    my $xml = $t->xml;

=cut

our %OUT_options = (
    RootName    => 'test_run',
    XMLDecl     => 1,
    KeyAttr     => [],
    NoAttr      => 1,
);

our %IN_options = (
    KeyAttr     => [],
    NoAttr      => 1,
    ForceArray  => [qw(test_files event)],
);

sub xml {
    my $self = shift;
    my $struct = $self->structure;

    # remove the extra "\n" at the end of each 'line'
    foreach my $file ( @{$struct->{test_files}} ) {
        foreach my $event ( @{$file->{events}} ) {
            chomp($event->{line});
        }
        # rename 'events' to 'event' (it looks better in the XML)
        $file->{event} = delete $file->{events};
    }

    # rename 'events' to 'event'
    return XMLout(
        $struct,
        %OUT_options,
    );
}

=head1 CLASS METHODS

=head2 from_xml

This method will create a new Test::TAP::XML object from a string
(a scalar or a scalar ref) containing XML.

    my $tap_model = Test::TAP::XML->from_xml($xml);

=cut

sub from_xml {
    my ($class, $xml) = @_;
    my $struct = ref $xml eq 'SCALAR' 
        ? XMLin($$xml, %IN_options)
        : XMLin($xml,  %IN_options);

    # rename 'event' to 'events'
    foreach my $file ( @{$struct->{test_files}} ) {
        $file->{events} = delete $file->{event};
        foreach my $event ( @{$file->{events}} ) {
            
            $event->{reason} = '' if(_is_empty_hash($event->{reason}));
            $event->{skip}   = '' if(_is_empty_hash($event->{skip}));
            $event->{todo}   = '' if(_is_empty_hash($event->{todo}));
            $event->{'pos'}  = undef if(_is_empty_hash($event->{'pos'}));
            $event->{line}   .= "\n";
        }
    }
    my $tap_model = $class->new_with_struct($struct);
    return $tap_model;
}

sub _is_empty_hash {
    my ($thing) = @_;
    if( 
        ref $thing eq 'HASH'
        &&
        ! keys %$thing
    ) {
        return 1;
    } else {
        return 0;
    }
}

=head1 AUTHOR

Michael Peters, C<< <mpeters at plusthree.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-tap-xml at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-TAP-XML>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::TAP::XML

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-TAP-XML>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-TAP-XML>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-TAP-XML>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-TAP-XML>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Michael Peters, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Test::TAP::XML
