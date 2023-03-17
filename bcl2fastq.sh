#!/bin/bash

display_usage(){
  echo -e "\nUsage:"
  echo -e "\t$(basename $0) SampleSheet.csv\n"
}

samplesheet=${1}

if [ -z "${samplesheet}" ]; then
  display_usage
  exit 1
fi

bcl2fastq -R ./ -r $(nproc) -p $(nproc) -w $(nproc) --no-lane-splitting --fastq-compression-level 9 --minimum-trimmed-read-length 70 -l NONE -o fastq2 --sample-sheet ${samplesheet}

# -r $(nproc) -p $(nproc) -w $(nproc)
# cd /run_directory_of_your_choice # Should contain RunInfo.xml
# bcl2fastq --input-dir /yourdirectory/blabla/Data/Intensities/BaseCalls --output-dir /yourdirectory
# -i Data/Intensities/BaseCalls
