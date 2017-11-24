#! /bin/bash -e

version=0.1.6-beta
install_dir=/usr/local/community/bioinformatics/apps/hisat/$version/binary
mkdir -p $install_dir

cd $install_dir

wget http://www.ccb.jhu.edu/software/hisat/downloads/hisat-$version-Linux_x86_64.zip

unzip hisat-$version-Linux_x86_64.zip


mv hisat-$version/* .
rm -r hisat-$version
rm hisat-$version-Linux_x86_64.zip

