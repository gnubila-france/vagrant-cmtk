#!/bin/sh
#
# Build script for CMTK
# http://www.cmtk.org/mapper/installation.html

set -e

readonly APP='cmtk'
readonly VER=$(date +'%Y%m%d')
readonly SOFTWARE_REPOSITORY="http://web.maatg.fr/grid/softwares/$APP"

readonly PYTHON_APP='Python'
readonly PYTHON_VER='2.7.7'
readonly PYTHON_INSTALL_URL="$SOFTWARE_REPOSITORY/${PYTHON_APP}-${PYTHON_VER}.tgz"
readonly PYTHON_INSTALL_URL_FILENAME="${PYTHON_INSTALL_URL##*/}"

readonly DTK_APP='Diffusion_Toolkit'
readonly DTK_VER='v0.6.2.2_x86_64'
readonly DTK_INSTALL_URL="$SOFTWARE_REPOSITORY/${DTK_APP}_${DTK_VER}.tar.gz"
readonly DTK_INSTALL_URL_FILENAME="${DTK_INSTALL_URL##*/}"

readonly JDK_APP='jdk'
readonly JDK_VER='7u60-linux-x64'
readonly JDK_INSTALL_URL="$SOFTWARE_REPOSITORY/${JDK_APP}-${JDK_VER}.tar.gz"
readonly JDK_INSTALL_URL_FILENAME="${JDK_INSTALL_URL##*/}"

readonly CAMINO_APP='camino-code'
readonly CAMINO_VER='163f67cbf550560aa351b3d0a3bbbd7a22863cb4'
readonly CAMINO_INSTALL_URL="$SOFTWARE_REPOSITORY/${CAMINO_APP}-${CAMINO_VER}.zip"
readonly CAMINO_INSTALL_URL_FILENAME="${CAMINO_INSTALL_URL##*/}"

readonly NIFTILIB_APP='nifticlib'
readonly NIFTILIB_VER='2.0.0'
readonly NIFTILIB_INSTALL_URL="$SOFTWARE_REPOSITORY/${NIFTILIB_APP}-${NIFTILIB_VER}.tar.gz"
readonly NIFTILIB_INSTALL_URL_FILENAME="${NIFTILIB_INSTALL_URL##*/}"

readonly CAMINO_TRACKVIS_APP='camino-trackvis'
readonly CAMINO_TRACKVIS_VER='0.2.8.1'
readonly CAMINO_TRACKVIS_INSTALL_URL="$SOFTWARE_REPOSITORY/${CAMINO_TRACKVIS_APP}-${CAMINO_TRACKVIS_VER}.tar.bz2"
readonly CAMINO_TRACKVIS_INSTALL_URL_FILENAME="${CAMINO_TRACKVIS_INSTALL_URL##*/}"

readonly MRTRIX_APP='mrtrix'
readonly MRTRIX_VER='0.2.11_2013-03-13'
readonly MRTRIX_INSTALL_URL="$SOFTWARE_REPOSITORY/${MRTRIX_APP}-${MRTRIX_VER}.tar.bz2"
readonly MRTRIX_INSTALL_URL_FILENAME="${MRTRIX_INSTALL_URL##*/}"

readonly GIBBS_APP='MITK'
readonly GIBBS_VER='2014.03.00-linux64'
readonly GIBBS_INSTALL_URL="$SOFTWARE_REPOSITORY/${GIBBS_APP}-${GIBBS_VER}.tar.gz"
readonly GIBBS_INSTALL_URL_FILENAME="${GIBBS_INSTALL_URL##*/}"

if [ ! -r './common.sh' ]; then
  echo 'common.sh is missing, exiting!'
  exit 1
fi

. ./common.sh

readonly TEMP_DIR_PATH="$PWD"
readonly BUILD_DIR="$TEMP_DIR_PATH/$APP-$VER"
readonly INIT_SCRIPT="$BUILD_DIR/init.sh"

# Python 2.7
[ -f "$PYTHON_INSTALL_URL_FILENAME" ] || fetch_file "$PYTHON_INSTALL_URL"

# Diffusion Toolkit
[ -f "$DTK_INSTALL_URL_FILENAME" ] || fetch_file "$DTK_INSTALL_URL"

# MRtrix
[ -f "$MRTRIX_INSTALL_URL_FILENAME" ] || fetch_file "$MRTRIX_INSTALL_URL"

# JDK
[ -f "$JDK_INSTALL_URL_FILENAME" ] || fetch_file "$JDK_INSTALL_URL"

# nifti
[ -f "$NIFTILIB_INSTALL_URL_FILENAME" ] || fetch_file "$NIFTILIB_INSTALL_URL"

# Camino
[ -f "$CAMINO_INSTALL_URL_FILENAME" ] || fetch_file "$CAMINO_INSTALL_URL"

# Camino trackvis
[ -f "$CAMINO_TRACKVIS_INSTALL_URL_FILENAME" ] || fetch_file "$CAMINO_TRACKVIS_INSTALL_URL"

# Gibbs tracker
[ -f "$GIBBS_INSTALL_URL_FILENAME" ] || fetch_file "$GIBBS_INSTALL_URL"

mkdir "$BUILD_DIR"
cd "$BUILD_DIR"

# Python
echo
echo 'Installing python'
extract_tarball "$TEMP_DIR_PATH/$PYTHON_INSTALL_URL_FILENAME"
cd "${PYTHON_INSTALL_URL_FILENAME%.*}"
./configure --prefix "$BUILD_DIR/python"
make
#make test
make install
cd "$BUILD_DIR"
rm -rf "${PYTHON_INSTALL_URL_FILENAME%.*}"

# Use our python distribution starting from now
export PATH="$BUILD_DIR/python/bin:$PATH"
export LD_LIBRARY_PATH="$BUILD_DIR/python/lib:$LD_LIBRARY_PATH"

# EasyInstall for python modules
echo
echo 'Installing EasyInstall'
wget https://bootstrap.pypa.io/ez_setup.py -O - | python
rm -r setuptools-*.zip

# Diffusion Toolkit
# http://trackvis.org/dtk/
echo
echo 'Installing Diffusion Toolkit'
extract_tarball "$TEMP_DIR_PATH/$DTK_INSTALL_URL_FILENAME"
mkdir -p "$BUILD_DIR/bin"
find dtk -maxdepth 1 -type f -perm /111 -exec mv {} "$BUILD_DIR/bin" \;

# MRtrix
# http://www.brain.org.au/software/mrtrix/install/unix.html
echo
echo 'Installing MRtrix'
extract_tarball "$TEMP_DIR_PATH/$MRTRIX_INSTALL_URL_FILENAME"
cd "${MRTRIX_INSTALL_URL_FILENAME%_*}"
# Prevent install to create configuration file in /etc
sed -i "s#/etc/mrtrix.conf#$BUILD_DIR/etc/mrtrix.conf#" build
mkdir -p "$BUILD_DIR/etc"
# /etc/mrtrix.conf path is hardcoded into lib/libmrtrix-*.so
python build
python build install=$BUILD_DIR/mrtrix linkto=

cd "$BUILD_DIR"
rm -rf "${MRTRIX_INSTALL_URL_FILENAME%_*}"

# Install JDK
echo
echo 'Installing JDK'
extract_tarball "$TEMP_DIR_PATH/$JDK_INSTALL_URL_FILENAME"
readonly JDK_DIR_NAME=$(find $BUILD_DIR -maxdepth 1 -name 'jdk*' -printf '%f')
# Use our java distribution starting from now
export JAVA_HOME="$BUILD_DIR/$JDK_DIR_NAME"
export PATH="$JAVA_HOME/bin:$PATH"

# Camino
# http://cmic.cs.ucl.ac.uk/camino/index.php?n=Main.Installation
echo
echo 'Installing Camino'
extract_zip "$TEMP_DIR_PATH/$CAMINO_INSTALL_URL_FILENAME"
mv "${CAMINO_INSTALL_URL_FILENAME%.zip}" camino
cd camino
make
cd "$BUILD_DIR"

# niftylib
echo
echo 'Installing niftilib'
extract_tarball "$TEMP_DIR_PATH/$NIFTILIB_INSTALL_URL_FILENAME"
readonly NIFTILIB_DIRNAME="${NIFTILIB_INSTALL_URL_FILENAME%.tar.gz}"
cd "$NIFTILIB_DIRNAME"
make all
cd "$BUILD_DIR"

# Camino Trackvis
# http://sourceforge.net/projects/camino-trackvis/
echo
echo 'Installing Camino trackvis'
extract_tarball "$TEMP_DIR_PATH/$CAMINO_TRACKVIS_INSTALL_URL_FILENAME"
cd "${CAMINO_TRACKVIS_INSTALL_URL_FILENAME%.tar.bz2}"
./build.sh
cd "$BUILD_DIR"

# Gibbs tracker
# http://mitk.org/Download
echo
echo 'Installing Gibbs tracker'
extract_tarball "$TEMP_DIR_PATH/$GIBBS_INSTALL_URL_FILENAME"

# Nipype and connectomemapper deps
echo
echo 'Installing python modules dependencies'
easy_install numpy
easy_install nibabel dipy traits traitsui pyface networkx scipy nose

# Nipype
echo
echo 'Installing nipype'
git clone git://github.com/LTS5/nipype.git
cd nipype
python setup.py install
cd "$BUILD_DIR"

# Connectomemapper
echo
echo 'Installing connectomemapper'
git clone https://github.com/LTS5/cmp_nipype.git
cd cmp_nipype
python setup.py install
cd "$BUILD_DIR"

echo
echo "Creating $INIT_SCRIPT"
cat > "$INIT_SCRIPT" << EOF
# Initialization script for CMTK

# assert_is_set caller_name variable_name
assert_is_set() {
  if [ \$# -ne 2 ]; then
    echo 'assert_is_set: Wrong numbers of parameters:'
    echo 'assert_is_set caller_name variable_name'
    exit 1
  fi

  local caller_name="\$1"
  local variable_name="\$2"

  eval val=\\\$\$variable_name
  if [ -z "\$val" ] ; then
    echo "\$caller_name: variable '\$variable_name' is not defined or empty" >&2
    exit 1
  fi
}

if \$(assert_is_set cmtk-init-env FREESURFER_HOME) && \$(assert_is_set cmtk-init-env FSLDIR); then
  CMTK_HOME=\$(readlink -m \$(dirname \$0))

  PATH="\$CMTK_HOME/bin:\$PATH"

  # Python
  export PATH="\$CMTK_HOME/python/bin:$PATH"
  export LD_LIBRARY_PATH="\$CMTK_HOME/python/lib:\$LD_LIBRARY_PATH"

  # Diffusion Toolkit
  # folder containing the dtk executables
  export DTDIR="\$CMTK_HOME/bin"
  # folder containing the diffusion matrices
  export DSI_PATH="\$CMTK_HOME/dtk/matrices"

  # Freesurfer
  source \$FREESURFER_HOME/FreeSurferEnv.sh

  # FSL
  source \$FSLDIR/fsl-init-env.sh

  # JDK
  export JAVA_HOME="\$CMTK_HOME/$JDK_DIR_NAME"
  export PATH="\$JAVA_HOME/bin:\$PATH"

  # MRtrix
  PATH="\$CMTK_HOME/mrtrix/bin:\$PATH"
  export LD_LIBRARY_PATH="\$CMTK_HOME/mrtrix/lib:\$LD_LIBRARY_PATH"

  # Camino
  export PATH="\$CMTK_HOME/camino/bin:\$PATH"
  export MANPATH="\$CMTK_HOME/camino/man:\$MANPATH"

  # NIFTI lib
  export PATH="\$CMTK_HOME/$NIFTILIB_DIRNAME/bin:$PATH"
  export LD_LIBRARY_PATH="\$CMTK_HOME/$NIFTILIB_DIRNAME/lib:\$LD_LIBRARY_PATH"

  # Camino trackvis
  export CAMINO2TRK="\$CMTK_HOME/${CAMINO_TRACKVIS_INSTALL_URL_FILENAME%.tar.bz2}/bin"
  export PATH="\$CMTK_HOME/\$CAMINO2TRK:\$PATH"

  # Gibbs
  export PATH="\$CMTK_HOME/${GIBBS_INSTALL_URL_FILENAME%.tar.gz}/bin:$PATH"
  export LD_LIBRARY_PATH="\$CMTK_HOME/${GIBBS_INSTALL_URL_FILENAME%.tar.gz}/lib:\$LD_LIBRARY_PATH"
  echo 'Initialized!'
else
  echo 'Initialization impossible, please set required variables'
fi
EOF

# Tarball creation
echo
echo 'Creating tarball'
cd ..
tar cjvf "$APP-$VER.tar.bz2" "$APP-$VER"

exit 0

# vim:set ft=sh ts=2 sw=2 expandtab:
