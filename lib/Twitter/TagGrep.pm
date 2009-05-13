package TagGrep;

use strict;
use warnings;

our $VERSION = '0.0001';

sub prefix {
  my $self = shift;

  $self->{prefix} = $_[0] if defined $_[0];
  $self->{tag_regex} = '';
  return $self->{prefix};
}

sub add_prefix {
  my $self = shift;

  $self->{prefix} = join '', $self->{prefix}, @_;
  $self->{tag_regex} = '';
  return $self->{prefix};
}

sub tags {
  my $self = shift;

  if (@_) {
    if (ref $_[0] eq 'ARRAY') {
      $self->{tags} = $_[0];
    } else {
      $self->{tags} = [ @_ ];
    }
    $self->{tag_regex} = '';
  }

  return @{$self->{tags}};
}

sub add_tag {
  my $self = shift;

  for my $tag (@_) {
    if (ref $tag eq 'ARRAY') {
      push @{$self->{tags}}, @$tag;
    } else {
      push @{$self->{tags}}, $tag;
    }
  }

  $self->{tag_regex} = '';
  return @{$self->{tags}};
}


sub grep_tags {
  my $self = shift;
  my $timeline = shift;

  $self->_gen_tag_regex unless $self->{tag_regex};

  return reverse grep {
    my @tags = $_->{text} =~ /$self->{tag_regex}/gi;
    $_->{tags} = \@tags if @tags;
  } @$timeline;
}


sub new {
  my ($class, %params) = @_;

  my $self = {
              prefix    => defined $params{prefix} ? $params{prefix} : '#',
              tag_regex => '',
             };
  bless $self, $class;

  $self->tags($params{tags});

  return $self;
}

sub _gen_tag_regex {
  my $self = shift;

  $self->{tag_regex} = '(?:\A|\s)[' . $self->prefix . ']('
                       . (join '|', $self->tags) . ')\b';

#  print $self->{tag_regex}, "\n";
}

=head1 NAME

Twitter::TagGrep - The great new Twitter::TagGrep!

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Twitter::TagGrep;

    my $foo = Twitter::TagGrep->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=head2 function2

=head1 AUTHOR

Dave Sherohman, C<< <dave at sherohman.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-twitter-taggrep at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Twitter-TagGrep>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Twitter::TagGrep


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Twitter-TagGrep>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Twitter-TagGrep>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Twitter-TagGrep>

=item * Search CPAN

L<http://search.cpan.org/dist/Twitter-TagGrep/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Dave Sherohman, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Twitter::TagGrep
