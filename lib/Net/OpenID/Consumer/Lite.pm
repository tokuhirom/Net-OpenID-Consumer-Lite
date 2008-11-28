package Net::OpenID::Consumer::Lite;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use LWP::UserAgent;
use Carp ();

my $TIMEOUT = 4;

sub new {
    my ($class, %args) = @_;
    $args{op_list} = +{ map { $_ => 1 } @{$args{op_list}} };
    bless {%args}, $class;
}

sub _ua {
    LWP::UserAgent->new(
        agent =>
          "Net::OpenID::Consumer::Lite/$Net::OpenID::Consumer::Lite::VERSION",
        timeout      => $TIMEOUT,
        max_redirect => 0,
    );
}

sub check_url {
    my ($self, $url, $return_to) = (shift, shift, shift);
    Carp::croak("Too many parameters") if @_;
    Carp::croak("unknown op: $url") unless $self->{op_list}->{$url};

    my $ua = _ua();
    my $res = $ua->get("${url}?openid.mode=checkid_immediate&openid.return_to=" . URI::Escape::uri_escape($return_to));
    $res->is_success() or die $res->content;
    my $location = $res->base or die 'missing location';
    return $location;
}

sub _check_authentication {
    my ($self, $request) = @_;
    my $url = do {
        $request->{'openid.mode'} = 'check_authentication';
        my $request_url = URI->new($request->{'openid.op_endpoint'});
        $request_url->query_form(%$request);
        $request_url;
    };
    my $ua = _ua();
    my $res = $ua->get($url);
    $res->is_success() or die "cannot load $url";
    my $is_valid = Net::OpenID::Consumer::Lite::Util::parse_keyvalue($res->content)->{is_valid};
    return $is_valid eq 'is_valid:true' ? 1 : 0;
}

sub handle_server_response {
    my $self = shift;
    my $request = shift;
    my %callbacks_in = @_;
    my %callbacks = ();

    for my $cb (qw(not_openid setup_required cancelled verified error)) {
        $callbacks{$cb} = delete( $callbacks_in{$cb} )
            || sub { Carp::croak( "No " . $cb . " callback" ) };
    }

    my $mode = $request->{'openid.mode'};
    unless ($mode) {
        return $callbacks{not_openid}->();
    }

    if ($mode eq 'cancel') {
        return $callbacks{cancelled}->();
    }

    if (my $url = $request->{'openid.user_setup_url'}) {
        return $callbacks{'setup_required'}->($url);
    }

    if ($self->_check_authentication($request)) {
        return $callbacks{'verified'}->($request);
    } else {
        return $callbacks{'error'}->();
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Net::OpenID::Consumer::Lite -

=head1 SYNOPSIS

    use Net::OpenID::Consumer::Lite;
    my $csr = Net::OpenID::Consumer::Lite->new(
        op_list => ['https://mixi.jp/openid_server.pl'] # usable OP list
    );
    $csr->handle_server_response(
        not_openid => sub {
            die "Not an OpenID message";
        },
        setup_required => sub {
            my $setup_url = shift;
            # Redirect the user to $setup_url
        },
        cancelled => sub {
            # Do something appropriate when the user hits "cancel" at the OP
        },
        verified => sub {
            my $vident = shift;
            # Do something with the VerifiedIdentity object $vident
        },
        error => sub {
            my $err = shift;
            die($err);
        },
    );

=head1 DESCRIPTION

Net::OpenID::Consumer::Lite is

    LIMITED.
    BUT, LIGHTWEIGHT.

=head1 POINT!

    only supports OpenID 2.0
    only supports verified OPs
    support CGI

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
