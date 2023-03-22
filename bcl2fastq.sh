#!/bin/bash

display_usage(){
  echo -e "\nUsage:"
  echo -e "\t$(basename $0) SampleSheet.csv\n"
}

<<<<<<< HEAD
samplesheet=$1

if [ -z "$samplesheet" ]; then
=======
samplesheet=${1}

if [ -z "${samplesheet}" ]; then
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
  display_usage
  exit 1
fi

<<<<<<< HEAD
bcl2fastq -R . -r $(nproc) -p $(nproc) -w $(nproc) --no-lane-splitting --fastq-compression-level 9 --minimum-trimmed-read-length 70 -l NONE -o fastq --sample-sheet $samplesheet
=======
bcl2fastq -R ./ -r $(nproc) -p $(nproc) -w $(nproc) --no-lane-splitting --fastq-compression-level 9 --minimum-trimmed-read-length 70 -l NONE -o fastq2 --sample-sheet ${samplesheet}
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

# -r $(nproc) -p $(nproc) -w $(nproc)
# cd /run_directory_of_your_choice # Should contain RunInfo.xml
# bcl2fastq --input-dir /yourdirectory/blabla/Data/Intensities/BaseCalls --output-dir /yourdirectory
<<<<<<< HEAD
=======
# -i Data/Intensities/BaseCalls
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
