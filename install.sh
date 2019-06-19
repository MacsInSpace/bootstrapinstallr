#!/bin/bash

#credits
#https://github.com/munki/bootstrappr
#https://github.com/munki/installr
#https://stackoverflow.com/questions/8350942/how-to-re-run-the-curl-command-automatically-when-the-error-occurs
#https://coderwall.com/p/ftrahg/install-all-the-dmg-s
#https://apple.stackexchange.com/questions/73926/is-there-a-command-to-install-a-dmg

# USAGE
#Run the following from recovery
#The second argument is a list of DMGs or PKGs that you want on the 'image'

# curl https://raw.githubusercontent.com/MacsInSpace/bootstrapinstallr/master/install.sh | bash -s  http://Link.To.Install.local/list.txt




#Intall from this list.....
linklist=$1

function with_backoff {
  local max_attempts=${ATTEMPTS-5}
  local timeout=${TIMEOUT-1}
  local attempt=1
  local exitCode=0

  while (( $attempt < $max_attempts ))
  do
    if "$@"
    then
      return 0
    else
      exitCode=$?
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "You've failed me for the last time! ($@)" 1>&2
  fi

  return $exitCode
}

function install_from_dmg () {
    URL="${1}"
    MOUNT="${URL##*/}"
    uuidgen=`uuidgen`
    TEMP=/tmp/${uuidgen}
    MOUNT_PATH=${TEMP}/mount
    mkdir -p ${TEMP}
    mkdir -p ${MOUNT_PATH}

    pushd /tmp > /dev/null

    echo "Downloading ${URL}"
    with_backoff curl -L "${URL}" -s -o ${TEMP}/app.dmg --connect-timeout 20 2>&1
    
    echo "Mounting ${MOUNT_PATH}"
    Yes | /usr/bin/hdiutil attach ${TEMP}/app.dmg -noverify -nobrowse -mountpoint "${MOUNT_PATH}" > /dev/null 

    MPKG_PATH="$(find "${MOUNT_PATH}" -name "*.mpkg" ! -name "*readme*" ! -name "*read me*" ! -name "*ReadMe*" ! -name "*Read Me*" ! -name "*uninstall*" ! -name "*Uninstall*" -maxdepth 1 2> /dev/null || echo "")"
    PKG_PATH="$(find "${MOUNT_PATH}" -name "*.pkg" ! -name "*readme*" ! -name "*read me*" ! -name "*ReadMe*" ! -name "*Read Me*" ! -name "*uninstall*" ! -name "*Uninstall*" -maxdepth 1 2> /dev/null || echo "")"
    APP_PATH="$(find "${MOUNT_PATH}" -name "*.app" ! -name "*readme*" ! -name "*read me*" ! -name "*ReadMe*" ! -name "*Read Me*" ! -name "*uninstall*" ! -name "*Uninstall*" -maxdepth 1 2> /dev/null || echo "")"
    APP_NAME="$(ls "${MOUNT_PATH}" | grep ".app$" || echo "")"

    if
        [ "${APP_PATH}" != "" ]
    then
        echo "Rsync app to /Applications/${APP_NAME}"
        #rsync -av "${APP_PATH}/" "/Applications/${APP_NAME}/"
        #cp -pPR "${APP_PATH}" "/Applications/"
        ditto -rsrc "${APP_PATH}" "/Applications/${APP_NAME}"
    elif
        [ "${MPKG_PATH}" != "" ]
    then
        install_from_pkg "${MPKG_PATH}"
    elif
        [ "${PKG_PATH}" != "" ]
    then
        install_from_pkg "${PKG_PATH}"
    else
        abort "No app or pkg found for ${MOUNT}"
    fi

    sleep 5

    echo "Unmounting ${MOUNT_PATH}"
    hdiutil unmount "${MOUNT_PATH}"

    echo "Removing DMG"
    rm -rf app.dmg
    rm -rf ${MOUNT_PATH}
    rm -rf $TEMP
    popd > /dev/null
}

function install_from_pkg () {
    echo "Install package ${1}"
    installer -package "${1}" -target "/"
}


function install_direct_from_pkg () {
    echo "Install direct from package ${1}"
    URL="${1}"
    MOUNT="${URL##*/}"
    uuidgen=`uuidgen`
    TEMP=/tmp/${uuidgen}
    mkdir -p ${TEMP}

    pushd /tmp > /dev/null

    echo "Downloading ${URL}"
    with_backoff curl -L "${URL}" -s -o ${TEMP}/app.pkg --connect-timeout 20 2>&1
    
    PKG_PATH="${TEMP}/app.pkg"
    install_from_pkg "${PKG_PATH}"
    
    echo "Removing PKG"
    rm -rf app.pkg
    rm -rf $TEMP
    popd > /dev/null
}


#Search for link
function search_page_for_link () {
curl -s $i | \
    # Filter hyperlinks
    egrep -o 'href="http[^"]://[^"]+\.(dmg|pkg)"' | \
    egrep -o 'http[^"]://[^"]+' | \
    sort -t. -rn -k1,1 -k2,2 -k3,3 | head -1
    if [ "${i##*.}" = dmg ]
        then
        echo "${i##*.}"
          install_from_dmg $i
        elif [ "${i##*.}" = pkg ]
        then
        echo "${i##*.}"
          install_direct_from_pkg $i
        else
          echo "No .dmg or .pkg file linked."
        fi

}


xIFS=$IFS
    IFS=$'\n'
    for i in $(curl "${linklist}")
     do
        if [ "${i##*.}" = dmg ]
        then
        echo "${i##*.}"
          install_from_dmg $i
        elif [ "${i##*.}" = pkg ]
        then
        echo "${i##*.}"
          install_direct_from_pkg $i
        else
          echo "Not a .dmg or .pkg file linked. Searching page..."
          search_page_for_link
        fi
    done;
IFS=$xIFS
