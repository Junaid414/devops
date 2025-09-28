# DevOps Repository - Apache Web Server Deployment

This repository contains Apache web server deployment scripts and configurations for localhost deployment.

## 🚀 Apache Web Server Deployment

### Quick Deployment

Run the automated deployment script on Linux:

```bash
# Make the script executable
chmod +x deploy_apache.sh

# Run the script with sudo privileges
sudo bash deploy_apache.sh
```

### Features

- ✅ **Multi-Distribution Support**: Ubuntu/Debian/CentOS/RHEL/Fedora
- ✅ **Beautiful HTML Templates**: Responsive design with animations
- ✅ **Complete Firewall Configuration**: Automatic port 80 access setup
- ✅ **Security Best Practices**: Proper file permissions and ownership
- ✅ **Multiple Sample Pages**: Home, About, and Contact pages
- ✅ **Real-time Server Information**: Dynamic status display

### Access Your Website

After successful deployment, access your website at:
- **http://localhost** - Main homepage with server information
- **http://localhost/about.html** - About Apache web server
- **http://localhost/contact.html** - Contact form page

### Project Structure

```
task_devops/
├── deploy_apache.sh     # Main deployment script for Linux
├── deploy_to_linux.ps1  # PowerShell script for remote deployment
├── sample_index.html    # Professional HTML template
├── README.md           # This documentation file
├── adnan.txt           # Team member file
└── usman.txt           # Team member file
```

### Useful Commands

```bash
# Check Apache status
sudo systemctl status apache2

# Restart Apache service
sudo systemctl restart apache2

# Stop Apache service
sudo systemctl stop apache2

# Start Apache service
sudo systemctl start apache2

# View real-time access logs
sudo tail -f /var/log/apache2/access.log

# View real-time error logs
sudo tail -f /var/log/apache2/error.log
```

### Requirements

- Linux system (Ubuntu/Debian/CentOS/RHEL/Fedora)
- Root or sudo access
- Internet connection for package installation

### Manual Installation Steps

If you prefer manual installation:

1. **Update system packages**:
   ```bash
   sudo apt update && sudo apt upgrade -y  # Ubuntu/Debian
   sudo dnf update -y                      # Fedora/CentOS 8+
   ```

2. **Install Apache**:
   ```bash
   sudo apt install -y apache2             # Ubuntu/Debian
   sudo dnf install -y httpd               # Fedora/CentOS 8+
   ```

3. **Start and enable Apache**:
   ```bash
   sudo systemctl start apache2 && sudo systemctl enable apache2    # Ubuntu/Debian
   sudo systemctl start httpd && sudo systemctl enable httpd        # Fedora/CentOS
   ```

4. **Configure firewall**:
   ```bash
   sudo ufw allow 'Apache Full'            # Ubuntu/Debian
   sudo firewall-cmd --add-service=http --permanent && sudo firewall-cmd --reload  # Fedora/CentOS
   ```

### Troubleshooting

**Apache won't start?**
```bash
# Check configuration syntax
sudo apache2ctl configtest  # Ubuntu/Debian
sudo httpd -t               # CentOS/RHEL

# Check if port 80 is in use
sudo netstat -tlnp | grep :80
```

**Permission issues?**
```bash
# Fix file ownership
sudo chown -R www-data:www-data /var/www/html/  # Ubuntu/Debian
sudo chown -R apache:apache /var/www/html/      # CentOS/RHEL

# Set proper permissions
sudo chmod -R 644 /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
```

### Contributing

This is a collaborative DevOps learning repository. Feel free to:
- Add new deployment scripts
- Improve existing configurations  
- Share infrastructure automation tools
- Document best practices

### Team Members

- **Usman** - Apache Web Server Deployment
- **Adnan** - Team Collaborator
- **Junaid** - Repository Owner

---

**Happy DevOps Learning! 🎉**
