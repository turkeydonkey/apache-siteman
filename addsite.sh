#!/bin/bash

WRITE_TO=""
SITES_AVAILABLE='/etc/apache2/sites-available'
SITES_ENABLED='/etc/apache2/sites-enabled'
SITES_DIR='/home/donkey/sites'

function chkreturn () {
  if [ $1 -ne 0 ]
    then
      exit 1
  fi
}

while getopts ":t" optionName; do
  case "$optionName" in
    t) WRITE_TO="1";;
   \?) echo "Invalid option: -$OPTARG" >&2
       echo "Usage: addsite [-t] sitename.tld"
       exit 1;;
  esac
done

shift $(($OPTIND - 1))
SITE=$1

if [ -z "$WRITE_TO" ]
  then
    WRITE_TO="> $SITES_AVAILABLE/$SITE"
  else
    WRITE_TO=""
fi

if [ -n "$SITE" ]
  then
    eval /bin/sed s/'SITENAME'/"$SITE"/g $SITES_AVAILABLE/template-namevhost $WRITE_TO
    if [ $? -ne 0 ]
      then
        echo "ERROR: *Failed to create $SITES_AVAILABLE/$SITE*"
        exit 2
    fi

    (cd $SITES_ENABLED; ln -sf "../sites-available/$SITE" $SITE)

    mkdir -p $SITES_DIR/$SITE/www
    apache2ctl configtest 

      if [ $? -ne 0 ]
        then
          echo "$SITES_AVAILABLE/$SITE is broken! Aborting..."
          exit 2
      fi
    apache2ctl restart
  else
    echo "Usage: addsite [-t] sitename.tld"
    exit 1
fi
