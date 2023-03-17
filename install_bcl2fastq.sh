sudo apt-get update && sudo apt-get install -y build-essential unzip cmake \
     gcc g++ automake make zlib1g-dev libncurses5-dev libboost-all-dev zlibc libxml2

mkdir -p $HOME/bin && cd $_
wget ftp://webdata2:webdata2@ussd-ftp.illumina.com/downloads/software/bcl2fastq/bcl2fastq2-v2-20-0-tar.zip
unzip bcl2fastq2-v2-20-0-tar.zip
tar -zxvf bcl2fastq2-v2.20.0.422-Source.tar.gz
#rm bcl2fastq2-v2-20-0-tar.zip bcl2fastq2-v2.20.0.422-Source.tar.gz

cat <<EOF >> $HOME/.bashrc
if [ -d "\$HOME/bin" ] ; then
   export PATH="\$HOME/bin:\$PATH"
fi
EOF

source $HOME/.bashrc

sed -i '76s/)/ \/usr\/include\/x86_64-linux-gnu\/\)/' $HOME/bin/bcl2fastq/src/cmake/macros.cmake
sed -i '172s/settings/settings\<ptree::key_type\>/' $HOME/bin/bcl2fastq/src/cxx/lib/io/Xml.cpp
sed -i '180s/settings/settings\<ptree::key_type\>/' $HOME/bin/bcl2fastq/src/cxx/lib/io/Xml.cpp

mkdir -p $HOME/bin/BCL2FASTQ

cd $HOME/bin/bcl2fastq/src
mkdir build && cd $_
$HOME/bin/bcl2fastq/src/configure --prefix=$HOME/bin/BCL2FASTQ
make
make install
cd $HOME/bin && rm -r $HOME/bin/bcl2fastq
ln -s BCL2FASTQ/bin/bcl2fastq .
