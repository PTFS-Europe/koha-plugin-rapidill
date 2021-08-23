package Koha::Plugin::Com::PTFSEurope::RapidILL::Api;

use Modern::Perl;
use strict;
use warnings;

use File::Basename qw( dirname );
use XML::Compile;
use XML::Compile::WSDL11;
use XML::Compile::SOAP12;
use XML::Compile::SOAP11;
use XML::Compile::Transport::SOAPHTTP;
use JSON qw( decode_json );

use Koha::Logger;
use Koha::Patrons;
use Mojo::Base 'Mojolicious::Controller';
use Koha::Plugin::Com::PTFSEurope::RapidILL;

sub InsertRequest {

    # Validate what we've received
    my $c = shift->openapi->valid_input or return;

    my $credentials = _get_credentials();

    my $body = $c->validation->param('payload')->{body};

    if (!$body->{borrowerId} || !$body->{metadata}) {
        return $c->render(
            status => 400,
            openapi => {
                result => {},
                errors => ['Both borrowerId and metadata properties must be supplied']
            }
        );
    }

    my $borrower = Koha::Patrons->find( $body->{borrowerId} );

    # Base request including passed metadata and credentials
    my $req = {
        input => {
            PatronId             => $borrower->borrowernumber,
            PatronName           => join (" ", ($borrower->firstname, $borrower->surname)),
            PatronNotes          => "== THIS IS A TEST - PLEASE IGNORE! ==",
            ClientAppName        => "Koha RapidILL client",
            IsHoldingsCheckOnly  => 0,
            DoBlockLocalOnly     => 0,
            %{$credentials},
            %{$body->{metadata}}
        }
    };

    $req->{input}->{PatronEmail} = $borrower->email if $borrower->email;

    my $client = build_client('InsertRequest');

    my $response = $client->($req);

    return $c->render(
        status => 200,
        openapi => {
            result => $response->{parameters}->{InsertRequestResult},
            errors => []
        }
    );
}

sub UpdateRequest {

    # Validate what we've received
    my $c = shift->openapi->valid_input or return;

    my $credentials = _get_credentials();

    my $body = $c->validation->param('payload')->{body};

    if (
        !exists $body->{requestId} ||
        !exists $body->{updateAction} ||
        !exists $body->{metadata}
    ) {
        return $c->render(
            status => 400,
            openapi => {
                result => {},
                errors => [{
                    message => 'requestId, updateAction and metadata properties must be supplied'
                }]
            }
        );
    }

    # Base request including passed metadata and credentials
    my $req = {
        input => {
            RapidRequestId       => $body->{requestId},
            UpdateAction         => $body->{updateAction},
            ClientAppName        => "Koha RapidILL client",
            %{$credentials},
            %{$body->{metadata}}
        }
    };

    my $client = build_client('UpdateRequest');

    my $response = $client->($req);

    return $c->render(
        status => 200,
        openapi => {
            result => $response->{parameters}->{UpdateRequestResult},
            errors => []
        }
    );
}

sub _get_credentials {

    my $plugin = Koha::Plugin::Com::PTFSEurope::RapidILL->new();
    my $config = decode_json($plugin->retrieve_data("rapid_config") || {});

    return {
        UserName             => $config->{username},
        Password             => $config->{password},
        RequestingRapidCode  => $config->{requesting_rapid_code},
        RequestingBranchName => $config->{requesting_branch_name}
    };
}

sub build_client {
    my ($operation) = @_;

    open my $wsdl_fh, "<", dirname(__FILE__) . "/rapidill.wsdl" || die "Can't open file $!";
    my $wsdl_file = do { local $/; <$wsdl_fh> };
    my $wsdl = XML::Compile::WSDL11->new($wsdl_file);

    my $client = $wsdl->compileClient(
        operation => $operation,
        port      => "ApiServiceSoap12"
    );

    return $client;
}

1;