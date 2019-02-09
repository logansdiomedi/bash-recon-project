#!/bin/bash
#:::digmeup.sh | an open source, OSINT recon tool by Logan S. Diomedi - 2019:::
#:::https://github.com/logansdiomedi/bash-recon-project/blob/master/digmeup.sh:::
#Usage: ./digmeup.sh google.com
#######################################################################
###Launch variables
recondomain=$1
#######################################################################
### Perform the dig and host commands:
echo -e "Performing dig and host on the provided domain name...\n--------------------"
host $recondomain >> /tmp/aresults.txt
dig -t ns $recondomain >> /tmp/aresults.txt

### Builds initial host data needed to perform next functions
echo -e "Dig and Host command results:\n--------------------"
cat /tmp/aresults.txt |grep $recondomain

### Sets IP variable to the IP address for all four octets !!IMPORTANT!!
###
fullip=$(cat /tmp/aresults.txt |grep "has address" | cut -d " " -f 4|cut -d"." -f 1,2,3,4)
twofourip=$(cat /tmp/aresults.txt |grep "has address" | cut -d " " -f 4|cut -d"." -f 1,2,3)
### To-Do: Accept hosts with more than one A record registered to them (ex: sprint.com)
###
echo -e "Host $recondomain has the IP address of $fullip\n--------------------"
echo -e "The host most likely owns the /24 block - we'll do a reverse DNS on $twofourip.1/24...\n--------------------"

### For loop to run reverse DNS lookup and then cleanup:::
for ipblock in $(seq 1 254);do
	host $twofourip.$ipblock >> /tmp/reversedns.txt &
done

### Parses data output from reverse DNS Lookup
cat /tmp/reversedns.txt |grep pointer |sort |cut -d" " -f5,6,7,8,9 >> /tmp/reversedns24.txt
echo -e "Here's your reverse DNS lookup on the /24:\n--------------------"
cat /tmp/reversedns24.txt |sort -u 
echo -e "-----\n"
echo -e "End of output for the reverse lookup on /24 range.\n--------------------"

### WHOIS DNS + IP Address Lookup
echo -e "WHOIS Records on the domain and IP of the domain:\n--------------------"
whois $fullip >> /tmp/whoisip.txt
whois $recondomain >> /tmp/whoisdns.txt

### Sorting the WHOIS data to grab the NetRange and Org (usually the only information I like to grab at first...
cat /tmp/whoisip.txt |grep Org |sort -u >> /tmp/whoisip1.txt && cat /tmp/whoisip1.txt |grep OrgTechEmail
cat /tmp/whoisip.txt |grep Net

### Formatting
echo -e "\n--------------------"
echo -e "End of IP WHOIS for $fullip: Be sure to take note of what range it covers!\n--------------------"

### Display the DNS info - could be tweaked more....
echo -e "Here's your WHOIS for the domain name $recondomain:\n--------------------"
cat /tmp/whoisdns.txt |grep Server |sort -u
cat /tmp/whoisdns.txt |grep Name |sort -u
echo -e "\n--------------------"

### Clean out /tmp###
echo -e "Cleaning up some files...\n--------------------"
rm /tmp/reversedns.txt
rm /tmp/aresults.txt
rm /tmp/reversedns24.txt
rm /tmp/whoisip.txt
rm /tmp/whoisip1.txt
rm /tmp/whoisdns.txt

### Cleanup output
echo -e "Done! Displaying /tmp directory to ensure cleanup occurred - If you don't see any output, this means it was successful:\n--------------------"
echo "Directory listing for /tmp: "
ls -la /tmp |grep txt

### Done!
