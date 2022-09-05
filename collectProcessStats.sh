#Author: Manoj Palivela
# sample cron job to execite this script : * * * * * for i in 0; do /root/collectProcessStats.sh >> /root/processStats.txt & sleep 2; done;
#Purpose: 
# collect few statistics when free memory <100 Mb
# collect few statistics when CPU usage > 98% 


freeMem=`/bin/free -m | grep "^Mem" | awk '{print $4}'`
cpuUsage=`/bin/vmstat 1 2|tail -1|awk '{print $15}'`
cpuUsage=$(( 100-$cpuUsage ))

if [ $freeMem -lt 100 ] || [ $cpuUsage -gt 98 ];
then

echo "=========================================================="
echo " Top  5 Memory consuming processes "
/bin/ps aux --sort -%mem | head -6
echo "=========================================================="

echo "=========================================================="
echo " Process with high OOM scores "
readarray -t my_array < <(cat /proc/*/oom_score | sort -nr | head -5)
echo "=========================================================="

echo "=========================================================="
for i in "${my_array[@]}"
do
#echo $i
#grep -w $i /proc/*/oom_score
pid=`grep -w $i /proc/*/oom_score | cut -d / -f 3`
#echo "--> $pid"
if [[ ! -z $pid ]]
then
/bin/ps -o pid,user,%mem,command ax | sort -b -k3 -r | awk "/^ +${pid}/{print}"
fi
done
echo "=========================================================="

echo "=========================================================="
echo " Top 5 Consuming proceses "
/bin/ps aux --sort -%cpu | head -6
echo "=========================================================="
fi
