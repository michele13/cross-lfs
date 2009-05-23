#!/bin/bash
# Create a Eglibc Tarball

# Get Version #
#
VERSION=$1
SOURCEVERSION=$2

# Check Input
#
if [ "${VERSION}" = "" -o "${SOURCEVERSION}" = "" ]; then
  echo "$0 - Eglibc_Version"
  echo "This will Create a Tarball for Eglibc Eglibc_Series Eglibc_Version"
  echo "Example $0 2.19 2.19.1"
  exit 255
fi

# Get Current Eglibc from SVN
#
install -d ~/tmp
cd ~/tmp
FIXEDVERSION=$(echo ${VERSION} | sed -e 's/\./_/g')
echo "Retreiving from SVN eglibc-${SOURCEVERSION}..."
svn export svn://svn.eglibc.org/branches/eglibc-${FIXEDVERSION} eglibc-${SOURCEVERSION}

# Customize the version string, so we know it's patched
#
cd ~/tmp/eglibc-${SOURCEVERSION}
DATE_STAMP=$(date +%Y%m%d)
echo "#define DL_DATE \"${DATE_STAMP}\"" >> libc/version.h
sed -i "s@Compiled by GNU CC version@Built for Cross-LFS.\\\\n\\\\\nRetrieved on \"DL_DATE\".\\\\n\\\\\\nCompiled by GNU CC version@" libc/csu/version.c
sed -i "s@static const char __libc_release@static const char __libc_dl_date[] = DL_DATE;\nstatic const char __libc_release@" libc/csu/version.c

# Remove Files not needed
#
FILE_LIST=".cvsignore"
for files in ${FILE_LIST}; do
  REMOVE=$(find * -name ${files})
  for file in $REMOVE; do
    rm -f ${file}
  done
done

# Fix configuration files
#
echo "Updating Glibc configure files..."
find . -name configure -exec touch {} \;

# Compress
#
echo "Creating Tarball for Eglibc Ports ${SOURCEVERSION}...."
tar cjf ~/public_html/eglibc-ports-${SOURCEVERSION}.tar.bz2 ports
rm -rf ports
echo "Creating Tarball for Eglibc Linuxthreads ${SOURCEVERSION}...."
tar cjf ~/public_html/eglibc-linuxthreads-${SOURCEVERSION}.tar.bz2 linuxthreads
rm -rf linuxthreads
echo "Creating Tarball for Eglibc LocaleDef ${SOURCEVERSION}...."
tar cjf ~/public_html/eglibc-localedef-${SOURCEVERSION}.tar.bz2 localedef
rm -rf localedef
mv libc eglibc-${SOURCEVERSION}
echo "Creating Tarball for Eglibc ${SOURCEVERSION}...."
tar cjf ~/public_html/eglibc-${SOURCEVERSION}.tar.bz2 eglibc-${SOURCEVERSION}

# Clean up Directores
#
cd ~/tmp
rm -rf eglibc-${SOURCEVERSION}

