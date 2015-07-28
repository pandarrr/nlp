#! usr/bin/perl
#
# Author: Ryan Stowell
# Date: 10/05/2014
# CS 5761
# Programming Assignment 2
#
# Problem: Write a program that reads text from files and builds
# a model using ngrams and then generates sentences from the model.
# The length of the ngram, the number of sentences to generate and
# the files to read are input by the user.
#
# Usage: Run the program from command line giving it arguments in the form of:
#
# perl ngram.pl n m file/s
#
# where n is the length of the ngram, m is the number of sentences to generate
# followed by a list of 1 or more files.
#
# Algorithm:
#  1)  Get ngram length and number of sentences from command line.
#  2)  While there are files to read:
#  3)    Open the next file.
#  4)    Slurp the entire file into a scalar.
#  5)    Clean the input: remove invalid characters, convert to lowercase, and
#          add a space before and after punctuation.
#  6)    Split the input into an array so each index of the array is one token.
#  7)    Initialize the starting ngram with n "<s> " tokens.
#  8)    Loop through the token array.
#  9)      Get the next token and add it to list in the hash associated with the ngram.
#  10)     If the token is an end of sentence token then reset the ngram to the starting ngram.
#          Else remove the first token from the ngram and append the new token.
#  11)   Close the file.
#  12) Generate m sentences from the model.
#  13)   Initialize the sentence to "" and the starting ngram.
#  14)   Loop until the token is an end of sentence token.
#  15)     Get a random token associated with the current ngram.
#  16)     Append the token to the sentence.
#  17)     Remove the first token from the current ngram and append the new token.
#

sub main {
  @input = reverse(@ARGV);
  $n = pop @input;
  $sentences = pop @input;
  %ngrams = ();
  buildModel();

  for ($l = 0; $l < $sentences; $l += 1) {
    generate();
  }
}

# Reads the files and builds the model.
sub buildModel {
  # Loop through each file.
  while ($file = pop @input) {
    # Open the file.
    open FILE, '<:encoding(UTF-8)', $file;

    # Read the entire file into a scalar.
    undef $/;
    $lines = <FILE>;

    # Remove all characters that are not punctuation, digits,
    # letters, or white space.
    $lines =~ s/[^\s\w\d\p{P}]//gi;

    # Convert everything to lowercase.
    $lines =~ s/(.*)/\L$1/gi;

    # Add a space before and after every punctuation mark.
    $lines =~ s/(\p{P})/ $1 /g;

    # Split by white space and get size of array
    @tokens = split /\s+/, $lines;
    $numTokens = @tokens;

    # Initialize first ngram with n "<s>" tokens to signify start of sentence
    $ngram = "";
    for ($k = 0; $k < $n; $k += 1) {
      $ngram .= "<s> ";
    }

    # Loop through the size of the array
    for ($j = 0; $j < $numTokens; $j += 1) {
      # Get next token
      $token = @tokens[$j];

      # Add token to list
      push (@{$ngrams{$ngram}}, $token);

      # If token is a '.' or '?' or '!' get next token for ngram
      if ($token =~ m/[\.\?\!]/) {
        $ngram = "";
        for ($k = 0; $k < $n; $k += 1) {
          $ngram .= "<s> ";
        }
      } else {
        # Remove first token from ngram and append new token
        $ngram =~ s/^.*?\s(.*)/$1$token /;
      }
    }

    close FILE;
  }
}

# Generates one sentence from the ngram model.
sub generate {
  # Initialize sentence with "" and the first ngram.
  $sentence = "";
  $ngram = "";
  for ($j = 0; $j < $n; $j += 1) {
    $ngram .= "<s> ";
  }
  $token = "";

  # Loop until the token is an end of sentence token.
  until ($token =~ m/[\.\?\!]/) {
    # Get a random token from the list associate with the current ngram.
    @tokens = @{$ngrams{$ngram}};
    $token = $tokens[rand  @tokens];

    # If token is punctuation remove the last space before appending
    if ($token =~ m/[\p{P}]/) {
      chop ($sentence);
    }

    # Append the token to the sentence.
    $sentence .= "$token ";

    # Remove the first token from the ngram and append the new token.
    $ngram =~ s/^.*?\s(.*)/$1$token /;
  }

  # Remove the last space from the sentence and capitalize the first letter before printing.
  chop ($sentence);
  $sentence = ucfirst($sentence);
  print $sentence . "\n";
}

main();
