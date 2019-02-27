# platform-automation
Repository for using platform-automation

Before you start, you should have:

1. The URL, username and password of the Ops Manager you want to target
2. Your Pivnet API api_token
3. The Pivnet details for the tile you wish to install (slug, version, file glob)
4. A private git repo, and a corresponding git private key 

Instructions:
1. Clone this repo to your local machine
2. Follow the directions at the head of file `config-template-common.yml`
3. Follow the directions at the head of file `config-template.yml`
4. Set your fly target using the alias "w"
5. Log in to your fly cli
6. Run the script 'fly-set-pipeline'
7. Unpause the generated pipeline and start the first job
