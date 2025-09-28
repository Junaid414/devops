#!/bin/bash

# Deploy Sample HTML Page with Apache on Linux Localhost
# This script automates the installation and setup of Apache web server

echo "========================================="
echo "Apache Web Server Deployment Script"
echo "========================================="

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "This script needs to be run with sudo privileges"
        echo "Usage: sudo bash deploy_apache.sh"
        exit 1
    fi
}

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        echo "Unable to detect Linux distribution"
        exit 1
    fi
}

# Function to install Apache based on distribution
install_apache() {
    echo "Installing Apache web server..."
    
    case $DISTRO in
        ubuntu|debian)
            apt update
            apt install -y apache2
            APACHE_SERVICE="apache2"
            WEB_ROOT="/var/www/html"
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf install -y httpd
            else
                yum install -y httpd
            fi
            APACHE_SERVICE="httpd"
            WEB_ROOT="/var/www/html"
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    echo "Apache installed successfully!"
}

# Function to create sample HTML page
create_sample_html() {
    echo "Creating sample HTML page..."
    
    cat > $WEB_ROOT/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Apache Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 600px;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .success {
            color: #28a745;
            font-size: 18px;
            margin-bottom: 20px;
        }
        .info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border-left: 4px solid #007bff;
        }
        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 14px;
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .status-item {
            background: #e9ecef;
            padding: 15px;
            border-radius: 5px;
        }
        .status-item h3 {
            margin: 0 0 10px 0;
            color: #495057;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Apache Web Server Successfully Deployed!</h1>
        <div class="success">
            Your Apache web server is now running on localhost
        </div>
        
        <div class="info">
            <h3>Server Information</h3>
            <div class="status-grid">
                <div class="status-item">
                    <h3>Server Status</h3>
                    <p>✅ Active and Running</p>
                </div>
                <div class="status-item">
                    <h3>Access URL</h3>
                    <p><strong>http://localhost</strong></p>
                </div>
                <div class="status-item">
                    <h3>Document Root</h3>
                    <p>/var/www/html</p>
                </div>
                <div class="status-item">
                    <h3>Default Port</h3>
                    <p>80</p>
                </div>
            </div>
        </div>
        
        <div class="info">
            <h3>Useful Commands</h3>
            <ul style="text-align: left;">
                <li><code>sudo systemctl status apache2</code> - Check Apache status</li>
                <li><code>sudo systemctl restart apache2</code> - Restart Apache</li>
                <li><code>sudo systemctl reload apache2</code> - Reload configuration</li>
                <li><code>sudo tail -f /var/log/apache2/access.log</code> - View access logs</li>
            </ul>
        </div>
        
        <div class="footer">
            <p>Deployed on: <span id="datetime"></span></p>
            <p>Apache Web Server on Linux</p>
        </div>
    </div>
    
    <script>
        document.getElementById('datetime').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF
    
    # Set proper permissions
    chown www-data:www-data $WEB_ROOT/index.html 2>/dev/null || chown apache:apache $WEB_ROOT/index.html 2>/dev/null
    chmod 644 $WEB_ROOT/index.html
    
    echo "Sample HTML page created at: $WEB_ROOT/index.html"
}

# Function to configure Apache
configure_apache() {
    echo "Configuring Apache web server..."
    
    # Enable Apache to start on boot
    systemctl enable $APACHE_SERVICE
    
    # Start Apache service
    systemctl start $APACHE_SERVICE
    
    # Check if Apache is running
    if systemctl is-active --quiet $APACHE_SERVICE; then
        echo "Apache is running successfully!"
    else
        echo "Failed to start Apache. Checking status..."
        systemctl status $APACHE_SERVICE
        exit 1
    fi
}

# Function to configure firewall (if firewall is active)
configure_firewall() {
    echo "Configuring firewall..."
    
    # Check if ufw is available (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        ufw allow 'Apache Full' 2>/dev/null || ufw allow 80/tcp
        echo "Firewall configured for Apache (ufw)"
    
    # Check if firewalld is available (CentOS/RHEL/Fedora)
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-service=http
        firewall-cmd --reload
        echo "Firewall configured for Apache (firewalld)"
    
    # Check if iptables is available
    elif command -v iptables &> /dev/null; then
        iptables -A INPUT -p tcp --dport 80 -j ACCEPT
        # Save iptables rules (method varies by distribution)
        if command -v iptables-save &> /dev/null; then
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /etc/sysconfig/iptables 2>/dev/null
        fi
        echo "Firewall configured for Apache (iptables)"
    else
        echo "No firewall detected or already configured"
    fi
}

# Function to create additional sample pages
create_additional_pages() {
    echo "Creating additional sample pages..."
    
    # Create a simple about page
    cat > $WEB_ROOT/about.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - Apache Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .nav { margin-bottom: 20px; }
        .nav a { margin-right: 15px; text-decoration: none; color: #007bff; }
        .nav a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/about.html">About</a>
            <a href="/contact.html">Contact</a>
        </div>
        <h1>About Apache Web Server</h1>
        <p>Apache HTTP Server is a free and open-source cross-platform web server software.</p>
        <p>It has been the most popular web server software since April 1996.</p>
        <ul>
            <li>Cross-platform compatibility</li>
            <li>Modular architecture</li>
            <li>Extensive configuration options</li>
            <li>Strong security features</li>
        </ul>
    </div>
</body>
</html>
EOF

    # Create a simple contact page
    cat > $WEB_ROOT/contact.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact - Apache Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .nav { margin-bottom: 20px; }
        .nav a { margin-right: 15px; text-decoration: none; color: #007bff; }
        .nav a:hover { text-decoration: underline; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/about.html">About</a>
            <a href="/contact.html">Contact</a>
        </div>
        <h1>Contact Information</h1>
        <p>This is a demo contact page for your Apache web server.</p>
        <form>
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" id="name" name="name">
            </div>
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email">
            </div>
            <div class="form-group">
                <label for="message">Message:</label>
                <textarea id="message" name="message" rows="4"></textarea>
            </div>
            <button type="submit">Send Message</button>
        </form>
    </div>
</body>
</html>
EOF

    # Set proper permissions for additional pages
    chown www-data:www-data $WEB_ROOT/about.html $WEB_ROOT/contact.html 2>/dev/null || chown apache:apache $WEB_ROOT/about.html $WEB_ROOT/contact.html 2>/dev/null
    chmod 644 $WEB_ROOT/about.html $WEB_ROOT/contact.html
    
    echo "Additional sample pages created!"
}

# Function to display final information
display_info() {
    echo ""
    echo "========================================="
    echo "✅ DEPLOYMENT COMPLETED SUCCESSFULLY!"
    echo "========================================="
    echo ""
    echo "🌐 Your Apache web server is now running!"
    echo ""
    echo "📍 Access your website at:"
    echo "   http://localhost"
    echo "   http://127.0.0.1"
    echo "   http://$(hostname -I | awk '{print $1}') (from other devices on network)"
    echo ""
    echo "📁 Web files location: $WEB_ROOT"
    echo ""
    echo "📄 Available pages:"
    echo "   • http://localhost/ (main page)"
    echo "   • http://localhost/about.html"
    echo "   • http://localhost/contact.html"
    echo ""
    echo "🔧 Useful commands:"
    echo "   • sudo systemctl status $APACHE_SERVICE   (check status)"
    echo "   • sudo systemctl restart $APACHE_SERVICE  (restart server)"
    echo "   • sudo systemctl stop $APACHE_SERVICE     (stop server)"
    echo "   • sudo systemctl start $APACHE_SERVICE    (start server)"
    echo ""
    echo "📊 Log files:"
    echo "   • Access log: /var/log/apache2/access.log (Ubuntu/Debian) or /var/log/httpd/access_log (CentOS/RHEL)"
    echo "   • Error log:  /var/log/apache2/error.log (Ubuntu/Debian) or /var/log/httpd/error_log (CentOS/RHEL)"
    echo ""
    echo "🎉 Happy coding!"
}

# Main execution
main() {
    check_root
    detect_distro
    
    echo "Detected distribution: $DISTRO"
    echo ""
    
    install_apache
    create_sample_html
    create_additional_pages
    configure_apache
    configure_firewall
    display_info
}

# Run the main function
main "$@"