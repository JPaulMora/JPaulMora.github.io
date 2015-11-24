./remove.sh
./packages.sh

dpkg-scanpackages -m . > Packages
bzip2 -k Packages

head -n 9 Release > R2
mv R2 Release

md51=$(md5sum Packages | cut -d ' ' -f1)
sz1=$(wc -c < Packages | sed 's/ //g')
md52=$(md5sum Packages.bz2 | cut -d ' ' -f1)
sz2=$(wc -c < Packages.bz2 | sed 's/ //g')

echo -e " $md51 $sz1 Packages\n $md52 $sz2 Packages.bz2" >> Release
rm Release.gpg
gpg -abs -u 2FD4C7A6 -o Release.gpg Release


