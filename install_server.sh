echo "Installing the perl modules..."
cpan -i JSON
cpan -i Try::Tiny
cpan -i HTTP::Tiny
cpan -i DBI
cpan -i Test::Simple

echo "Creating the databse..."
sudo su postgres -c 'psql -c "CREATE DATABASE host_info;"'
echo "Creating the tables..."
sudo su postgres -c 'psql -d host_info  -f ./db/schema.sql'
echo "Creating the user..."
sudo su postgres -c 'psql -d host_info  -f ./db/permissions.sql'

echo "Done. You should finish by filling the apache configuration template."
