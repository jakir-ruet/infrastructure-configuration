# Update package lists
sudo apt update

# Install required dependencies
sudo apt install -y wget gnupg2 lsb-release

# Add the PostgreSQL signing key
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update package lists again to include PostgreSQL packages
sudo apt update

# Install PostgreSQL 16
sudo apt install -y postgresql-16
