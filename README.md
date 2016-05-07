#HOST Info


## Installation

Depending on the part of the software you want to run (client or server) you should run `install_client.sh` or `install_server.sh`
They will create the db/install the perl modules.

The host should already have postgres, apache and perl(with cpan) installed.

## Client Configuration
The Client script is configured with command line parameters:
sudo perl client.pl --psk asd --cert_file_name ssh_host_rsa_key.pub --server_url

| Name    |      Description   | Example |
|----------|-------------|------|
| psk |  The pre shared key used in hmac generation |  sdasdad|
| cert_file_name |    The name of file in which the root public key is stored.   |   my_public_key |
| server_url | Url to the API end point. |    http://localhost:8010/a/api.pl |

Example call:
`sudo perl client.pl --psk asd --cert_file_name ssh_host_rsa_key.pub --server_url http://localhost:8010/a/api.pl`

## Server Configuration
The API is made to run under apache. You should replace the template parameters on the uploaded apache configuration: `apache.conf`
with the position where you've put the files. The ssl communication (https), logging and environment for the script should be configured via apache.

The server script requires information about the db in which it should connect and the psk it should use to validate the checksum.

These are the enviromnent variables you should set in the apache conf (replace them from the template:)

| Name    |      Description   | Example |
|----------|-------------|------|
| DB_CONN_STRING | Connection string to the db  | dbi:Pg:dbname=host_info;host=localhost |
| DB_USER |   DB user that the API will use  |  api_usr |
| DB_PASS | password to the db |  123  |
|PSK| pre shared key used in hmac generation | asd12 |

## API

The API is JSON based, over HTTP(S) using the POST method.
Currently there is only one method in the API Which registers a new host into the system.

Example request/response:

```
curl -v --header "Content-Type:application/json" --data '{"root_pub_key":"ssh-rsa myskey root@host", "checksum":"Kl09Abe/bb9uW9f9NcFMU4n/8sY7mHJXTWxy3GaqwBA", "free_space_mb":"22672267"}' http://localhost:8010/server/api.pl
* Hostname was NOT found in DNS cache
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 8010 (#0)
> POST /server/api.pl HTTP/1.1
> User-Agent: curl/7.35.0
> Host: localhost:8010
> Accept: */*
> Content-Type:application/json
> Content-Length: 129
> 
* upload completely sent off: 129 out of 129 bytes
< HTTP/1.1 200 OK
< Date: Sat, 07 May 2016 15:07:49 GMT
* Server Apache/2.4.7 (Ubuntu) is not blacklisted
< Server: Apache/2.4.7 (Ubuntu)
< Content-Length: 29
< Content-Type: text/html; charset=ISO-8859-1
< 
* Connection #0 to host localhost left intact
{"status":"ok", "code":"000"}
```

### API return codes
The api's response has 2 parts a status and a code. The status is a description of the code. 
Avaliable codes:

* 000 - request was processed successfully
* 001 - the request was wrong (missing param/wrong param). The request must be fixed, it shouldn't be retried.
* 002 - the checksum from the client is wrong. The request can be retried with a different checksum.
* 003 - there was an internal error. These errors can be retried
