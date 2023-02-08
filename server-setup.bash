# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
touch ~/.ssh/config
nano ~/.ssh/config

# Add the following to the config file:
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519

# Add to the agent
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub

# Copy the output to GitHub and add as an access key.

# Test connection
sudo chmod 600 ~/.ssh/config
ssh -T git@github.com

# Install git and clone
yum install git
git clone git@github.com:username/nea

# Install dotnet
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
sudo yum install dotnet-sdk-6.0
sudo yum install aspnetcore-runtime-6.0
sudo yum install libicu60
dotnet --version

# Run the project
sudo dotnet publish ./nea/LanguagesServer/Languages --configuration Release -o /var/www/languages
dotnet /var/www/languages/Languages.dll

# Configure the web server
cd /etc/httpd/
sudo chmod 555 conf.d
cd conf.d
sudo touch confirguration.conf

# Fill with
<VirtualHost *:*>
    RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
</VirtualHost>

<VirtualHost *:443>
    Protocols             h2 http/1.1 
    ProxyPreserveHost     On
    ProxyPass             / http://127.0.0.1:5000/
    ProxyPassReverse      / http://127.0.0.1:5000/
    ErrorLog              /var/log/httpd/languages-error.log
    CustomLog             /var/log/httpd/languages-access.log common
    SSLEngine             on
    SSLProtocol           all -SSLv3 -TLSv1 -TLSv1.1
    SSLHonorCipherOrder   off
    SSLCompression        off
    SSLSessionTickets     on 
    SSLUseStapling        off
    SSLCertificateFile    /etc/pki/tls/certs/localhost.crt
    SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
    SSLCipherSuite        ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:$
</VirtualHost>

# Check syntax
sudo apachectl configtest

sudo systemctl restart httpd
sudo systemctl enable httpd

# Configure apache to manage the dotnet lifecycle
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo nano /etc/systemd/system/kestrel-languages.service

# Fill the service config file
[Unit]
Description=The API for the Languages web and iOS apps

[Service]
WorkingDirectory=/var/www/languages
ExecStart=/usr/bin/dotnet /var/www/languages/Languages.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-languages
User=apache
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target

# Enable the service
sudo systemctl enable kestrel-languages.service
sudo systemctl restart kestrel-languages

# Configure the SSL certificate
sudo yum install mod_ssl
sudo yum install python3 augeas-libs
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-apache
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
sudo certbot --apache

# Restarting the server with a new version
cd nea
git pull
cd
sudo dotnet publish ./nea/LanguagesServer/Languages --configuration Release -o /var/www/languages
sudo systemctl restart kestrel-languages
