# nf-core/hic: Usage

## Table of contents

* [Introduction](#general-nextflow-info)
* [Running the pipeline](#running-the-pipeline)
* [Updating the pipeline](#updating-the-pipeline)
* [Reproducibility](#reproducibility)
* [Main arguments](#main-arguments)
  * [`-profile`](#-profile-single-dash)
    * [`awsbatch`](#awsbatch)
    * [`conda`](#conda)
    * [`docker`](#docker)
    * [`singularity`](#singularity)
    * [`test`](#test)
  * [`--reads`](#--reads)
  * [`--singleEnd`](#--singleend)
* [Reference genomes](#reference-genomes)
  * [`--genome`](#--genome)
  * [`--fasta`](#--fasta)
  * [`--igenomesIgnore`](#--igenomesignore)
  * [`--bwt2_index`](#--bwt2_index)
  * [`--chromosome_size`](#--chromosome_size)
  * [`--restriction_fragments`](#--restriction_fragments)
* [Hi-C specific options](#hi-c-specific-options)
  * [Reads mapping](#reads-mapping)
    * [`--bwt2_opts_end2end`](#--bwt2_opts_end2end)
    * [`--bwt2_opts_trimmed`](#--bwt2_opts_trimmed)
    * [`--min_mapq`](#--min_mapq)
  * [Digestion Hi-C](#digestion-hi-c)
    * [`--restriction_site`](#--restriction_site)
    * [`--ligation_site`](#--ligation_site)
    * [`--min_restriction_fragment_size`](#--min_restriction_fragment_size)
    * [`--max_restriction_fragment_size`](#--max_restriction_fragment_size)
    * [`--min_insert_size`](#--min_insert_size)
    * [`--max_insert_size`](#--max_insert_size)
  * [DNase Hi-C](#dnase-hi-c)
    * [`--dnase`](#--dnase)
  * [Hi-C Processing](#hi-c-processing)
    * [`--min_cis_dist`](#--min_cis_dist)
    * [`--rm_singleton`](#--rm_singleton)
    * [`--rm_dup`](#--rm_dup)
    * [`--rm_multi`](#--rm_multi)
  * [Genome-wide contact maps](#genome-wide-contact-maps)
    * [`--bins_size`](#--bins_size)
    * [`--ice_max_iter`](#--ice_max_iter)
    * [`--ice_filer_low_count_perc`](#--ice_filer_low_count_perc)
    * [`--ice_filer_high_count_perc`](#--ice_filer_high_count_perc)
    * [`--ice_eps`](#--ice_eps)
  * [Inputs/Outputs](#inputs-outputs)
    * [`--splitFastq`](#--splitFastq)
    * [`--saveReference`](#--saveReference)
    * [`--saveAlignedIntermediates`](#--saveAlignedIntermediates)
* [Skip options](#skip-options)
  * [--skip_maps](#--skip_maps)
  * [--skip_ice](#--skip_ice)
  * [--skip_cool](#--skip_cool)
  * [--skip_multiqc](#--skip_multiqc)  
* [Job resources](#job-resources)
* [Automatic resubmission](#automatic-resubmission)
* [Custom resource requests](#custom-resource-requests)
* [AWS batch specific parameters](#aws-batch-specific-parameters)
  * [`-awsbatch`](#-awsbatch)
  * [`--awsqueue`](#--awsqueue)
  * [`--awsregion`](#--awsregion)
* [Other command line parameters](#other-command-line-parameters)
  * [`--outdir`](#--outdir)
  * [`--email`](#--email)
  * [`-name`](#-name-single-dash)
  * [`-resume`](#-resume-single-dash)
  * [`-c`](#-c-single-dash)
  * [`--custom_config_version`](#--custom_config_version)
  * [`--max_memory`](#--max_memory)
  * [`--max_time`](#--max_time)
  * [`--max_cpus`](#--max_cpus)
  * [`--plaintext_email`](#--plaintext_email)
  * [`--multiqc_config`](#--multiqc_config)


## General Nextflow info
Nextflow handles job submissions on SLURM or other environments, and supervises running the jobs. Thus the Nextflow process must run until the pipeline is finished. We recommend that you put the process running in the background through `screen` / `tmux` or similar tool. Alternatively you can run nextflow within a cluster job submitted your job scheduler.

It is recommended to limit the Nextflow Java virtual machines memory. We recommend adding the following line to your environment (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```

## Running the pipeline
The typical command for running the pipeline is as follows:

```bash
nextflow run nf-core/hic --reads '*_R{1,2}.fastq.gz' -genome GRCh37 -profile docker
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work            # Directory containing the nextflow working files
results         # Finished results (configurable, see below)
.nextflow_log   # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

### Updating the pipeline
When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull nf-core/hic
```

### Reproducibility
It's a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [nf-core/hic releases page](https://github.com/nf-core/hic/releases) and find the latest version number - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future.


## Main arguments

### `-profile`
Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments. Note that multiple profiles can be loaded, for example: `-profile docker` - the order of arguments is important!

If `-profile` is not specified at all the pipeline will be run locally and expects all software to be installed and available on the `PATH`.

* `awsbatch`
  * A generic configuration profile to be used with AWS Batch.
* `conda`
  * A generic configuration profile to be used with [conda](https://conda.io/docs/)
  * Pulls most software from [Bioconda](https://bioconda.github.io/)
* `docker`
  * A generic configuration profile to be used with [Docker](http://docker.com/)
  * Pulls software from dockerhub: [`nfcore/hic`](http://hub.docker.com/r/nfcore/hic/)
* `singularity`
  * A generic configuration profile to be used with [Singularity](http://singularity.lbl.gov/)
  * Pulls software from DockerHub: [`nfcore/hic`](http://hub.docker.com/r/nfcore/hic/)
* `test`
  * A profile with a complete configuration for automated testing
  * Includes links to test data so needs no other parameters

### `--reads`
Use this to specify the location of your input FastQ files. For example:

```bash
--reads 'path/to/data/sample_*_{1,2}.fastq'
```

Please note the following requirements:

1. The path must be enclosed in quotes
2. The path must have at least one `*` wildcard character
3. When using the pipeline with paired end data, the path must use `{1,2}` notation to specify read pairs.

If left unspecified, a default pattern is used: `data/*{1,2}.fastq.gz`

## Reference genomes and annotation files

The pipeline config files come bundled with paths to the illumina iGenomes reference index files. If running with docker or AWS, the configuration is set up to use the [AWS-iGenomes](https://ewels.github.io/AWS-iGenomes/) resource.

### `--genome` (using iGenomes)
There are 31 different species supported in the iGenomes references. To run the pipeline, you must specify which to use with the `--genome` flag.

You can find the keys to specify the genomes in the [iGenomes config file](../conf/igenomes.config). Common genomes that are supported are:

* Human
  * `--genome GRCh37`
* Mouse
  * `--genome GRCm38`
* _Drosophila_
  * `--genome BDGP6`
* _S. cerevisiae_
  * `--genome 'R64-1-1'`

> There are numerous others - check the config file for more.

Note that you can use the same configuration setup to save sets of reference files for your own use, even if they are not part of the iGenomes resource. See the [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for instructions on where to save such a file.

The syntax for this reference configuration is as follows:


```nextflow
params {
  genomes {
    'GRCh37' {
      fasta   = '<path to the genome fasta file>' // Used if no annotations are given
      bowtie2 = '<path to bowtie2 index files>'
    }
    // Any number of additional genomes, key is used with --genome
  }
}
```

### `--fasta`
If you prefer, you can specify the full path to your reference genome when you run the pipeline:

```bash
--fasta '[path to Fasta reference]'
```

### `--igenomesIgnore`
Do not load `igenomes.config` when running the pipeline. You may choose this option if you observe clashes between custom parameters and those supplied in `igenomes.config`.

### `--bwt2_index`

The bowtie2 indexes are required to run the Hi-C pipeline. If the `--bwt2_index` is not specified, the pipeline will either use the igenome bowtie2 indexes (see `--genome` option) or build the indexes on-the-fly (see `--fasta` option)

```bash
--bwt2_index '[path to bowtie2 index (with basename)]'
```

### `--chromosome_size`

The Hi-C pipeline will also requires a two-columns text file with the chromosome name and its size (tab separated).
If not specified, this file will be automatically created by the pipeline. In the latter case, the `--fasta` reference genome has to be specified.

```bash
   chr1    249250621
   chr2    243199373
   chr3    198022430
   chr4    191154276
   chr5    180915260
   chr6    171115067
   chr7    159138663
   chr8    146364022
   chr9    141213431
   chr10   135534747
   (...)
```

```bash
--chromosome_size '[path to chromosome size file]'
```

### `--restriction_fragments`

Finally, Hi-C experiments based on restriction enzyme digestion requires a BED file with coordinates of restriction fragments.

```bash
   chr1   0       16007   HIC_chr1_1    0   +
   chr1   16007   24571   HIC_chr1_2    0   +
   chr1   24571   27981   HIC_chr1_3    0   +
   chr1   27981   30429   HIC_chr1_4    0   +
   chr1   30429   32153   HIC_chr1_5    0   +
   chr1   32153   32774   HIC_chr1_6    0   +
   chr1   32774   37752   HIC_chr1_7    0   +
   chr1   37752   38369   HIC_chr1_8    0   +
   chr1   38369   38791   HIC_chr1_9    0   +
   chr1   38791   39255   HIC_chr1_10   0   +
   (...)
```

If not specified, this file will be automatically created by the pipline. In this case, the `--fasta` reference genome will be used.
Note that the `--restriction_site` parameter is mandatory to create this file.

## Hi-C specific options

The following options are defined in the `hicpro.config` file, and can be updated either using a custom configuration file (see `-c` option) or using command line parameter.

### Reads mapping

The reads mapping is currently based on the two-steps strategy implemented in the HiC-pro pipeline. The idea is to first align reads from end-to-end.
Reads that do not aligned are then trimmed at the ligation site, and their 5' end is re-aligned to the reference genome.
Note that the default option are quite stringent, and can be updated according to the reads quality or the reference genome.

#### `--bwt2_opts_end2end`

Bowtie2 alignment option for end-to-end mapping. Default: '--very-sensitive -L 30 --score-min L,-0.6,-0.2 --end-to-end --reorder'

```bash
--bwt2_opts_end2end '[Options for bowtie2 step1 mapping on full reads]'
```

#### `--bwt2_opts_trimmed`

Bowtie2 alignment option for trimmed reads mapping (step 2). Default: '--very-sensitive -L 20 --score-min L,-0.6,-0.2 --end-to-end --reorder'

```bash
--bwt2_opts_trimmed '[Options for bowtie2 step2 mapping on trimmed reads]'
```

#### `--min_mapq`

Minimum mapping quality. Reads with lower quality are discarded. Default: 10

```bash
--min_mapq '[Minimum quality value]'
```

### Digestion Hi-C

#### `--restriction_site`

Restriction motif(s) for Hi-C digestion protocol. The restriction motif(s) is(are) used to generate the list of restriction fragments.
The precise cutting site of the restriction enzyme has to be specified using the '^' character. Default: 'A^AGCTT'
Here are a few examples:
* MboI: '^GATC'
* DpnII: '^GATC'
* BglII: 'A^GATCT'
* HindIII: 'A^AGCTT'

Note that multiples restriction motifs can be provided (comma-separated).

```bash
--restriction_size '[Cutting motif]'
```

#### `--ligation_site`

Ligation motif after reads ligation. This motif is used for reads trimming and depends on the fill in strategy.
Note that multiple ligation sites can be specified. Default: 'AAGCTAGCTT'

```bash
--ligation_site '[Ligation motif]'
```

#### `--min_restriction_fragment_size`

Minimum size of restriction fragments to consider for the Hi-C processing. Default: ''

```bash
--min_restriction_fragment_size '[numeric]'
```

#### `--max_restriction_fragment_size`

Maximum size of restriction fragments to consider for the Hi-C processing. Default: ''

```bash
--max_restriction_fragment_size '[numeric]'
```

#### `--min_insert_size`

Minimum reads insert size. Shorter 3C products are discarded. Default: ''

```bash
--min_insert_size '[numeric]'
```

#### `--max_insert_size`

Maximum reads insert size. Longer 3C products are discarded. Default: ''

```bash
--max_insert_size '[numeric]'
```

### DNAse Hi-C

#### `--dnase`

In DNAse Hi-C mode, all options related to digestion Hi-C (see previous section) are ignored.
In this case, it is highly recommanded to use the `--min_cis_dist` parameter to remove spurious ligation products.

```bash
--dnase'
```

### Hi-C processing

#### `--min_cis_dist`

Filter short range contact below the specified distance. Mainly useful for DNase Hi-C. Default: ''

```bash
--min_cis_dist '[numeric]'
```

#### `--rm_singleton`

If specified, singleton reads are discarded at the mapping step.

```bash
--rm_singleton
```

#### `--rm_dup`

If specified, duplicates reads are discarded before building contact maps.

```bash
--rm_dup
```

#### `--rm_multi`

If specified, reads that aligned multiple times on the genome are discarded. Note the default mapping options are based on random hit assignment, meaning that only one position is kept per read.

```bash
--rm_multi
```

## Genome-wide contact maps

#### `--bin_size`

Resolution of contact maps to generate (space separated). Default:'1000000,500000'

```bash
--bins_size '[numeric]'
```

#### `--ice_max_iter`

Maximum number of iteration for ICE normalization. Default: 100

```bash
--ice_max_iter '[numeric]'
```

#### `--ice_filer_low_count_perc`

Define which pourcentage of bins with low counts should be force to zero. Default: 0.02

```bash
--ice_filter_low_count_perc '[numeric]'
```

#### `--ice_filer_high_count_perc`

Define which pourcentage of bins with low counts should be discarded before normalization. Default: 0

```bash
--ice_filter_high_count_perc '[numeric]'
```

#### `--ice_eps`

The relative increment in the results before declaring convergence for ICE normalization. Default: 0.1

```bash
--ice_eps '[numeric]'
```

## Inputs/Outputs

#### `--splitFastq`

By default, the nf-core Hi-C pipeline expects one read pairs per sample. However, for large Hi-C data processing single fastq files can be very time consuming.
The `--splitFastq` option allows to automatically split input read pairs into chunks of reads. In this case, all chunks will be processed in parallel and merged before generating the contact maps, thus leading to a significant increase of processing performance.

```bash
--splitFastq '[Number of reads per chunk]'
```

#### `--saveReference`

If specified, annotation files automatically generated from the `--fasta` file are exported in the results folder. Default: false

```bash
--saveReference
```

#### `--saveAlignedIntermediates`

If specified, all intermediate mapping files are saved and exported in the results folder. Default: false

```bash
--saveReference
```

## Skip options

#### `--skip_maps`

If defined, the workflow stops with the list of valid interactions, and the genome-wide maps are not built. Usefult for capture-C analysis. Default: false

```bash
--skip_maps
```

#### `--skip_ice`

If defined, the ICE normalization is not run on the raw contact maps. Default: false

```bash
--skip_ice
```

#### `--skip_cool`

If defined, cooler files are not generated. Default: false

```bash
--skip_cool
```

#### `--skip_multiqc`

If defined, the MultiQC report is not generated. Default: false

```bash
--skip_multiqc
```

## Job resources
### Automatic resubmission
Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with an error code of `143` (exceeded requested resources) it will automatically resubmit with higher requests (2 x original, then 3 x original). If it still fails after three times then the pipeline is stopped.

### Custom resource requests
Wherever process-specific requirements are set in the pipeline, the default value can be changed by creating a custom config file. See the files hosted at [`nf-core/configs`](https://github.com/nf-core/configs/tree/master/conf) for examples.

If you are likely to be running `nf-core` pipelines regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter (see definition below). You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

If you have any questions or issues please send us a message on [`Slack`](https://nf-core-invite.herokuapp.com/).

## AWS Batch specific parameters
Running the pipeline on AWS Batch requires a couple of specific parameters to be set according to your AWS Batch configuration. Please use the `-awsbatch` profile and then specify all of the following parameters.
### `--awsqueue`
The JobQueue that you intend to use on AWS Batch.
### `--awsregion`
The AWS region to run your job in. Default is set to `eu-west-1` but can be adjusted to your needs.

Please make sure to also set the `-w/--work-dir` and `--outdir` parameters to a S3 storage bucket of your choice - you'll get an error message notifying you if you didn't.

## Other command line parameters

### `--outdir`
The output directory where the results will be saved.

### `--email`
Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. If set in your user config file (`~/.nextflow/config`) then you don't need to speicfy this on the command line for every run.

### `-name`
Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.

This is used in the MultiQC report (if not default) and in the summary HTML / e-mail (always).

**NB:** Single hyphen (core Nextflow option)

### `-resume`
Specify this when restarting a pipeline. Nextflow will used cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously.

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

**NB:** Single hyphen (core Nextflow option)

### `-c`
Specify the path to a specific config file (this is a core NextFlow command).

**NB:** Single hyphen (core Nextflow option)

Note - you can use this to override pipeline defaults.

### `--custom_config_version`
Provide git commit id for custom Institutional configs hosted at `nf-core/configs`. This was implemented for reproducibility purposes. Default is set to `master`.

```bash
## Download and use config file with following git commid id
--custom_config_version d52db660777c4bf36546ddb188ec530c3ada1b96
```

### `--max_memory`
Use to set a top-limit for the default memory requirement for each process.
Should be a string in the format integer-unit. eg. `--max_memory '8.GB'`

### `--max_time`
Use to set a top-limit for the default time requirement for each process.
Should be a string in the format integer-unit. eg. `--max_time '2.h'`

### `--max_cpus`
Use to set a top-limit for the default CPU requirement for each process.
Should be a string in the format integer-unit. eg. `--max_cpus 1`

### `--plaintext_email`
Set to receive plain-text e-mails instead of HTML formatted.

### `--multiqc_config`
Specify a path to a custom MultiQC configuration file.
