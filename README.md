# Securing CafeCoffeeCo's Azure testing infrastructure with VM-Series firewalls

I have used terraform to build CafeCoffeeCo's testing website, Panorama server and VM-Series firewalls. Each terraform script deploys a resource group with multipe resources. There will be total of three VNETs (App, Management and Transit). Download the scripts using:

```
git clone (targetURL)
```

## 1. CafeCoffeeCo Application Setup

Terraform script in the [ccc-azure-app](targetURL) folder deploys an Apache2 webserver running on Ubuntu 22.04 LTS with the IP address of 10.112.1.4. The NSG assinged to the subnet allows access from any source IP address to tcp port 22 and 80.

### Deplyment steps

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







## 2. CafeCoffeeCo Panorama (Management) Setup 

## 3. CafeCoffeeCo Common VM-series Firewall Setup

## 4. Palo Alto Netowrk Terraform Modules



