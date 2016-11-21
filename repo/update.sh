echo "[*] Removing Stuff"
./remove.sh
echo "[*] Packaging Stuff"
./package.sh

echo "[*] Building Packages file"
dpkg-scanpackages -m . > Packages
bzip2 -k Packages

echo "[*] Updating Release file"
head -n 9 Release > R2
rm Release
mv R2 Release

md51=$(md5sum Packages | cut -d ' ' -f1)
sz1=$(wc -c < Packages | sed 's/ //g')
md52=$(md5sum Packages.bz2 | cut -d ' ' -f1)
sz2=$(wc -c < Packages.bz2 | sed 's/ //g')

echo -e " $md51 $sz1 Packages\n $md52 $sz2 Packages.bz2" >> Release
echo "[*] Signing Release"
gpg -abs -u 7B9EED6F -o Release.gpg Release
