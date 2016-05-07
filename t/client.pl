use strict;
use warnings;

use lib '../lib/perl/';

use Test::More tests => 6;
use Test::Exception;


use Client;
use Scalar::Util qw(looks_like_number);

ok(defined Client::GetFreeSpaceMB());
ok(looks_like_number(Client::GetFreeSpaceMB()));

dies_ok(sub{Client::GetCertificate(undef)});
dies_ok(sub{Client::GetCertificate('asd', '/some_long_and_hardly_existing_top_level_dir_somethingsomething');});

ok(Client::GenerateChecksum('a', 'a') eq Client::GenerateChecksum('a', 'a'));
ok(Client::GenerateChecksum('asd', 'a') ne Client::GenerateChecksum('a', 'a'));
