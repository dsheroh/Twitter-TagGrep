#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
#use Test::More tests => 3;

use_ok('Twitter::TagGrep');

# Verify object creation w/ no parameters
my $tg = Twitter::TagGrep->new;
isa_ok($tg, 'Twitter::TagGrep');

is($tg->prefix, '#', 'Default prefix is hashtag');
is_deeply([$tg->tags], [], 'No tags by default');
is($tg->{tag_regex}, undef, 'No tag regex set');

# Create with parameters
undef $tg;
$tg = Twitter::TagGrep->new(prefix => '!$', tags => [ qw(foo bar baz) ]);
isa_ok($tg, 'Twitter::TagGrep');

is($tg->prefix, '!$', 'Prefix set correctly on create');
is_deeply([$tg->tags], [qw(foo bar baz)], 'Tags set correctly on create');
is($tg->{tag_regex}, undef, 'No tag regex set on create with prefix/tags');

# Instance method tests

is($tg->prefix(''), '', 'Clear prefix');
is($tg->prefix, '', 'Prefix cleared');
is($tg->prefix('%'), '%', 'Set prefix');
is($tg->prefix, '%', 'Prefix set');

is($tg->add_prefix('^'), '%^', 'Add to prefix');
is($tg->prefix, '%^', 'Prefix added');
is($tg->add_prefix('#', '()'), '%^#()', 'Add multiple prefixes');
is($tg->prefix, '%^#()', 'Multiple prefixes added');

is_deeply([$tg->tags('mumble')], ['mumble'], 'Set single tag');
is_deeply([$tg->tags], ['mumble'], 'Single tag set');
is_deeply([$tg->tags('xyzzy', 'quux')], [qw(xyzzy quux)], 'Set multiple tags');
is_deeply([$tg->tags], [qw(xyzzy quux)], 'Multiple tags set');
is_deeply([$tg->tags(['tag'])], ['tag'], 'Set tags with array ref');
is_deeply([$tg->tags], ['tag'], 'Tags set with array ref');
is_deeply([$tg->tags([])], [], 'Clear tags with array ref');
is_deeply([$tg->tags], [], 'Tags cleared with array ref');

is_deeply([$tg->add_tag('foo')], [qw(foo)], 'Add single tag');
is_deeply([$tg->tags], [qw(foo)], 'Single tag added');
is_deeply([$tg->add_tag('bar', 'baz')], [qw(foo bar baz)], 'Add multiple tags');
is_deeply([$tg->tags], [qw(foo bar baz)], 'Multiple tags added');
is_deeply([$tg->add_tag(['xyzzy'])], [qw(foo bar baz xyzzy)],
  'Add tag with array ref');
is_deeply([$tg->tags], [qw(foo bar baz xyzzy)], 'Tag added with array ref');

my @timeline = (
  { text => 'No match' },
  { text => 'The Wizard of #Quux' },
  { text => '#foo to be fought' },
  { text => '#food fight!' },
  { text => 'A priest and a rabbi walk into a bar...' },
  { text => 'Conan the #Barbarian' },
  { text => 'Ooh!  A candy #bar!' },
  { text => 'Everybody was !foo fighting' },
  { text => '#xyzzy and #quux often appear together' },
);
my @result;

$tg->prefix('#');

$tg->tags('foo');
is($tg->{tag_regex}, undef, 'No tag regex set before grep for #/foo');
@result = $tg->grep_tags(\@timeline);
is($tg->{tag_regex}, '(?:\A|\s)[#](foo)\b',
  'Correct tag regex set after grep for #/foo');
is_deeply(\@result, [ $timeline[2] ], 'Grep for #/foo results correct');

$tg->tags('bar', 'baz');
is($tg->{tag_regex}, undef, 'No tag regex set before grep for #/bar,baz');
@result = $tg->grep_tags(\@timeline);
is($tg->{tag_regex}, '(?:\A|\s)[#](bar|baz)\b',
  'Correct tag regex set after grep for #/bar,baz');
is_deeply(\@result, [ $timeline[6] ], 'Grep for #/bar,baz results correct');

$tg->add_tag('foo');
is($tg->{tag_regex}, undef, 'No tag regex set before grep for #/bar,baz,foo');
@result = $tg->grep_tags(\@timeline);
is($tg->{tag_regex}, '(?:\A|\s)[#](bar|baz|foo)\b',
  'Correct tag regex set after grep for #/bar,baz,foo');
is_deeply(\@result, [ @timeline[6,2] ],
  'Grep for #/bar,baz,foo results correct');

$tg->prefix('!');
is($tg->{tag_regex}, undef, 'No tag regex set before grep for !/bar,baz,foo');
@result = $tg->grep_tags(\@timeline);
is($tg->{tag_regex}, '(?:\A|\s)[!](bar|baz|foo)\b',
  'Correct tag regex set after grep for !/bar,baz,foo');
is_deeply(\@result, [ $timeline[7] ], 'Grep for !/bar,baz,foo results correct');

$tg->add_prefix('#');
is($tg->{tag_regex}, undef, 'No tag regex set before grep for !#/bar,baz,foo');
@result = $tg->grep_tags(\@timeline);
is($tg->{tag_regex}, '(?:\A|\s)[!#](bar|baz|foo)\b',
  'Correct tag regex set after grep for !#/bar,baz,foo');
is_deeply(\@result, [ @timeline[7,6,2] ],
  'Grep for !#/bar,baz,foo results correct');

$tg->tags('QUUX', 'xyzzy');
is($tg->{tag_regex}, undef, 'No tag regex set before grep for !#/QUUX,xyzzy');
@result = $tg->grep_tags(\@timeline);
is($tg->{tag_regex}, '(?:\A|\s)[!#](QUUX|xyzzy)\b',
  'Correct tag regex set after grep for !#/QUUX,xyzzy');
is_deeply(\@result, [ @timeline[8,1] ],
  'Grep for !#/QUUX,xyzzy results correct');

