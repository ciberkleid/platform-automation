# platform-automation
Repository for easily using PCF Platform Automation


## Before you start, you should have:

1. The URL, username and password of the Ops Manager you want to target
2. Your Pivnet API token
3. The Pivnet details for the tile you wish to install (slug, version, file glob)
4. An export of the default tile configuration. The pipeline uses [this tile configuration repo](https://github.com/daxterm/tile-configuration) directly, so just make sure the tile/version you want is there.
5. The build number. This is the number in the path to the tile configuration files from step 4 above. Sometimes it's the same as the version number, but sometimes it's different. Check the tile configuration repo above.
6. A private git repo, and a corresponding git private key
7. Access to Concourse to run the generated pipeline

## Instructions:

1. Clone this repo to your local machine
2. Copy the file `config-template-common.yml`. Update the values so that they are valid for your PCF foundation and push it to your private git repo using the following naming convention: **private-repo-root/foundation/common.yml**
     - For reference, please see the `config-sample` directory in this repository
3. Copy the file `config-template.yml` and rename it using the slug (e.g. `p-rabbitmq.yml`, `pivotal-mysql.yml`, etc). Edit the values in section 1 (slug, version, build), as well as the values in the paths in section 2 (slug, build). Then, run the `config-designer.sh` script to produce the parameters for which you will need to provide values.
     - You can add ops files to your config file (section 2) and rerun `config-designer.sh` as many times as necessary. The selection of ops files to choose from can be found on the tile configuration repo (see step 4 above), or in the local `_tmp/vars` directory, as the script will clone the repo there.
     - For reference, please see the `config-sample` directory in this repository
     - Note:
       - Use `vars` as parent for ops file paths (see sample config files)
       - `ops_files` can each be a space-delimited list
       - If no ops files are needed, use `ops_files:  env/common/config/templates/empty-file.yml`
       - Note that `config_file` does not need to specify a parent dir above the slug
       - Once you are satisfied with the configuration, copy the list of parameters to section 3 and provide values.
    - Finally, push the config file to your private repo using the following convention: **private-repo-root/foundation/slug.yml**   
4. Edit the file `fly-set-pipeline.sh` so that the `credentials` resource points to your private repo
5. Run the script `fly-set-pipeline.sh`. The script assumes a target alias `w`
6. Unpause the generated pipeline and start the first job
