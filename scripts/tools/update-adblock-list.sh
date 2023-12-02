# /usr/bin/env bash
# fetch adblock list for Chinese

tmpdir=/tmp/adblock
mkdir -p $tmpdir
rm -rfv ${tmpdir}/*

targetdir=~/Data/Adblock
mkdir -p $targetdir
target=${targetdir}/adblock.hosts

cd $tmpdir

rules_urls="https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt \
	https://easylist-downloads.adblockplus.org/fanboy-social.txt \
	"
	# https://easylist-downloads.adblockplus.org/malwaredomains_full.txt \

# 误伤太多
domain_urls="https://anti-ad.net/domains.txt"

# mirror to "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
host_urls=http://sbc.io/hosts/hosts

fetch_ruleurls() {
    if curl -s -L $rules_urls > rules.unsorted ; then
        echo "Downloaded lists from rule urls"
        echo "Downloaded total lines: $(wc -l rules.unsorted)"
	sort -u rules.unsorted | grep ^\|\|.*\^$ | grep -v \/ > rules.sorted
	sed -i 's/[\|^]//g' rules.sorted
	echo "Got sorted lines: $(wc -l rules.sorted)"
    fi
}

fetch_domains() {
    if curl -s -L $domain_urls > domains.unsorted ; then
        echo "Downloaded lists from rule urls"
        echo "Downloaded total lines: $(wc -l domains.unsorted)"
	sort -u domains.unsorted > domains.sorted
	sed -i '/^#/d' domains.sorted
	echo "Got sorted lines: $(wc -l domains.sorted)"
    fi
}

fetch_hosts() {
    if curl -s -L $host_urls > host.unsorted ; then
        echo "Downloaded lists from rule urls"
        echo "Downloaded total lines: $(wc -l host.unsorted)"
    
        grep '^0.0.0.0 ' host.unsorted | awk '{print $2}' | sort -u > host.sorted
        
        echo "Got sorted lines: $(wc -l host.sorted)"
    fi
}

echo "--------------------------------------------"
[[ -n "$rules_urls" ]] && fetch_ruleurls
echo "--------------------------------------------"
[[ -n "$domain_urls" ]] && fetch_domains
echo "--------------------------------------------"
[[ -n "$host_urls" ]] && fetch_hosts
echo "--------------------------------------------"

for f in *.sorted ; do
    if [[ -s $f ]] ; then
        echo "Merging $f"
        cat $f >> fin.domains
    fi
done

if [[ -s fin.domains ]]; then 
    sort -u fin.domains > $target
    echo "Got final lines $(wc -l $target)"
else
    echo "Ignored empty result."
fi

rm -rfv ${tmpdir}/*
