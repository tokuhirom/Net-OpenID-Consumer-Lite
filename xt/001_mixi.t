use strict;
use warnings;
use Test::More tests => 2;
use URI;
use Net::OpenID::Consumer::Lite;

{
    my $check_url1 = Net::OpenID::Consumer::Lite->check_url('https://mixi.jp/openid_server.pl', 'http://example.com/');
    is $check_url1, 'https://mixi.jp/openid_server.pl?openid.mode=checkid_immediate&openid.return_to=http%3A%2F%2Fexample.com%2F';
}

{
    my $check_url2 = Net::OpenID::Consumer::Lite->check_url('https://mixi.jp/openid_server.pl', 'http://example.com/', {
        "http://openid.net/extensions/sreg/1.1" => { required => join( ",", qw/email nickname/ ) }
    });
    is_deeply(+{URI->new($check_url2)->query_form()}, +{URI->new('https://mixi.jp/openid_server.pl?openid.mode=checkid_immediate&openid.return_to=http%3A%2F%2Fexample.com%2F&openid.ns.e1=http://openid.net/extensions/sreg/1.1&openid.e1.required=email,nickname')->query_form});
}
