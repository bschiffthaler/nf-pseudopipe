#!/bin/bash

set -x

echo Making directories
cd out
mkdir dna
touch dna/formatdb.log
mkdir pep

mkdir blast
cd blast
touch jobs
mkdir stamps
mkdir output
mkdir status
mkdir processed
cd ..

mkdir pgenes
cd pgenes
mkdir minus plus
cd minus
mkdir log stamp
cd ../plus
mkdir log stamp
cd ../../..

pwd

for sp in $(ls split????); do
	out=${sp}.Out
	sta=${sp}.Status
	cp $sp out/blast
	touch out/blast/stamps/${sp}.Start
	touch out/blast/stamps/${sp}.Stamp
	cp $out out/blast/output
	cp $sta out/blast/status
done
