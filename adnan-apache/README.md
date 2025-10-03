# My Project

This is my project for the Apache & Git task.
## How to install Apache on your system:
1. Install Apache on Ubuntu/Linux
    sudo apt update
    sudo apt install apache2 -y

2. Start Apache and enable it to run at boot:
    sudo systemctl start apache2
    sudo systemctl enable apache2

3. Check if Apache is running:
    systemctl status apache2
    Visit:http://localhost/
    
## How to run this project on Apache:

1. Copy the project folder to Apache’s root directory:

    sudo cp -r ~/adnan-apache /var/www/html/
    Note: ~/adnan-apache add this path correctly according to your current directory

2. Set correct ownership and permissions so Apache can access it:

    sudo chown -R www-data:www-data /var/www/html/adnan-apache
    sudo chmod -R 755 /var/www/html/adnan-apache

3. Open your web browser and go to:

    http://localhost/adnan-apache/
