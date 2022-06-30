sudo apt install postgresql dbeaver-ce

# make user=postgres password=postgres
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Disable auto-boot
sudo systemctl disable postgresql
# to start it after reboot:
# sudo systemctl start postgresql   # have to use service when systemctl is unavailable e.g. in WSL
