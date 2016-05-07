use strict;
use warnings;

use JSON;
use Digest::SHA;
use Try::Tiny;
use Getopt::Long;
use HTTP::Tiny;

use Data::Dumper;

use lib '../lib/perl';
use Client;

Client::Handler();
