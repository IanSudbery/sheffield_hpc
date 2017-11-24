#!/bin/bash -e

module load dev/gcc/4.9.4
module load libs/expat/2.1.1

version=4.12.0
install_dir=/usr/local/community/bioinformatics/apps/meme/$version/gcc-4.9.4+openmpi-1.10.4-intel-15+expat-2.0.0
build_dir=/data/$USER/meme-$version
perl_dir=$install_dir/perl
expat_lib=/usr/local/community/bioinformatics/libs/expat-2.2.0/lib
expat_inc=/usr/local/community/bioinformatics/libs/expat-2.2.0/include
mpi_path=/usr/local/packages/mpi/openmpi/1.10.4/intel-15.0.7/

mkdir -p $build_dir
mkdir -p $install_dir
mkdir -p $perl_dir

cd $build_dir
wget http://meme-suite.org/meme-software/$version/meme_$version.tar.gz
tar -xvf meme_$version.tar.gz
cd meme_$version

##Install the neccesary perl modules

# get cpanminus
curl -L https://cpanmin.us/ -o cpanm
chmod +x cpanm

# XML::Parser must in install manually because it requires special switches to its makefile
# but we can install its dependencies via cpanm

./cpanm -l $perl_dir --installdeps XML::Parser

# now download and install the library it self
wget http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/XML-Parser-2.44.tar.gz
tar -xvf XML-Parser-2.44.tar.gz
cd XML-Parser-2.44
perl Makefile.PL INSTALL_BASE=$perl_dir EXPATLIBPATH=$expat_lib EXPATINCPATH=$expat_inc 2>&1 | tee MakeMaker-XML-Parser.log
make 2>&1 | tee make-XML-Parser-2.44.log
make install 2>&1 | tee make-install-XML-Parser.log

cd $build_dir/meme_$version


# now we can install the remaining perl dependencies

./cpanm -l $perl_dir HTML::Template
./cpanm -l $perl_dir HTML::TreeBuilder
./cpanm -l $perl_dir JSON
./cpanm -l $perl_dir XML::Simple
./cpanm -l $perl_dir XML::LibXML
./cpanm -l $perl_dir XML::Compile::SOAP11
./cpanm -l $perl_dir XML::Compile::WSDL11
./cpanm -l $perl_dir Log::Log4perl
./cpanm -l $perl_dir Math::CDF
./cpanm -l $perl_dir File::Which

## We should now be ready to build and install meme

# couldn't load this eariler because it conflicts with compiling the perl dependencies!
module load mpi/openmpi/1.10.4/intel-15.0.7

# Configure, telling it to use the install dirs and to use the env specific python2 and 3 and to add the perl lib path to the perl call.
./configure --prefix=$install_dir --with-url=http://meme-suite.org --enable-build-libxml2 --enable-build-libxslt --with-mpidir=$mpi_path --with-python="/usr/bin/env python2" --with-python3="/usr/bin/env python3" --with-perl="/bin/perl -I $perl_dir/lib/perl5" | tee config-meme-$version.log

make 2>&1 | tee make-meme-$version.log

#patch dreme, see https://groups.google.com/forum/#!topic/meme-suite/m8YVDU2lECs
cp scripts/dreme scripts/dreme_original
sed -i 's/\(pwm, nsites\) = make_pwm_from_re/pwm = make_pwm_from_re/' scripts/dreme

make test 2>&1 | tee make-test-$version.log
make install 2>&1 | tee make-install-$version.log

#download and install the databases
wget http://meme-suite.org/meme-software/Databases/motifs/motif_databases.12.15.tgz
tar -xzf motif_databases.12.15.tgz
mv motif_databases $install_dir/db/

wget http://meme-suite.org/meme-software/Databases/gomo/gomo_databases.3.2.tgz
tar -xzf gomo_databases.3.2.tgz
mv gomo_databases $install_dir/db/



