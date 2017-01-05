#!/usr/bin/env bash

COMPOSER_COMMAND=$(which "composer")
if [ "$COMPOSER_COMMAND" = '' ]
then
	#No global composer found, try local or download it
	if [ -e "composer.phar" ]
	then
		echo "Composer found: checking for update"
	else
		echo "Composer not found: fetching"
		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
		php composer-setup.php
		php -r "unlink('composer-setup.php');"
	fi

	COMPOSER_COMMAND="php composer.phar"
else
	echo "Global composer found: checking for update"
fi

#Make sure we are on the latest composer
$COMPOSER_COMMAND self-update

REPODIR=`git rev-parse --show-toplevel`

#Redump the autoloader
echo
echo "Regenerating autoloader"
$COMPOSER_COMMAND dump-autoload -d $REPODIR

files=`git diff --name-only`
composerfile=false
for file in $files
do
    if [[ $file == lib/composer/* ]]
    then
        composerfile=true
        break
    fi
done

echo
if [ $composerfile = true ]
then
    echo "The autoloader is not up to date"
    echo "Please run: bash build/autoloaderchecker.sh"
    echo "And commit the result"
    exit 1
else
    echo "Autoloader up to date. Carry on"
    exit 0
fi
