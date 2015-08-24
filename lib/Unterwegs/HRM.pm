use utf8;
use Remedi::Imagefile;
package Unterwegs::HRM;

# ABSTRACT: Heart rate monitor file

use Moose;
use MooseX::Types::Path::Tiny qw( Path );
use MooseX::AttributeShortcuts;
use Data::Dumper;

has filename => (
    is => 'rw',
    isa => Path,
    coerce => 1,
);

has block_sep_reg => (
    is => 'ro',
    isa => 'RegexpRef',
    is => 'lazy',
);

sub _build_block_sep_reg {
    qr{ 
        \[                  # starts with a square bracket
            (               # capturing
                [^\]]*      # everything except a closing bracket 
            )
        \]                  # closing square bracket
   \s*                      # perhaps spaces
   }x;
}

sub trim { $_[0] =~ s/^\s+|\s+$//g }

sub get_blocks {
    my $self = shift;
    my $chunk = shift;

    my $regex = $self->block_sep_reg;
    my (undef, %blocks) = split /$regex/, $chunk;
    trim($_) foreach values %blocks;
    return \%blocks;
}

sub get_params {
    my $self = shift;
    my $blocks = shift;

    my (undef, %params) = split /^([^=]*)=/m, $blocks->{Params};
    trim($_) foreach values %params;
    return \%params;
}

sub get_hrzones {
    my $self = shift;
    my $blocks = shift;

    my @hrzones = split /\s+/, $blocks->{HRZones};
    return \@hrzones;
}

sub get_hrdata {
    my $self = shift;
    my $blocks = shift;

    my @hrdata =  split /^/, $blocks->{HRData};
    trim($_) foreach @hrdata;
    foreach my $hrdate (@hrdata) {
        my $temp;
        @$temp{qw(heart_rate speed altitude)} = split /\t/, $hrdate;
        $hrdate = $temp;
    }
    return \@hrdata;  
}


sub read {
    my $self = shift;
    $self->filename(shift);
    
    my $data;
    my $blocks = $self->get_blocks($self->filename->slurp_utf8);   
    $data->{params} = $self->get_params($blocks);
    $data->{hrzones} = $self->get_hrzones($blocks);
    $data->{hrdata} = $self->get_hrdata($blocks);
    return $data;
}

sub get_hrdata_as_href_of_time {
    my $self = shift;
    my $data = shift;

    my $strp_hrm_time = new DateTime::Format::Strptime(
        pattern     => '%H:%M:%S.%1N',
        locale      => 'de_DE',
        on_error    => 'croak',
    );

    my $strp_hrm_date = new DateTime::Format::Strptime(
        pattern     => '%Y%m%d',
        locale      => 'de_DE',
        on_error    => 'croak',
    );

    my $date = $strp_hrm_date->parse_datetime($data->{params}{Date});
    my $time = $strp_hrm_time->parse_datetime($data->{params}{StartTime});
    my $dt = $date->add(DateTime::Duration->new(
        hours   => $time->hour(),
        minutes => $time->minute(),
        seconds => $time->second(),
    ));
    my $one_second = DateTime::Duration->new(seconds => 1);
    
    my $hrdata;
    foreach my $hr (@{ $data->{hrdata} } ) {
        my $timestr = $dt->strftime("%FT%TZ");
        $hrdata->{$timestr} =  $hr;
        $dt->add($one_second);
    }        
    return $hrdata;
}

__PACKAGE__->meta->make_immutable();

1;

