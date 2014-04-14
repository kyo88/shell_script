#!/bin/sh
for i in {72..80}
do
        echo $i
	ssh root@10.112.21.${i} "useradd longta; passwd longta"
done
