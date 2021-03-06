#!/bin/sh -xe

#
# main entry point to run s3cmd
#
S3CMD_PATH=s3cmd

#
# Check for required parameters
#
if [ -z "${aws_key}" ]; then
    echo "ERROR: The environment variable key is not set."
    exit 1
fi

if [ -z "${aws_secret}" ]; then
    echo "ERROR: The environment variable secret is not set."
    exit 1
fi

if [ -z "${cmd}" ]; then
    echo "ERROR: The environment variable cmd is not set."
    exit 1
fi

#
# Replace key and secret in the /.s3cfg file with the one the user provided
#
echo "" >> /.s3cfg
echo "access_key=${aws_key}" >> /.s3cfg
echo "secret_key=${aws_secret}" >> /.s3cfg

#
# Add region base host if it exist in the env vars
#
if [ "${s3_host_base}" != "" ]; then
  sed -i "s/host_base = s3.amazonaws.com/# host_base = s3.amazonaws.com/g" /.s3cfg
  echo "host_base = ${s3_host_base}" >> /.s3cfg
fi

# Check if we want to run in interactive mode or not
if [ "${cmd}" != "interactive" ]; then

  #
  # download-gtfs-osm - download gtfs and osm from s3 to local
  #
  if [ "${cmd}" = "build-graph" ]; then
      ${S3CMD_PATH} --config=/.s3cfg sync --exclude-from /opt/files.exclude ${SRC_S3} /opt/dest/
  fi

  #
  # download-graph - download graph object from s3 to local
  #
  if [ "${cmd}" = "run-graph" ]; then
     ${S3CMD_PATH} --config=/.s3cfg get ${SRC_S3}/Graph.obj.xz /opt/dest/
  fi
	
else
  # Copy file over to the default location where S3cmd is looking for the config file
  cp /.s3cfg /root/
fi

#
# Finished operations
#
echo "Finished s3cmd operations, starting runtime"

if [ "${cmd}" = "build-graph" ]; then
  /usr/local/bin/otp --build /opt/dest
  xz -vf /opt/dest/Graph.obj 
  s3cmd --config=/.s3cfg put /opt/dest/Graph.obj.xz ${SRC_S3}
else
  xz -df /opt/dest/Graph.obj.xz
  /usr/local/bin/otp  --graphs opt/  --router dest  --server
fi

