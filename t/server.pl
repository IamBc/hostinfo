use strict;
use warnings;

use lib '../lib/perl/';

use Test::More tests => 1;
use Test::Exception;


use Server;
use Client;
use Scalar::Util qw(looks_like_number);

ok(Server::ValidateChecksum( Client::GenerateChecksum('a', 'a'), 'a', 'a'));
#TODO Test GetFreeSpaceMB
#TODO Test returned JSON structure
