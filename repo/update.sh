./remove.sh
./packages.sh

dpkg-scanpackages -m ../../ > Packages
bzip2 -k Packages
