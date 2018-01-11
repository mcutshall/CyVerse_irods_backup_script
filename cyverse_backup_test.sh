#!/bin/bash
########################################

#Test script for cyverse_backup_beta.sh

########################################

#could set the tester's password as a variable and echo to each test to avoid typing 
#password for each case

#pswd = 
#echo pswd | ./cyverse_backup_beta.sh

echo "test for no arguments given"
#should backup to /iplant/home/cutshall/atmosphere from /home/cutshall/Documents/atmosphere
./cyverse_backup_beta.sh
echo "END TEST"
echo

echo "test for only -b"
#should backup to /iplant/home/cutshall/atmosphere from /home/cutshall/Documents/atmosphere
./cyverse_backup_beta.sh -b
echo "END TEST"
echo

echo "test -r with 'yes'"
#should restore to /home/cutshall/Documents/atmosphere from /iplant/home/cutshall/atmosphere
./cyverse_backup_beta.sh -r
echo "END TEST"
echo

echo "test -r with 'no'"
#should abort restore
./cyverse_backup_beta.sh -r
echo "END TEST"
echo

echo "test -r with -f"
#should restore to /home/cutshall/Documents/atmosphere from /iplant/home/cutshall/atmosphere
#without prompt for "overwrite? [yes/no]"
./cyverse_backup_beta.sh -r -f
echo "END TEST"
echo

echo "test for only -L"
#should print '-L needs argument'. print help screen
./cyverse_backup_beta.sh -L
echo "END TEST"
echo

echo "test for only -R"
#should print '-R needs argument'. print help screen
./cyverse_backup_beta.sh -R
echo "END TEST"
echo

echo "test for -h"
#should print help screen
./cyverse_backup_beta.sh -h
echo "END TEST"
echo

echo "test for only -f"
#currently will perform default backup
#should print error about including -r
./cyverse_backup_beta.sh -f
echo "END TEST"
echo

echo "test for only -m"
#should attempt to create directory /iplant/home/cutshall/atmosphere
#will print mkdirUtil error if directory already exists
./cyverse_backup_beta.sh -m
echo "END TEST"
echo

echo "test for local directory that doesnt exist"
#should print error that local directory doesn't exist. suggests using -m option
./cyverse_backup_beta.sh -L /home/cutshall/not_here
echo "END TEST"
echo

echo "test restore of directory that doesnt exist in irods"
#Should print error 
./cyverse_backup_beta.sh -r -R /home/cutshall/doesnt_exist
echo "END TEST"
echo

echo "test for -b and -r arguments"
#should return an incompatibility error 
./cyverse_backup_beta.sh -b -r
echo "END TEST"
echo

echo "test for only a dash as option"
#should return missing argument error
./cyverse_backup_beta.sh -
echo "END TEST"
echo 

echo "test for multiple dashes"
#should return an invalid option error. should work for any number of dashes
./cyverse_backup_beta.sh ----
echo "END TEST"
echo

echo "test for non-option string as first argument"
#should return invalid option error
./cyverse_backup_beta.sh lkjlkj
echo "END TEST"
echo 
