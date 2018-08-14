#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\

echo "Restauration des préférences"
# Sélection du service de cloud (à décommenter si vous n'utilisez pas Dropbox, c'est le service par défaut) : https://github.com/lra/mackup/blob/master/doc/README.md
# echo -e "[storage]\nengine = google_drive" >> ~/.mackup.cfg

# Récupération de la sauvegarde sans demander à chaque fois l'autorisation
mackup restore -f

# Enregistrement des copies d'écran sur Dropbox
defaults write com.apple.screencapture location -string “$HOME/Dropbox/Captures/MB12”

echo "Configuration de unbound"
sudo mv /usr/local/etc/unbound/unbound.conf /usr/local/etc/unbound/unbound.conf.bak
sudo cp -r ~/Dropbox/conf_macbook/unbound/ /usr/local/etc/unbound/

#Doing following commands to add the user unbound missing with brew installation
sudo dscl . -create /Groups/_unbound
sudo dscl . -create /Groups/_unbound PrimaryGroupID 451
sudo dscl . -create /Users/_unbound
sudo dscl . -create /Users/_unbound RecordName _unbound unbound
sudo dscl . -create /Users/_unbound RealName "Unbound DNS server"
sudo dscl . -create /Users/_unbound UniqueID 451
sudo dscl . -create /Users/_unbound PrimaryGroupID 451
sudo dscl . -create /Users/_unbound UserShell /usr/bin/false
sudo dscl . -create /Users/_unbound Password '*'
sudo dscl . -create /Groups/_unbound GroupMembership _unbound

sudo brew services restart unbound

#SET DNS SERVER
sudo networksetup -setdnsservers Wi-Fi 172.16.72.180 127.0.0.1

echo "Configuration de apache"
sudo rm -f /etc/apache2/httpd.conf
sudo ln -s ~/Dropbox/conf_macbook/httpd.conf /etc/apache2/httpd.conf

echo "Installation du switcher pour PHP"
sudo curl -L https://gist.githubusercontent.com/rhukster/f4c04f1bf59e0b74e335ee5d186a98e2/raw > /usr/local/bin/sphp
sudo chmod +x /usr/local/bin/sphp

#Installation de APCu pour toutes les versions de PHP
sphp 5.6
brew install autoconf
pecl channel-update pecl.php.net
pecl install apcu-4.0.11

sphp 7.0
pecl uninstall -r apcu
pecl install apcu

sphp 7.1
pecl uninstall -r apcu
pecl install apcu

sphp 7.2
pecl uninstall -r apcu
pecl install apcu

sudo apachectl -k stop
sudo apachectl start

#Librairie pour parser Yaml
sphp 5.6
brew install libyaml
pecl install yaml-1.3.1

sphp 7.0
pecl uninstall -r yaml
pecl install yaml

sphp 7.1
pecl uninstall -r yaml
pecl install yaml

sphp 7.2
pecl uninstall -r yaml
pecl install yaml

# Xdebug
sphp 5.6
pecl install xdebug-2.5.5
# Remove the first line of /usr/local/etc/php/5.6/php.ini refering to xdebug
# Create a new file /usr/local/etc/php/5.6/conf.d/ext-xdebug.ini with 
#[xdebug]
#zend_extension="xdebug.so"
#xdebug.remote_enable=1
#xdebug.remote_host=localhost
#xdebug.remote_handler=dbgp
#xdebug.remote_port=9000

echo "Installation du switch xdebug"
sudo curl -L https://gist.githubusercontent.com/rhukster/073a2c1270ccb2c6868e7aced92001cf/raw > /usr/local/bin/xdebug
sudo chmod +x /usr/local/bin/xdebug

#Afer this just repeat the Required Xdebug Configuration steps, with /usr/local/etc/php/7.0/php.ini as the PHP configuration file to remove the existing entry, and /usr/local/etc/php/7.0/conf.d/ext-xdebug.ini for the file you will create with the new Xdebug configuration.  
sphp 7.0
pecl uninstall -r xdebug
pecl install xdebug

sphp 7.1
pecl uninstall -r xdebug
pecl install xdebug

sphp 7.2
pecl uninstall -r xdebug
pecl install xdebug

#Installation de memcached
#git clone -b NON_BLOCKING_IO_php7 https://github.com/websupport-sk/pecl-memcache.git
#cd pecl-memcache
#phpize
#./configure
#make && make install
#Dans fichier php.ini ajouter l'extension, par ex: dans /usr/local/etc/php/7.0/php.ini ajouter extension="/Users/damien/Downloads/pecl-memcache/modules/memcache.so"

echo "Installation de oh-my-zsh"
# Installation de oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo ""
echo "ET VOILÀ !"
echo "Il est maintenant possible d'activer d'autres dossiers dans la synchronisation Dropbox."