# jenkins-pipeline-artifacts

This repository contains the resources needed for the CICD pipelines

#### Folder Structure
The following diagram shows the folder structure in this repository:

```
.
├── cfn
│   └── jenkins.yaml
├── jenkinsfile
│   ├── aws
│   │   └── Jenkinsfile
│   └── k8s
├── README.md
└── scripts
    ├── packer
    │   ├── packer.json
    │   └── packer-resources
    │       ├── conf
    │       │   ├── limits.conf
    │       │   ├── sources.list
    │       │   └── sysctl.conf
    │       ├── config.sh
    │       └── util
    │           ├── bashScripts
    │           │   └── provision_db_scripts.sh
    │           └── dbScripts
    │               └── is.sql
    └── puppet
        └── apply-config.sh
        └── README.md
```
* cfn: This directory holds the cloud formation template for the Jenkins server.
* jenkinsfile: This directory contains the main pipeline scripts for each infrastructure.
* scripts: This directory holds the utility scripts needed for Packer and Puppet.

Prerequisites
* Replace the files inside the dbScripts directory with the database scripts respective for the deployment pattern.

#### How to Start the Pipeline
The jenkins.yaml file holds the CFN (template file) for the Jenkins server in region us-east-1.

Steps to start:
1.  Upload the jenkins.yaml file as the template.
2.  Specify the required parameters mentioned below.
    *   AWSAccessKeyId - Your AWS Access Key ID.
    *   AWSAccessKeySecret - Your AWS Secret Key.
    You can find your Access key and Secret key from your aws account from below steps.
        -   Log in to your AWS Management Console.
        -   Click on your user name at the top right of the page.
        -   Click on the Security Credentials link from the drop-down menu.
        -   In the Access Credentials section, you can find your Access Key ID.
        -   Click on the Show link in the same row, you can find your Secret Access Key.
    *   KeyPairName - This key pair name will be used as the private key when a user logs in to instances through SSH.
    *   CertificateName - A valid SSL certificate used for HTTPS.
    *   WSO2InstanceType - The AWS instance type that you want to create. This must be any of the following valid EC2 instance types:
        -   t2.medium
        -   t2.large
        -   t2.2xlarge
        -   m3.large
        -   m3.xlarge
        -   m3.2xlarge
        -   m4.large
        -   m4.xlarge (recommended)
    *   WUMPassword - Password for WUM.
    *   WUMUsername - Username for WUM.
    *   DBUsername - Database username.
    *   DBPassword - Database password.
    *   JDKVersion - Java version.
    *   Product - Product for which the pipeline is created
            -   EI
            -   IS
    *   DeploymentPattern - Deployment pattern of the product. Given values
            -   ei_integrator
            -   is
    *   GITREPOARTIFACTS - Git URL of the artifact repository. The artifacts in this repository will be deployed from the pipeline.(Sample atrifact repo - https://github.com/wso2-incubator/cicd-test-artifacts.git)
    *   GITREPOCF - Git URL of the repository that contains the CFN scripts for staging and production (https://github.com/wso2-incubator/cicd-deployment-scripts.git).
    *   GITREPOPUPPET - Git URL of the repository that contains the puppet scripts (https://github.com/wso2-incubator/cicd-configurations.git).
    *   Email - In case of any failures in the pipeline, a message will be sent to this email.

3. Create the stack.
4. Once the stack is created, in the stack outputs the jenkins URL will be available under "JenkinsManagementConsoleURL". Now you can log into Jenkins through a web browser using that URL.
5. Go Global Jenkins Credentials, and update your AWS credentials (under aws_creds) and WUM credentials (under wum_creds) respectively.
6. Configure GitHub webhook for the jenkins server. Follow the steps given below.
    - Sign in to your GitHub account.
    - Select the related repository you own.
    - Click "Settings" on the right panel.
    - Then click "Webhooks" on the left panel.
    - Click the "Add WebHook" button.
    - Paste the URL of the Jenkins server in the URL form field. The webhook URL is <Public DNS (IPv4):8080/github-webhook/>
    - Select "application/json" as the content type.
    - Select "Just the push event".
    - Leave the "Active" check box selected.
    - Click "Add webhook" to save the webhook.

           When the webhook is created, the for each push that is made to the repository a jenkins build will be triggered. This will start the pipeline. When two pushes are made at one time, for each push a build will be triggered one after the other.

5.  Make a push to the GitHub repository.

### Jenkins Pipeline Flow
Once the pipeline is started, the following steps will be executed:

1. Setup the environment.
    - clone the repositories and make the directory structure.
2. Build the pack.
    - product pack is created as a .zip file.
3. Build the image for EI Instances.
    - this step returns an AMI ID that is used in steps 4 and 5.
4. Deploy to staging.
    - staging stack is created and the test endpoint is returned. Note that this endpoint is not app-specific. To be able to test app-specific endpoints (in the next step), the test cases should already contain the app-specific URI.
5. Run tests on staging.
    - run tests in the staging environment.
6. Deploy to production.
    - production stack is created and the test endpoint for the production environment is returned. Note that this endpoint is not app-specific. To be able to test app-specific endpoints in the next step, the test cases should already contain the app-specific URI.
7. Run tests on production.

This pipeline uses the Jenkins shared library. This repository contains the set of functions that is used in the pipeline. This repository is intended to keep the generic methods that is used by the pipeline. For more information on how to use this library check the repository at https://github.com/wso2-incubator/jenkins-shared-lib.

### How to Configure the Pipeline for another Region

To configure the CICD pipeline for any region: Copy the AMI specified for us-east-1 region (under mappings) in the Jenkins.yaml file to the region you require. Then specify the copied AMI along with the region in the Jenkins.yaml file under mappings.
