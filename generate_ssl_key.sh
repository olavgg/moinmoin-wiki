#!/bin/bash

#Required
domain=$1
commonname=$domain
 
#Change to your company details
country=NO
state=Rogaland
locality=Sola
organization=example.org

openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 3600 \
	-nodes \
	-subj "/C=$country/ST=$state/L=$locality/O=$organization"
