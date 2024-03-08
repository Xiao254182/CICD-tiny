#! /bin/bash

hostName=$(hostname)
ipList=$(ip a | grep -w inet | awk '{print $2}' | sed "s/\/.*//g" | tr '\n' ',' | sed 's/,$//')
loadList=$(top -b -n 1 | grep "load average" | awk '{print $(NF-2),$(NF-1),$NF}')
timeNow=$(top -b -n 1 | grep "load average" | awk '{print $3}')
taskslist=$(top -b -n 1 | grep -w Tasks | awk '{print $2,$4,$6,$8,$10}' | sed "s/ /,/g")
cpuWa=$(top -b -n 1 | grep -w Cpu | awk '{ if ($10 == "wa,") { print $9 } else { print  $10 } }')
availMem=$(echo "scale=2; $(top -b -n 1 | grep "avail Mem" | awk '{print $(NF-2)}') / 1048576" | bc)
totalMem=$(printf "%.2f\n" $(echo "scale=2; $(top -b -n 1 | grep "B Mem" | awk '{print $4}') /1048576" | bc))
useMem=$(printf "%.2f\n" $(echo "scale=2; $(top -b -n 1 | grep "B Mem" | awk '{print $8}') /1048576" | bc))
useRate=$(printf "%.0f\n" $(echo "scale=2; ($useMem / $totalMem)* 100" | bc))

touch /root/monitor.json
printf "{\n" > /root/monitor.json
printf "  \"message\":\"monitor\",\n" >> /root/monitor.json
printf "  \"hostName\":\"$hostName\",\n" >> /root/monitor.json
printf "  \"ipList\":[\"$ipList\"],\n" >> /root/monitor.json
printf "  \"loadList\":[$loadList],\n" >> /root/monitor.json
printf "  \"timeNow\":\"$timeNow\",\n" >> /root/monitor.json
printf "  \"taskslist\":[$taskslist],\n" >> /root/monitor.json
printf "  \"cpuWa\":\"$cpuWa%%\",\n" >> /root/monitor.json
printf "  \"availMem\":\"$availMem M\",\n" >> /root/monitor.json
printf "  \"totalMem\":\"$totalMem M\",\n" >> /root/monitor.json
printf "  \"useMem\":\"$useMem M\",\n" >> /root/monitor.json
printf "  \"useRate\":\"$useRate%%\"\n" >> /root/monitor.json
printf "}\n" >> /root/monitor.json

#nc -u 192.168.100.31 12201 < /root/monitor.json
#Graylog
