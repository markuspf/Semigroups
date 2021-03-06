# If a command fails, exit this script with an error code
set -e

cd ..
mv Semigroups $HOME/semigroups

################################################################################
# Install software necessary for linting: cpplint and gaplint
################################################################################

if [ "$SUITE" == "lint" ]; then

  # Check-out most recent release of cpplint from GitHub
  cd $HOME
  git clone -b master https://github.com/cpplint/cpplint.git lint/cpplint
  cd lint/cpplint
  git checkout `git tag | tail -1`

  # Check out most recent commit of gaplint from GitHub
  cd $HOME
  git clone -b master --depth=1 https://github.com/james-d-mitchell/gaplint lint/gaplint

  # Move Semigroups package into a GAP folder structure, so that cpplint is happy
  cd $HOME
  mkdir gap gap/.git gap/pkg
  mv semigroups $HOME/gap/pkg/semigroups

  exit 0
fi

################################################################################
# Install software necessary for tests and coverage: GAP and packages
################################################################################ 

if [ "$SUITE" != "test" ] && [ "$SUITE" != "coverage" ]; then
  echo -e "\nError, unrecognised Travis suite: $SUITE"
  exit 1
fi

# Display compiler version
$CXX --version

################################################################################
# Install GAP
if [ "$GAP" == "required" ]; then
  cd $HOME/semigroups
  GAP=v`grep "GAPVERS" PackageInfo.g | awk -F'"' '{print $2}'`
fi
echo -e "\nInstalling GAP $GAP into $GAPROOT..."
git clone -b $GAP --depth=1 https://github.com/gap-system/gap.git $GAPROOT
cd $GAPROOT
if [ -f autogen.sh ]; then
  ./autogen.sh
fi
./configure --with-gmp=system $GAP_FLAGS $PKG_FLAGS
make -j4
mkdir pkg

################################################################################
# Move Semigroups into its proper location
mv $HOME/semigroups $GAPROOT/pkg/semigroups

################################################################################
# Get libsemigroups version from file
if [ -f $GAPROOT/pkg/semigroups/.LIBSEMIGROUPS_VERSION ]; then
  LIBSEMI=`tr -d '\n' < $GAPROOT/pkg/semigroups/.LIBSEMIGROUPS_VERSION`
  LIBSEMI=v$LIBSEMI
else
  echo -e "\nError, cannot find $GAPROOT/pkg/semigroups/.LIBSEMIGROUPS_VERSION"
  exit 1
fi

# Download libsemigroups
echo -e "\nDownloading libsemigroups $LIBSEMI into $GAPROOT/pkg/semigroups/src..."
cd $GAPROOT/pkg/semigroups/src
git clone -b $LIBSEMI --depth=1 https://github.com/james-d-mitchell/libsemigroups.git libsemigroups

################################################################################
# Install digraphs, genss, io, orb, and profiling
PKGS=( "digraphs" "genss" "io" "orb" "profiling" )
for PKG in "${PKGS[@]}"; do
  cd $GAPROOT/pkg
  if [ "$PACKAGES" == "master" ] || [ "$PKG" == "profiling" ]; then
    echo -e "\nGetting master branch of $PKG repository..."
    git clone -b master --depth=1 https://github.com/gap-packages/$PKG.git $PKG
    PKGDIR=$PKG
  else
    if [ "$PACKAGES" == "newest" ]; then
      echo -e "\nGetting latest release of $PKG..."
      VERSION=`curl -s -L https://github.com/gap-packages/$PKG/releases/latest | grep \<title\> | awk -F' ' '{print $2}'`
    else
      echo -e "\nGetting required release of $PKG..."
      VERSION=`grep "\"$PKG\"" $GAPROOT/pkg/semigroups/PackageInfo.g | awk -F'"' '{print $4}' | cut -c3-`
    fi
    echo -e "Downloading $PKG-$VERSION..."
    curl -L -O https://github.com/gap-packages/$PKG/releases/download/v$VERSION/$PKG-$VERSION.tar.gz
    tar xf $PKG-$VERSION.tar.gz
    PKGDIR=`tar -tf $PKG-$VERSION.tar.gz | head -1`
    rm $PKG-$VERSION.tar.gz
  fi
  cd $PKGDIR
  if [ -f autogen.sh ]; then
    ./autogen.sh
  fi
  if [ -f configure ]; then
    ./configure $PKG_FLAGS
    make
  fi
done

################################################################################
# Install required GAP packages
cd $GAPROOT/pkg
curl -L -O http://www.gap-system.org/pub/gap/gap4pkgs/packages-required-master.tar.gz
tar xf packages-required-master.tar.gz
rm packages-required-master.tar.gz
