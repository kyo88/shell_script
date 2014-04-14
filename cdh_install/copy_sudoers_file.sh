#!/bin/sh
for i in {73..80}
do
        echo $i
        sudo scp ./sudoers root@10.112.21.${i}:/etc/
done

