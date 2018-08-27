#!/usr/bin/perl

use strict;
use warnings;

use lib 'salesforce/PDF';

use CGI;
use Salesforce;
use PDF;

my $cgi = CGI->new;

my $action = $cgi->param('action');

my %actions = ( contract => \&contract, );

if ( $actions{$action} ) {
    $actions{$action}->($cgi);
}

sub contract {
    my $cgi = shift;
    my $sf  = sf();

    my $contract_id = $cgi->param('id') || shift;

    die "No Contract ID Supplied" unless $contract_id;

    # get the objects from Salesforce
    my ($contract) = $sf->get_object( 'Contract', { Id => $contract_id } );
    my ($client) = $sf->get_object( 'Contact', { Id => $contract->[0]->{CustomerSignedId} } );
    my ($account) = $sf->get_object( 'Account', { Id => $contract->[0]->{AccountId} } );

    my $pdf = PDF->new();

    my $sf_records = {
        contract => $contract->[0],
        client   => $client->[0],
        account  => $account->[0],
    };

    my $vars;
    foreach my $type ( keys %{$sf_records} ) {
        foreach my $key ( keys %{ $sf_records->{$type} } ) {
            $vars->{$type}->{$key} = $sf_records->{$type}->{$key};
        }
    }

    $vars->{header} = "Contract: " . $contract->[0]->{Name};

    print $cgi->header(
        {
            -encoding => 'utf-8',
            -type     => 'text/html',
        }
    );

    print $pdf->make_pdf( 'contract.tt2', $vars );
}

sub sf {
    my $user = '';
    my $pass = '';

    my $sf = Salesforce->new( $user, $pass )
      or die "Could not connect to Salesforce";

    return $sf;
}
