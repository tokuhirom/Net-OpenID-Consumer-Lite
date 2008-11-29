use strict;
use warnings;
use Test::More tests => 1;
use URI;
use Net::OpenID::Consumer::Lite;

my $check_url = Net::OpenID::Consumer::Lite->check_url('https://mixi.jp/openid_server.pl', 'http://example.com/');
is $check_url, 'https://mixi.jp/openid_server.pl?openid.mode=checkid_immediate&openid.return_to=http%3A%2F%2Fexample.com%2F';

