#!/bin/sh
for i in {71..80}
do
        echo $i
	ssh-copy-id -i ~/.ssh/id_rsa.pub longta@10.112.21.${i}
done
