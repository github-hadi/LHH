# Securing CafeCoffeeCo's Azure testing infrastructure with VM-Series firewalls

I have used terraform to build CafeCoffeeCo's testing website, Panorama server and VM-Series firewalls. Each terraform script deploys a resource group with multipe resources. There will be total of three VNETs (App, Management and Transit). 

**Note: This guide is written for bash shell**

- Download the scripts using:

    ```
    git clone https://github.com/Learning-Happy-Hour/cafecoffeeco-vmseries-testing-azure.git
    ```
## 1. CafeCoffeeCo Application Setup

Terraform script in the [ccc-azure-app](https://github.com/Learning-Happy-Hour/cafecoffeeco-vmseries-testing-azure/tree/master/ccc-testing-vmseries-terraform-azure/ccc-azure-app-deployment) folder deploys an Apache2 webserver on Ubuntu 22.04 LTS with the IP address of 10.112.1.4. The NSG assinged to the subnet allows access from any source IP address to tcp port 22 and 80.

### Deployment steps:

+ (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary

- initialize the Terraform module:

    ```
    terraform init
    ```
- (optional) plan you infrastructure to see what will be actually deployed:
    
     ```
    terraform plan
    ```    
- deploy the infrastructure (you will have to confirm it with typing in yes):

    ```
    terraform apply
    ```
- the deployment takes a few minutes. the output should be similar to the below screenshot: 


        screenshot




## 2. CafeCoffeeCo Panorama (Management) Setup 

The Terraform script in [ccc-panorama](https://github.com/Learning-Happy-Hour/cafecoffeeco-vmseries-testing-azure/tree/master/ccc-testing-vmseries-terraform-azure/ccc-panorama) folder deploys a Panorama server (version 10.2.3) with one NIC. the NIC will have a private IP address of 10.255.0.4 and a dynamic public IP address. Once panorama web inteface is reachable, login to the server to import and load the baseline configuration. follow the below deployment steps for more info.

### Deployment steps

+ (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary

- Initialize the Terraform module:

    ```
    terraform init
    ```
- (optional) plan you infrastructure to see what will be actually deployed:
    
     ```
    terraform plan
    ```    
- Deploy the infrastructure (you will have to confirm it with typing in yes):

    ```
    terraform apply
    ```
- The deployment takes around 10 minutes. the output should be similar to the below screenshot: 


        screenshot

- Wait for a few minutes for Panorama to boot up.
- Use the public IP address in output summary to connect to panorama:

    https://\<panorama-public-ip\>

-  username: panadmin

- For password run the below command:

    ```
    terraform output password
    ```
- Login to panorama and load the baselie config ([basline-config.xml](https://github.com/Learning-Happy-Hour/cafecoffeeco-vmseries-testing-azure/blob/master/ccc-testing-vmseries-terraform-azure/ccc-panorama/baseline-config.xml)).
- Before commiting the configuation, make sure you define a new Panorama administrator so you don't lock yourself out!
- License the Panorama.
- Install the Software Licensing Plugin. 
- Under the plugin, add a bootstrap definition and a license manager.
- Commit the config
- take a note of bootstrap parameter under the license manager


## 3. CafeCoffeeCo Common VM-series Firewall Setup

The Terraform script in [ccc-common-vmseries](https://github.com/Learning-Happy-Hour/cafecoffeeco-vmseries-testing-azure/tree/master/ccc-testing-vmseries-terraform-azure/ccc-common-vmseries) folder deploys two vm-series firewall with four vCPUs and three interface, a public loadbalancer and a private loadbalancer. It configures vnet peering between transit vnet and the other two vnets. To ensure that the web server has inbound and outbound internet access follow the below steps.


### Deployment steps

- Setup bootstrapping options in  **terraform.tfvars** file. copy **auth-key** value from bootstrap parameters under the plugin license manager and paste it in **bootstrap_options** auth-key value for both fw-1 and fw-2:  

    ```
    nano terraform.tfvars
    ```
    the result should look like:

    
    > bootstrap_options = "type=dhcp-client;panorama-server=10.255.0.4;__**auth-key=\<auth-key-value\>**__;dgname=Azure Transit_DG;tplname=Azure Transit_TS;plugin-op-commands=panorama-licensing-mode-on;dhcp-accept-server-hostname=yes;dhcp-accept-server-domain=yes"
    

- (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary

- Initialize the Terraform module:

    ```
    terraform init
    ```
- (optional) plan you infrastructure to see what will be actually deployed:
    
     ```
    terraform plan
    ```    
- Deploy the infrastructure (you will have to confirm it with typing in yes):

    ```
    terraform apply
    ```
- It will take up to 15 minutes to successfully build the resources. Once finished the result should look like:

        Screenshot

- While the resources are being deployed, define a route table in ccc-app-rg resource group. Create a UDR for desitnation 0.0.0.0/0 with the next hop of 10.112.0.21 (private LB's fronetEnd IP address). Associate the route with app-subnet01.
- the effective route on app-nic should look like:

            screenshot

- get the frotend IP address of Public LB:
    ```
    terraform output lb_frontend_ips.public
    ```
- Go to panorama and replace the 


- commit and push the configuraiton
- CafeCoffeeCo's website should be accessabile after a successful commit.

## 4. Useful Links

- [Terraform for Software NGFW](https://pan.dev/swfw/) 
- [Palo Alto Networks  Reference Architecture Guides](https://www.paloaltonetworks.com/resources/reference-architectures)
- [Terraform VM-Series Modules in Github](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules)
- [Palo Alto Networks as Code with Terraform](https://pan.dev/terraform/)
- [VM-Series Tech Docs](https://docs.paloaltonetworks.com/vm-series)
- [Software NGFW Credit Estimator](https://www.paloaltonetworks.com/resources/tools/ngfw-credits-estimator)



