OpenTripPlanner Docker image
============================

This project contains a Docker image for stable
[OpenTripPlanner](http://opentripplanner.org) releases. It is available from
Docker Hub in the
[`goabout/opentripplanner` repository](https://hub.docker.com/r/goabout/opentripplanner/).
Image tags correspond to OpenTripPlanner versions. The `latest` tag points to
the latest stable release.

# Usage

## Step 1 Create an image, download GTFS and OSM files from AWS S3 bucket, generate a graph and upload the graph to S3 bucket :

    docker build -t docker-opentripplanner-withgraph .
        
## Step 2 Run the image which is created in Step 1 :

    AWS_KEY=<YOUR AWS KEY>
    AWS_SECRET=<YOUR AWS SECRET>
    BUCKET=s3://your-public-bucket
    
    docker run \
    --env aws_key=${AWS_KEY} \
    --env aws_secret=${AWS_SECRET} \
    --env cmd=download-gtfs-osm \
    --env SRC_S3=${BUCKET} \
    docker-opentripplanner-withgraph

## Step 3 Run the image with the graph which is created in Step 2 :

    AWS_KEY=<YOUR AWS KEY>
    AWS_SECRET=<YOUR AWS SECRET>
    BUCKET=s3://your-public-bucket

    docker run \
    --env aws_key=${AWS_KEY} \
    --env aws_secret=${AWS_SECRET} \
    --env cmd=download-graph \
    --env SRC_S3=${BUCKET} \
    -p 8080:8080 \
    docker-opentripplanner-withgraph


* After the graph has been built, the planner is available at port 8080.

### Environment variables

**JAVA_MX**: The amount of heap space available to OpenTripPlanner. (The `otp`
             command adds `-Xmx$JAVA_MX` to the `java` command.) Default: 1G
