list=($(curl "https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&use_mirror_status=on" | grep "#Server"))

oldIFS=$IFS
IFS=$'\n' 

repos=()

for i in "${list[@]}"; do
    repoPath=$(echo "$i" | awk -F' = ' '{print $2}')

    host="$(echo "$repoPath" | sed 's/https:\/\///; s/\/.*//g')"

    printf "Working $host... "

    pingOutput="$(timeout 1 ping -c3 -i0.2 -W1 "$host")"

    if [ -z "$pingOutput" ] || [ "$pingOutput" == "" ]; then
        printf "Ping failed.\n"
        continue
    fi

    avgTime="$(echo "$pingOutput" | tail -n1 | awk -F' = ' '{print $2}' | awk -F'/' '{print $2}')"

    if [ -z "$avgTime" ] || [ "$avgTime" == "" ]; then
        printf "Avg time failed\n"
        continue
    fi

    printf "Time: ${avgTime}ms\n"

    repos+=("${repoPath} ${avgTime}")
done

echo "Output:"
for i in "${repos[@]}"; do
    echo "$i"
done | sort -k2 -n | sed 's/\ /\n# AvgTime: /'
