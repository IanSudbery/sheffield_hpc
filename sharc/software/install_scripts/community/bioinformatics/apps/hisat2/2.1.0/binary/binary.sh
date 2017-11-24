#! /bin/bash -e

install_dir=/usr/local/community/bioinformatics/apps/hisat2/2.1.0/binary
version=2.1.0
mkdir -p $install_dir

cd $install_dir

wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-$version-Linux_x86_64.zip

unzip hisat2-$version-Linux_x86_64.zip


mv hisat2-$version/* .
rm -r hisat2-$version
rm hisat2-$version-Linux_x86_64.zip

