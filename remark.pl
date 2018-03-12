#!/usr/bin/perl

use strict;
use warnings;

@ARGV == 1 or die "Usage: remark <markdown file>\n";

my $md_file = $ARGV[0];
my $out_file = $md_file;
$out_file =~ s/\.md$/.html/;
my $title = $md_file;
$title =~ s/\.md$//;

open OUT, ">$out_file" or die "unable to write to $out_file\n";
print_header($title);
print_content($md_file);
print_footer();
print "convert to remark, result in $out_file\n";

close OUT;

sub print_content {
    my $in = shift;
    open IN, $md_file or die "unable to open $md_file\n";
    while (<IN>) {
        print OUT $_;
    }
    close IN;
}

sub print_header {
  my $title = shift;

  my $header = <<END_HEADER;

<!DOCTYPE html>
<html>
  <head>
    <title>$title</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <style type="text/css">
      \@import url(https://fonts.googleapis.com/css?family=Yanone+Kaffeesatz);
      \@import url(https://fonts.googleapis.com/css?family=Droid+Serif:400,700,400italic);
      \@import url(https://fonts.googleapis.com/css?family=Ubuntu+Mono:400,700,400italic);

      body { font-family: 'Droid Serif'; }
      h1, h2, h3 {
        font-family: 'Yanone Kaffeesatz';
        font-weight: normal;
      }
      .remark-code, .remark-inline-code { font-family: 'Ubuntu Mono'; }
      .hljs-github table, th, td {
        vertical-align: bottom;
        padding: 10px;
      }
      .hljs-github th {
        text-align: left;
        border-bottom: 4px solid black;
      }
      .hljs-github tr:nth-child(even) {
        background-color: #f2f2f2;
      }
    </style>
  </head>
  <body>
    <textarea id="source">

class: center, middle

END_HEADER

  print OUT $header;
}

sub print_footer {

  my $footer = <<END_FOOTER;

    </textarea>
    <script src="https://remarkjs.com/downloads/remark-latest.min.js" type="text/javascript">
    </script>
    <script type="text/javascript">
      var slideshow = remark.create({
        ratio: '16:9',
        highlightStyle: 'github'
      });
    </script>
  </body>
</html>
END_FOOTER

  print OUT $footer;
}


