#!/bin/bash
#
#Launch variables
recondomain=$1

#Perform the dig and host commands:
echo -e "Performing dig and host on the provided domain name...\n--------------------"
host $recondomain >> /tmp/aresults.txt
dig -t ns $recondomain >> /tmp/aresults.txt
echo -e "\n--------------------"

#Builds initial host data needed to perform next functions
echo -e "Dig and Host command results:\n--------------------"
cat /tmp/aresults.txt |grep $recondomain

#Sets IP variable to the IP address for all four octets
echo -e "\n--------------------"
fullip=$(cat /tmp/aresults.txt |grep "has address" | cut -d " " -f 4|cut -d"." -f 1,2,3,4)
echo -e "Host $recondomain has the IP address of $fullip\n--------------------"

#sets for /24 with three octets
twofourip=$(cat /tmp/aresults.txt |grep "has address" | cut -d " " -f 4|cut -d"." -f 1,2,3)
echo -e "The host most likely owns the /24 block - we'll do a reverse DNS on $twofourip...\n--------------------"

	#For loop to run reverse DNS lookup and then cleanup 
for ipblock in $(seq 1 254);do
	host $twofourip.$ipblock >> /tmp/reversedns.txt &
done

	#parses data output from reverse DNS Lookup
cat /tmp/reversedns.txt |grep pointer |sort |cut -d" " -f5 >> /tmp/reversedns24.txt
echo -e "Here's your reverse DNS lookup on the /24:\n--------------------"
cat /tmp/reversedns24.txt

	#Cleanup here...
echo -e "Cleaning up some files...\n--------------------"
rm /tmp/reversedns.txt
rm /tmp/aresults.txt
rm /tmp/reversedns24.txt
echo "Done!" 
#Done


