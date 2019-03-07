# platform-automation
Repository for easily using PCF Platform Automation

## Get started quickly

### You will need:
- The URL, username and password of the Ops Manager you want to target
- Your Pivnet API token
- The Pivnet details for the tile you wish to install (slug, version, file glob)
- A private git repo, and a corresponding git private key
- Access to Concourse to run the generated pipeline

### Easy setup:
1. Clone this repo, as well as your private repo, to your local machine, as follows:
```
git clone git@github.com:ciberkleid/platform-automation.git
git clone git@github.com:<YOUR-USERNAME>/<YOUR-PRIVATE-REPO>.git platform-automation-private
```

2. Copy the sample config files from this repo to your private repo:
```
cp -ri platform-automation/config/samples/toolsmiths-pas platform-automation-private
```

3. In your private repo, rename the `toolsmiths-pas` directory you just copied to an alias of your choice for your PCF foundation. Update the alias specified inside of the `common.yml` file as well.

4. Edit the values in your `common.yml` and in any of the tile-specific config files you wish to use. See [here](README.md#build-out-your-tile-config) for tips on changing ops_files and adding/removing parameters from section 3 of the tile-specific config files. Check your changes into your private git repo:
```
cd platform-automation-private
git add .
git commit -m "updated config files"
git push
cd ..
```

5. Log in to Concourse using "w" as your Concourse target alias and set your pipeline:
```
fly --target w login --team-name <YOUR-CONCOURSE-TEAM-NAME> --concourse-url <YOUR-CONCOURSE-URL>
```

6. Set the pipeline for a given tile using the [fly-set-pipeline.yml](fly-set-pipeline.yml) script. The script will prompt you for the required input. You can also accept the defaults in shown in brackets. The script will also prompt to ask if you wish to unpause and trigger the pipeline.
```
. ./fly-set-pipeline
```

7. The apply-changes job is configured to require a manual trigger. Keep an eye on the pipeline's progress and kick off the apply-changes job manually. Edit the file [pipeline-parameterized.yml](pipeline-parameterized.yml) to make the trigger(s) automatic rather than manual.

That's it! You're done.

The next section provides guidance on determining the list of params for section 3 of the tile-specific config files based on changes to the choice of ops_files.

## Build Out Your Tile Config
If the sample config files do not reflect the configuration you wish to use, or if you want to create config files for tiles not represented in the samples, this section is for you.

Steps:

1. Run the [design-config.sh](design-config.sh) script to produce the parameters you will need to set for a given tile installation. For example:
```
. ./design-config.sh #follow prompts to provide your config file
```
or, for example:
```
. ./design-config.sh ~/workspace/platform-automation-private/toolsmiths-pas/pivotal-mysql.yml
```

2. Edit the ops_files in your tile config file.

Repeat steps 1 and 2 until you are satisfied with your configuration.

3. Copy parameters provided by [design-config.sh](design-config.sh) to your tile config file and assign values as needed. Remember to add a ":" to all parameters, even if you are leaving the value empty.
