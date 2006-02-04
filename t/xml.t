use Test::More;
use Test::LongString;
use Test::XML;
plan(tests => 50);
use_ok("Test::TAP::XML");
use Test::TAP::Model;
use File::Temp;

# run some of the other tests
my @tests = qw(t/pod.t t/pod-coverage.t); 
$ENV{TEST_TAP_XML_TESTS} = 1;
my $model = Test::TAP::XML->new(); 
$model->run_tests(@tests); 
my $xml = $model->xml;

# test the XML
is_well_formed_xml($xml);
contains_string($xml, '<file>t/pod.t</file>');
contains_string($xml, '<file>t/pod-coverage.t</file>');
contains_string($xml, '<ok>1</ok>');
contains_string($xml, '<bonus>0</bonus>');
contains_string($xml, '<exit>0</exit>');
contains_string($xml, '<max>1</max>');
contains_string($xml, '<ok>1</ok>');
contains_string($xml, '<passing>1</passing>');
contains_string($xml, '<seen>1</seen>');
contains_string($xml, '<skip>0</skip>');
contains_string($xml, '<todo>0</todo>');
contains_string($xml, '<wait>0</wait>');

# now read that XML and create another model obj
my $model2 = Test::TAP::XML->from_xml($xml);
isa_ok($model2, 'Test::TAP::XML');

# now create another model from reading the file
my $tmp = File::Temp->new(
    UNLINK  => 1,
    SUFFIX  => '.xml',
);
print $tmp $xml or die "Could not print XML to file '$tmp'! $!";
close $tmp;
my $model3 = Test::TAP::XML->from_xml_file($tmp->filename);
isa_ok($model3, 'Test::TAP::XML');


# now compare them to the original
my @methods = qw( 
    ok passing passed nok failed 
    failing total_ok total_passed 
    total_nok total_failed total_percentage 
    total_ratio total_seen total_skipped 
    total_todo total_unexpectedly_succeeded ratio
);
foreach my $method (@methods) {
    foreach my $other_model ($model2, $model3) {
        is($model->$method, $other_model->$method, "$method returns the same");
    }
}



