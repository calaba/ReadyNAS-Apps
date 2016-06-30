#!/bin/sh

# =====
# ===== INPUT PARAMETERS
# =====

# LATEST_RELEASES SEE ... https://github.com/nzbget/nzbget/releases/latest
LATEST_NZB_GET_URL="https://github.com/nzbget/nzbget/releases/download/v17.0-r1726/nzbget-17.0-testing-r1726-bin-linux.run"

input=$1
if [ "${input}" = ""  ]; then
	echo
	echo "No Download URL specified, please check the URL https://github.com/nzbget/nzbget/releases/latest for available NZBGet versions!"
	echo
	echo "Please specify the Downlaod URL for NZBGet binary instaler (nzbget-VERSION-bin-linux.run)"
	echo "[default: ${LATEST_NZB_GET_URL}]"
	echo ":" 
	read input </dev/tty 
	if [ "${input}" = "" ]]; then
        	LATEST_NZB_GET_URL="$LATEST_NZB_GET_URL"
	else
        	LATEST_NZB_GET_URL="${input}"
	fi
else
	LATEST_NZB_GET_URL="${input}"
fi

LATEST_NZB_GET_FILE="${LATEST_NZB_GET_URL##*/}"

# =====
# ===== REPACKAGING DEFAULTS
# =====

# Original package name - withouth the ".deb" suffix 
BASE_PACKAGE_NAME="nzbget-app_1.0.4_all"
input=$2
input="${input%.deb}"
if [ "${input}" = ""  ]; then
        echo
        echo "No Base .deb package specified, please provide the .deb base package name (without the .deb extension)!"
        echo "(NZBGet base .deb package can be downloaded from: http://apt.readynas.com/packages/readynasos/dists/apps/pool/n/nzbget-app/nzbget-app_1.0.4_all.deb)"
        echo 
        echo "[default: ${BASE_PACKAGE_NAME}]"
        echo ":"
        read input </dev/tty
        if [ "${input}" = "" ]]; then
                BASE_PACKAGE_NAME="$BASE_PACKAGE_NAME"
        else
                BASE_PACKAGE_NAME="${input}"
        fi
else
        BASE_PACKAGE_NAME="${input}"
fi

if [! -f "${BASE_PACKAGE_NAME}" ]; then
	echo
	echo "ERROR: Base .deb package (${BASE_PACKAGE_NAME}) not found!"
	exit 1
fi


#arch_x86_suffix="i686"
arch_x86_suffix="x86_64"
input=$3
if [ ! "${input}" = ""  ]; then
	arch_x86_suffix=${input}
fi

#arch_arm_suffix="armel"
arch_arm_suffix="armhf"
input=$4
if [ ! "${input}" = ""  ]; then
        arch_arm_suffix=${input}
fi

# directory name which the nzbget installer extracts into
UNPACKED_DIR="./nzbget"

# =====
# ===== REPACKAGING LOGIC
# =====

# wget https://github.com/nzbget/nzbget/releases/download/v17.0-r1726/nzbget-17.0-testing-r1726-bin-linux.run
if [ -f "${LATEST_NZB_GET_FILE}" ] ; then
	echo
	echo "WARNING: File ${LATEST_NZB_GET_FILE} detected - skipping download !"
	echo
else
	download_url="${LATEST_NZB_GET_URL}"
	echo "Downloading latest NZBGet version from URL ${download_url} to file ${LATEST_NZB_GET_FILE} ..."
	wget "${download_url}" -O "${LATEST_NZB_GET_FILE}" || exit 1
fi

# Detect version from file name
echo "Detecting NZBGet version from downloaded filename ${LATEST_NZB_GET_FILE} ... "
LATEST_VERSION=`echo "${LATEST_NZB_GET_FILE}" | awk -F"-" '{ print $2 }'`
testing=`echo "${LATEST_NZB_GET_FILE}" | awk -F"-" '{ print $3 }'`
if [ "${testing}" = "testing" ]; then
	echo "Testing version detected ..."
	testing_VERSION=`echo "${LATEST_NZB_GET_FILE}" | awk -F"-" '{ print $4 }'`
	LATEST_VERSION="${LATEST_VERSION}-${testing}-${testing_VERSION}"
fi
echo
echo "Detected Version: ${LATEST_VERSION}"
echo 

# unpack
chmod 755 ./"${LATEST_NZB_GET_FILE}"

# unpack the downloaded installer 
./"${LATEST_NZB_GET_FILE}" --unpack || exit 1

# repackage - extract
REPACKAGE_DIR="./${BASE_PACKAGE_NAME}-${LATEST_VERSION}"
REPACKAGE_DIR_CONTROL="${REPACKAGE_DIR}/DEBIAN"

rm -Rf "${REPACKAGE_DIR}" 
mkdir "${REPACKAGE_DIR}" && mkdir -p "${REPACKAGE_DIR_CONTROL}" || exit 1

echo "Unpacking Base DEB Install Package ..." 
echo "- Unpacking Control Files ..."
dpkg-deb -e "${BASE_PACKAGE_NAME}.deb" "${REPACKAGE_DIR_CONTROL}" || exit 1
echo "- Unpacking Data Files ..."
dpkg-deb -x "${BASE_PACKAGE_NAME}.deb" "${REPACKAGE_DIR}" || exit 1

# repackage - update binaries and scripts

src="${UNPACKED_DIR}/scripts/*" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/nzbget/ppscripts" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/webui/*" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/nzbget/webui" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/license*" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/doc/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt}
src="${UNPACKED_DIR}/COPYING" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/doc/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} 
src="${UNPACKED_DIR}/ChangeLog" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/doc/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt}
src="${UNPACKED_DIR}/license*" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/doc/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt}
src="${UNPACKED_DIR}/*.pem" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} | exit 1
src="${UNPACKED_DIR}/install-update.sh" && tgt="${REPACKAGE_DIR}/apps/nzbget-app/nzbget_install/share/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt}
#src="${UNPACKED_DIR}/install-update.sh" && tgt="${REPACKAGE_DIR}/arm/usr/bin" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt}
#src="${UNPACKED_DIR}/install-update.sh" && tgt="${REPACKAGE_DIR}/x86/usr/bin" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt}
src="${UNPACKED_DIR}/7za-${arch_x86_suffix}" && tgt="${REPACKAGE_DIR}/x86/usr/bin/7za" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/7za-${arch_arm_suffix}" && tgt="${REPACKAGE_DIR}/arm/usr/bin/7za" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/nzbget-${arch_x86_suffix}" && tgt="${REPACKAGE_DIR}/x86/usr/bin/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/nzbget-${arch_arm_suffix}" && tgt="${REPACKAGE_DIR}/arm/usr/bin/nzbget" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/unrar-${arch_x86_suffix}" && tgt="${REPACKAGE_DIR}/x86/usr/bin/unrar" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
src="${UNPACKED_DIR}/unrar-${arch_arm_suffix}" && tgt="${REPACKAGE_DIR}/arm/usr/bin/unrar" && echo "Copying updated  ${src} to ${tgt} ..." && cp -rf ${src} ${tgt} || exit 1
echo
echo "Updating ReadyNAS App Version to ${LATEST_VERSION} ..."
sed -i -e "s|<Version>[0-9a-z.]\{1,\}</Version>|<Version>${LATEST_VERSION}</Version>|g" "${REPACKAGE_DIR}/apps/nzbget-app/config.xml" || exit 1
sed -i -e "s/^\(Version:\).*/\1 ${LATEST_VERSION}/" "${REPACKAGE_DIR}/DEBIAN/control" || exit 1
echo

# cleanup source data
echo "Cleaning temporary files from ${UNPACKED_DIR} ..."
rm -Rf "${UNPACKED_DIR}" 

# repackage - package new version
dpkg-deb -b "${REPACKAGE_DIR}" || exit 1

# cleanup repackage directory
echo "Cleaning temporary files from ${REPACKAGE_DIR} ..."
rm -Rf "${REPACKAGE_DIR}"
echo
echo  "SUCCESS: Package Built into: ${REPACKAGE_DIR}.deb"
echo
echo  "Upload & Install package manually via ReadyNAS Admin Web UI  ..."


