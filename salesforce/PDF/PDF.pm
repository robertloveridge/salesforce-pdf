package PDF;

use strict;
use warnings;

use Template;

sub new {
    my $class = shift;

    my $tt = Template->new(
        {
            INCLUDE_PATH => 'templates/',
            INTERPOLATE  => 1,
            FILTERS      => { commify => \&tt2_filter_commify },
        }
    );

    my $self = { tt => $tt };

    bless( $self, $class );
    return $self;
}

sub make_pdf {
    my $self     = shift;
    my $template = shift;
    my $vars     = shift;

    my $output = '';

    $self->{tt}->process( $template, $vars, \$output, binmode => 1 )
      || die $self->{tt}->error();

    return $output;
}

sub tt2_filter_commify {
    my $text = reverse shift;
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}

1;
