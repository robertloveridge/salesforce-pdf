package Salesforce;

use strict;
use warnings;

use WWW::Salesforce::Simple;

sub new {
    my $class = shift;
    my $user  = shift;
    my $pass  = shift;

    my $sf_connect = WWW::Salesforce::Simple->new(
        username => $user,
        password => $pass
    );

    my $self = { sf_object => $sf_connect };

    bless( $self, $class );
    return $self;
}

# returns an array of field names for sf table
sub get_table_fields {
    my $self   = shift;
    my $object = shift;

    my @fields;

    my $fields_ref = $self->{sf_object}->get_field_list($object);
    foreach my $field ( @{$fields_ref} ) {
        push @fields, $field->{'name'};
    }

    return @fields;
}

# returns a hash for the given sf object
sub get_object {
    my $self    = shift;
    my $object  = shift;
    my $options = shift;

    my @where;
    foreach my $key ( keys %$options ) {
        if ( $options->{$key} eq 'true' || $options->{$key} eq 'false' ) {
            push @where, "$key = " . $options->{$key} . "";
        }
        else {
            push @where, "$key = '" . $options->{$key} . "'";
        }
    }

    my $query =
        "SELECT "
      . join( ',', $self->get_table_fields($object) )
      . " FROM "
      . $object
      . " WHERE "
      . join( ' AND ', @where );

    my $result = $self->{sf_object}->do_query($query)
      or die "Error fetching records";

    return $result;
}

1;
