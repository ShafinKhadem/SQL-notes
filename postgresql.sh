sudo apt install postgresql
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" # user=postgres password=postgres

# installing pgadmin4-web

# install apache2 and curl first
sudo apt install -y apache2 curl

#
# Install pgAdmin
#
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
# Install for web mode only:
sudo apt install -y pgadmin4-web && sudo /usr/pgadmin4/bin/setup-web.sh --yes

# Open the generated url (localhost/pgadmin4) in browser to open pgadmin

# Disable auto-boot
sudo systemctl disable postgresql apache2

# to start them after reboot
# sudo systemctl start postgresql apache2

xdg-open localhost/pgadmin4 &>/dev/null
# Add new server -> name:whatever -> Connection -> Host:localhost, username:postgres, password:postgres.
