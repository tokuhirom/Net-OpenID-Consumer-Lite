use inc::Module::Install;
name 'Net-OpenID-Consumer-Lite';
all_from 'lib/Net/OpenID/Consumer/Lite.pm';

requires 'LWP::UserAgent';
requires 'URI'            => 1.37;

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
