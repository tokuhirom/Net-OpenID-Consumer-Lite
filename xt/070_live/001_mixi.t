use strict;
use warnings;
use Test::More tests => 2;
use URI;
use Net::OpenID::Consumer::Lite;
use Data::Dumper;
use CGI;

my $consumer = Net::OpenID::Consumer::Lite->new(
    op_list => [ 'https://mixi.jp/openid_server.pl']
);
my $check_url = $consumer->check_url('https://mixi.jp/openid_server.pl', 'http://example.com/');
is $check_url, 'http://example.com/?openid.mode=id_res&openid.user_setup_url=https%3A%2F%2Fmixi.jp%2Fopenid_server.pl%3Fopenid.mode%3Dcheckid_setup%26openid.return_to%3Dhttp%253A%252F%252Fexample.com%252F';
is +{URI->new($check_url)->query_form}->{'openid.user_setup_url'}, 'https://mixi.jp/openid_server.pl?openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fexample.com%2F';

