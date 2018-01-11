#!/bin/bash

################################################################
#
#  Script to backup or retrieve data between an Atmosphere
#  instance and iPlant Datastore
#
#  cyverse_backup.sh -- Version 2.0
#  Michael Cutshall -- 1/08/2018
#
################################################################

user=$(whoami)
USER_LOCAL_DIR=${USER_LOCAL_DIR:-"/home/$user/Documents/atmosphere"}
USER_DS_DIR=${USER_DS_DIR:-"/iplant/home/$user/atmosphere"}
USER_ATMO_DIR=${USER_ATMO_DIR:-"/iplant/home/$user/atmobackup"}
IRODS_ENV_FILE=${IRODS_ENV_FILE:-"/home/$user/.irods/irods_environment.json"}
USER_IRODS_DIR=${USER_IRODS_DIR:-"/home/$user/.irods"}

#check for and set irods environment variables
function set_env()
{
  if [ ! -d $USER_IRODS_DIR ] ; then
    mkdir -p /home/$user/.irods
  fi

  if [  -f $IRODS_ENV_FILE ] ; then
    echo "Warning: Setting irods environment variables"
  fi

  #irods configuration for atmoshpere
  cat >$IRODS_ENV_FILE <<EOF
{
      "irods_host": "data.iplantcollaborative.org",
      "irods_port": 1247,
      "irods_user_name": "$user",
      "irods_zone_name": "iplant"
}
EOF
}

function usage()
{
  echo "Usage: ./cyverse_backup_beta.sh [-h] [-b] [-r] [-f] [-m] [-L] [-R]"
  echo "./cyverse_backup_beta.sh - backup or restore data between an Atmosphere instance and Cyverse Datastore"
  echo
  echo "Options:"
  echo
  echo "  -h	print help/usage"
  echo "  -b	backup files."
  echo "  -r	restore from backup"
  echo "  -f	overwrite existing files/directories"
  echo "  -m	create any missing directories"
  echo "  -L	specify local directory to backup or restore to. default is /home/user/Documents/atmosphere"
  echo "  -R	specify iRODs directory to backup. default is /iplant/home/user/atmosphere"
  echo
  echo "Examples:"
  echo "  ./cyverse_backup_beta.sh -b -L /home/user/Documents"
  echo "  ./cyverse_backup_beta.sh -r -L /home/user/Documents -R /iplant/home/user/atmosphere"
  echo
  exit
}

function backup()
{
  local_source=$1
  irods_dir=$2
  make_irods_dir=$3
  local output_log="$HOME/.irods/atmo_backup-$(date +"%Y-%m-%d").log" \

  echo "Backing up to $irods_dir from source: $local_source"
  iinit

  if [ $make_irods_dir ] ; then
    echo "Creating irods directory $irods_dir"
    imkdir $irods_dir
  fi

  echo "Backing up data..."
  irsync -r -v $local_source i:$irods_dir &>"$output_log"
  echo "Backup complete"
}

function restore()
{
  irods_dir=$1
  local_dir=$2
  option=$3

  local output_log="$HOME/.irods/atmo_backup-$(date +"%Y-%m-%d").log" \

  echo "Restoring data to $local_dir from source: $irods_dir"
  iinit

  if [[ "$option" == *"m"* ]]; then
    echo "Creating local directory $local_dir"
    mkdir -p $USER_LOCAL_DIR
  fi

  if [[ "$option" == *"f"* ]]; then
    echo "Restoring data..."
    irsync -r -v i:$irods_dir $local_dir &>"$output_log"
    echo "Restore complete"
  else
    echo -n "Warning: The file/folder already exists. Do you want to overwrite? [yes/no]: "
    read answer
    if [ $answer == "yes" ]; then
      echo "Restoring data..."
      irsync -r -v i:$irods_dir $local_dir &>"$output_log"
      echo "Restore complete"
    else
      echo "Restore aborted"
      exit 1
    fi
  fi
}

function main()
{
  #script should not be run as root
  if [ "$user" == "root" ]
  then
    echo "ERROR: This script cannot be run as root user" >&2
    exit 1
  fi
  
  #if no option given after dash
  if [[ "$1" == "-" ]] ; then
    echo "Missing option: -" >&2
    echo
    usage
    exit 1
  fi

  #if a non-option is given as the first argument, or more than one dash
  if [[ ! "$1" == -* ]] || [[ "$1" == *- ]] && [ -n  "$1" ]  ; then
    echo "Invalid option: $1" >&2
    echo
    usage
    exit 1
  fi

  while getopts ":hbfrmL:R:" opt; do
    case $opt in
      h)
         usage
         ;;
      b)
         backup=1
         ;;
      L)
         USER_LOCAL_DIR=$OPTARG
         ;;
      r)
         restore=1
         ;;
      R)
         USER_DS_DIR=$OPTARG
         ;;
      f)
         force=1
         ;;
      m)
         makedir=1
         ;;
      :)
         echo "-$OPTARG requires an argument"
         echo
         usage
         ;;
      *)
         echo "Invalid option: -$OPTARG"
	 echo
         usage
         ;;
    esac
  done

  #if both -r and -b options are given
  if [ $backup ] && [ $restore ] ; then
    echo "Error: -b and -r options incompatible" >&2
    echo
    usage
    exit 1
  fi

  #check/set irods environment
  set_env

  #if neither -b or -r given, backup is assumed
  if [ $backup ] || [ ! $restore ] 
  then
    if [ -d $USER_LOCAL_DIR ]; then
      usr_local=1
    else
      echo "The directory $USER_LOCAL_DIR does not exist. To create it use the -m option" >&2
      exit 1
    fi
    if [ $makedir ]; then
      backup_options=m
    fi
    if [ $usr_local -eq 1 ]; then
      backup $USER_LOCAL_DIR $USER_DS_DIR $backup_options
    fi
  fi

  if [ $restore ]
  then
    if [ -d $USER_LOCAL_DIR ]; then
      usr_local=1
    fi
    if [ $makedir ]; then
      restore_options=m
    fi
    if [ $force ]; then
      restore_options+=f
    fi
    if [ $usr_local -eq 1 ]; then
      restore $USER_DS_DIR $USER_LOCAL_DIR $restore_options
    fi
  fi
}

main $@
