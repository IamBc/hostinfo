package Client;
use strict;
use warnings;

use JSON;
use Digest::SHA;
use Try::Tiny;
use Getopt::Long;
use HTTP::Tiny;

use Data::Dumper;

# Example call:
# sudo perl client.pl --psk asd --cert_file_name ssh_host_rsa_key.pub --server_url "http://127.0.0.1:8010/server/api.pl"

sub GenerateChecksum($$)
{
    my ($payload, $psk) = @_;

    if(!defined $payload || !defined $psk)
    {
        die("Undefined param!");
    }

    return Digest::SHA::hmac_sha256_base64($payload, $psk);
}

sub GetCertificate($;$)
{
    my ($cert_name, $cert_dir) = @_;

    if(!defined $cert_name)
    {
        die("Undefined param!");
    }

    $cert_dir = $cert_dir // '/etc/ssh/';

    print "getting cert file from: ", $cert_dir.$cert_name, "\n";
    my ($fh, $payload);
    open $fh, $cert_dir.$cert_name or die "Couldn't open file: $!";
    while (<$fh>){
         $payload .= $_;
    }
    close $fh;
    return $payload;
}

sub GetFreeSpaceMB()
{
    my $free_space_mb = `df -m / | grep -v '^Filesystem' | awk 'NF=6{print \$4}NF==5{print \$3}{}'`;
    if ( $? == -1 )
    {
        die($!);
    }
    return $free_space_mb;
}


sub Handler()
{
    try
    {
        my ($name, $psk, $server_url); # psk => pre_shared_key
        GetOptions ("psk=s" => \$psk,
                    "cert_file_name=s"   => \$name,
                    "server_url=s" => \$server_url)
        or die("Error in command line arguments\n");

        print "psk: $psk", "\n";
        print "name: $name", "\n";
        print "server_url: $server_url", "\n";

        print "Fetching the free space...\n";
        my $free_space_mb = GetFreeSpaceMB();
        print "Fetching the certificate...\n";
        my $root_pub_key = GetCertificate($name);
        print "Generating the checksum...\n";
        my $checksum = GenerateChecksum("$root_pub_key$free_space_mb", $psk);

        #Send to server
        my $http =  HTTP::Tiny->new;
        my $resp = $http->post($server_url, { headers => {'Content-Type' => 'application/json'},
                                             content => to_json({checksum => $checksum, free_space_mb => $free_space_mb, root_pub_key => $root_pub_key}),
                                           });
        my $resp_status = '';
        try
        {
            my $req_status = from_json($$resp{content});
            $$req_status{status} = $$req_status{status} // 'null';
            $$req_status{code} = $$req_status{code} // 'null';
            $resp_status = "Code: $$req_status{code} Status: $$req_status{status}";
        }
        catch
        {
           $resp_status =  $$resp{content};
        };
        print "Resp: ", $resp_status, "\n";

    }
    catch
    {
        my ($err) = @_;
        print "An error has occured when executing the script: ", $err, "\n";
    };
}

1;
