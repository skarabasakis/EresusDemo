#!/bin/bash

# Paths
hostPath="."
sitePath="eresusdemo"

# Site
siteDomain="eresusdemo.karabasakis.net"
siteName="Eresus Demo"
siteSlogan="Because Drupal rocks but I don't..."
siteLocale="en"

# Database (assuming MySQL)
dbHost="localhost"
dbName="eresusdemo"
dbUser="www"
dbPassword=`cat .mysql_password | tr -d '\n'`

# Admin
AdminUsername="admin"
AdminPassword="admin"   # initial password. Remember to change this later.
adminEmail="admin@$siteDomain"

# Prepare the database (assumes CREATE privilege for dbUser)
mysql -u $dbUser -p$dbPassword -e "CREATE DATABASE $dbName";

# Download Core
##########################################################
drush dl drupal -y --use-site-dir=$hostPath --drupal-project-rename=$siteDomain;

cd $hostPath/$siteDomain;

# Install core
##########################################################
drush -y site-install standard \
  --account-mail=$adminEmail --account-name=$AdminUsername \
  --account-pass=$AdminPassword --site-name=$siteName --site-mail=$adminEmail \
  --locale=$siteLocale --db-url=mysql://$dbUser:$dbPassword@$dbHost/$dbName;

# Modules and themes
##########################################################

# Core modules to be disabled
core_modules_disabled=" color shortcut search ";

contrib_modules_enabled="";
contrib_modules_not_enabled="";

# Contrib modules to add to project.
# Comment out modules that are not needed.
# Use not_enabled to install a module but keep it disabled
contrib_modules_enabled+=" devel devel_generate module_builder coder coder_review";
contrib_modules_enabled+=" ctools";
contrib_modules_not_enabled=" token";
contrib_modules_enabled+=" menu_block ";
contrib_modules_enabled+=" views views_ui views_bulk_operations";
contrib_modules_enabled+=" panels ";
contrib_modules_enabled+=" pathauto ";

# Contrib modules to add to project.
# Comment out modules that are not needed.
contrib_modules_enabled+=" omega ohm ";
default_theme_name="ohm";

drush -y dis $core_modules_disabled;
drush -y dl --destination="sites/default/modules/contrib" $contrib_modules_enabled $contrib_modules_not_enabled
drush -y en $contrib_modules_enabled
drush -y vset theme_default $default_theme_name

# Pre configure settings
##########################################################
drush vset -y site_slogan $siteSlogan; # set site slogan
drush vset -y user_pictures 0;         # disable user pictures
drush vset -y user_register 0;         # allow only admins to register users

# Generate dummy content
##########################################################
drush -y gent tags 500;  # Generate 500 tags
drush -y genc 950;       # Generate 990 posts
# Generate 50 posts with some time difference
for i in {1..10}; do drush -y genc 1 5; sleep 10; done;
