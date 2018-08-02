#!/usr/bin/perl
use utf8;
use locale ':!numeric';
use Getopt::Args;
use Git;

arg language => (
	isa => 'Str',
	required => 1,
	comment => 'language for this entry',
);

opt minimum => (
	isa => 'Int',
	alias => 'm',
	default => '10',
	comment => 'minimum number of hits to make an entry',
);

opt license => (
	isa => 'Str',
	default => 'CC0-1.0',
	comment => 'license for the generated json stucture',
);

opt generator => (
	isa => 'Str',
	default => 'language-detect/generate-ngrams',
	comment => 'generator that created the json stucture',
);

opt major => (
	isa => 'Int',
	default => '1',
	comment => 'major version for the data structure, aka structure changes',
);

opt minor => (
	isa => 'Int',
	default => '0',
	comment => 'minor version for the data structure, aka data index',
);

opt title => (
	isa => 'Str',
	default => 'N-grams',
	comment => 'a title for the dataset, usually a short descriptive phrase',
);

opt comment => (
	isa => 'Str',
	default => 'Probabilities for the individual N-gram occurences.',
	comment => 'a comment about the dataset, usually a longer descriptive phrase',
);

opt author => (
	isa => 'ArrayRef',
	comment => 'one or more authors, could be a full name or a nick name',
);

opt error => (
	isa => 'Str',
	alias => 'e',
	comment => 'the error file, if missing use STDERR',
);

arg output => (
	isa => 'Str',
	required => 0,
	comment => 'the output file, if missing use STDOUT',
);

my $oa = optargs;

if ($oa->{error}) {
	open STDERR, ">", $oa->{error} or die "$0: open: $!";
}
binmode(STDERR, ":utf8");

if ($oa->{output}) {
	open STDOUT, ">", $oa->{output} or die "$0: open: $!";
}
binmode(STDOUT, ":utf8");

my %frags;
my $docs = 0;
my $words = 0;
my $frags = 0;
my $excludes = 0;

sub word {
	my $str = "__".@_[0]."__";
	my $len = length( $str ) - 3;
	for my $i (0..$len) {
		$frags++;
		my $fragment = lc( substr( $str, $i, 3 ) );
		$frags{$fragment} = 0 unless $frags{$fragment};
		$frags{$fragment}++;
	}
}

while ($_ = <>) {
	$docs++;
	s/(\p{Alpha}+)/{ word( $1 ); $words++; }/sge;
}

my @entries;
foreach my $name (sort keys %frags) {
	if ( $frags{$name} >= $oa->{minimum} ) {
		push( @entries, sprintf( "\t\t\"%s\": %.3e", $name, $frags{$name} / $frags ) );
	}
	else {
		$excludes += $frags{$name};
	}
}

my @authors;
if ( scalar(@{$oa->{author}}) > 0 ) {
	foreach my $author ( @{$oa->{author}} ) {
		push( @authors, sprintf( "\t\t\t\"%s\"", $author ) );
	}
}
else {
	my $repo = Git->repository();
	push( @authors, sprintf( "\t\t\t\"%s <%s>\"", $repo->config ( 'user.name' ), $repo->config ( 'user.email' ) ) );
}

my $buff =<<"EndOfText";
{
	"\@metadata": {
		"title": "$oa->{title}",
		"comment": "$oa->{comment}",
		"license": "$oa->{license}",
		"generator": "$oa->{generator}",
		"authors": [
@{[ join( ",\n", @authors ) ]}
		]
	},
	"language": "$oa->{language}",
	"version": "$oa->{major}.$oa->{minor}",
	"minimum": "$oa->{minimum}",
	"marginals": {
		"documents": $docs,
		"words": $words,
		"fragments": $frags,
		"excludes": $excludes
	},
	"ngrams": {
@{[ join( ",\n", @entries ) ]}
	}
}
EndOfText

print $buff;
