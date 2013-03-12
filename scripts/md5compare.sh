#!/bin/bash -x
#
# This script performs and md5 calculation recursively on a specific set of file types
# and outputs the results to a provided file

usage () {
        echo -e "Usage: $0 -s <base directory> -r <report_file> \n"
}

while :
do
    case $1 in
        -h | --help | -\?)
                usage
                exit 0
                ;;
        -s | --basedir)
                base_dir=$2
                shift 2
                ;;
        -r | --report)
                report_file=$2
                shift 2
                ;;
        *)
                break
                ;;
    esac
done

# required paramters
if [ -z $report_file ];then
        echo "Missing report file"
        usage
        exit 1
fi
if [ -z $base_dir ] ;then
        echo "Missing base directory"
        usage
        exit 1
fi



# Determine the md5sums from the new provided directory, directory errors are just shoved to null
cd $base_dir
find . \( -iname "*.php" -o -iname "*.phtml" -o -iname "*.swf" \) -print0 | xargs -0 md5sum > $report_file
