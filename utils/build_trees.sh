#! /usr/bin/env bash

indent () {
    num=`echo $1 | awk -F'/' '{print NF-1}'`
    if (( $num > 1 ));then
        num=$((${num}-1))
        python3 -c "print('\t'*${num})"
        #printf '\t%.0s' {1..${num}}
    fi
}

for i in `find | grep -v '\.git' | grep -v  'Pictures'| sort`; do 
    echo -e "`indent $i`- [${i##*/}]($i)"
done
