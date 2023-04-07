# AutoWP

This script is a bash script that automates the installation of WordPress, Apache2, MySQL, and PHP on Ubuntu. (JAPANESE)

Copyright (c) 2023 Marina Suzuki

This software is released under the MIT license

https://opensource.org/licenses/mit-license.php

The script collects necessary information from the user, such as domain name, database name, database user name, database password, site name, admin username, admin password, and admin email address, and installs WordPress using this information.
The script starts by displaying a welcome message and then prompts the user for the necessary information using the read command. The information collected includes the user's domain name, the database name, the database user name, the database password, the site name, the admin username, the admin password, and the admin email address. The script also asks the user whether they want to enable SSL for their site.
After collecting the necessary information, the script displays the collected information for the user to confirm. If the user confirms the installation, the script proceeds with the installation process.
The installation process involves the following steps:
1. Installing Apache2: The script updates the package list and installs the Apache2 package.
2. Configuring Apache2 Virtual Host: The script creates a directory for the site and sets the correct permissions. It then copies the default Apache2 configuration file and modifies it to use the site's domain name. Finally, it enables the new virtual host and disables the default virtual host.
3. Enabling SSL (optional): If the user chooses to enable SSL, the script installs the Let's Encrypt Certbot package and obtains an SSL certificate for the site. It then creates a new virtual host configuration file that includes the necessary SSL configuration.
4. Installing MySQL: The script installs the MySQL package and sets the root password for the MySQL server.
5. Creating MySQL Database and User: The script creates a new MySQL database and a new user with the necessary permissions to access the database.
6. Installing PHP and Required Modules: The script installs PHP and the required modules for WordPress.
7. Downloading and Installing WordPress: The script downloads the latest version of WordPress and installs it in the appropriate directory.
8. Configuring WordPress: The script creates a new WordPress configuration file with the information provided by the user during the setup process. It then modifies the WordPress configuration file to use the newly created MySQL database and user.
The script also creates a log file called wordpress_settings.log that contains all the information provided by the user during the setup process.
Overall, the script automates the installation of WordPress, Apache2, MySQL, and PHP on Ubuntu and makes it easy for users to set up their WordPress sites without having to manually install and configure all the necessary software.

