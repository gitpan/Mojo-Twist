package Mojo::Twist::Articles;
use Mojo::Base -base;

use Mojo::Twist::Article;
use Mojo::Twist::Directory;

sub new {
  my $self      = shift->SUPER::new;
  my (%params)  = @_;

  $self->{directory} = Mojo::Twist::Directory->new(path => $params{path});
  $self->{article_args} = $params{article_args} || {};

  return $self;
}

sub find_all {
  my $self = shift;
  my (%params) = @_;

  my $articles = [];
  foreach my $file (@{$self->{directory}->files}) {
    if (defined $params{offset}) {
      next unless $file->created->timestamp le $params{offset};
    }

    my $article = $self->_build_article(file => $file);
    if (defined(my $tag = $params{tag})) {
      next unless grep { $_ eq $tag } @{$article->tags};
    }

    push @$articles, $article;

    last if exists $params{limit} && @$articles >= $params{limit};
  }

  return $articles;
}

sub find {
  my $self = shift;
  my (%params) = @_;

  foreach my $file (@{$self->{directory}->files}) {
    return $self->_build_article(file => $file)
      if exists $params{slug} && $file->filename eq $params{slug};
  }

  return;
}

sub _build_article {
  my $self = shift;

  return Mojo::Twist::Article->new(%{$self->{article_args}}, @_);
}

1;
