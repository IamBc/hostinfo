package Server;

use strict;
use warnings;

use CGI;
use DBI;
use Digest::SHA;
use HTTP::Tiny;
use DBI;
use Data::Dumper;
use JSON;
use Try::Tiny;

sub Handler()
{
    my $cgi = CGI->new();
    print $cgi->header();

    my $req = {};
    try
    {
        $req = from_json($cgi->param('POSTDATA'));
    }
    catch
    {
        print '{"status":"Bad request!", "code":"001"}';
        die;
    };

    print STDERR Dumper $req;

    try
    {
        ValidateChecksum($$req{checksum}, $ENV{PSK}, "$$req{root_pub_key}$$req{free_space_mb}");
    }
    catch
    {
        print '{"status":"Bad checksum!", "code":"002"}';
        die;
    };

    try
    {
        SaveHostInfo($ENV{REMOTE_ADDR}, $$req{free_space_mb}, $$req{root_pub_key});
    }
    catch
    {
        print '{"status":"Internal error.", "code":"003"}';
        die;
    };

    print '{"status":"ok", "code":"000"}';
}


sub SaveHostInfo($$$)
{
    my ($primary_ip, $free_space_mb, $root_pub_key) = @_;

    if(!defined $primary_ip || !defined $free_space_mb || !defined $root_pub_key)
    {
        die;
    }

    if(!defined $ENV{DB_CONN_STRING} || !defined $ENV{DB_PASS} || !defined $ENV{DB_USER})
    {
        print STDERR "Missing configuration variables!";
        die;
    }

    my $dbh = DBI->connect( $ENV{DB_CONN_STRING}, $ENV{DB_USER}, $ENV{DB_PASS},{ RaiseError => 1}) or die $!;

    my $sth = $dbh->prepare("INSERT INTO host_info(root_ssh_pub_key, primary_ip, free_space_mb) VALUES(?, ?, ?);");
    $sth->execute($root_pub_key, $primary_ip, $free_space_mb) or die();
    #$dbh->disconnect();
}

sub ValidateChecksum($$$)
{
    my ($checksum, $psk, $payload) = @_;

    if(!defined $checksum || !defined $psk || !defined $payload)
    {
        print STDERR "checksum: ", $checksum, " psk: ", $psk, " payload: ", $payload, "\n";
        die;
    }

    my $real_checksum = Digest::SHA::hmac_sha256_base64($payload, $psk);
    if($real_checksum ne $checksum)
    {
        print STDERR "sent checksum: ", $checksum, " generated checksum: ", $real_checksum, "\n";
        die;
    }
    return 1;
}

1;
