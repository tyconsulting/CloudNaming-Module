# PowerShell module for Cloud Naming Standard

## Introduction

The CloudNaming PowerShell module can be used to programmatically generate cloud resource names for your organization.

It can be used as a standalone module, or as part of a Infrastructure as Code (IaC) pipeline.

It is highly customizable, and supports any cloud providers of your choice. The documentation and instruction can be found at the [project's wiki page](https://github.com/tyconsulting/CloudNaming-Module/wiki).

## Pipeline Examples

The [pipeline-examples](pipeline-examples) folder contains 3 sample Azure DevOps YAML pipelines to demonstrate how to use the CloudNaming module in a CI/CD pipeline:

* **[azure-pipelines-demo-1.yaml](./pipeline-examples/pipelines/azure-pipelines-demo-1.yaml)**: Beginner's level pipeline
  * Install module from a private Azure Artifacts feed
  * Does not use custom configuration file
  * Generate resource names one at a time

* **[azure-pipelines-demo-2.yaml](./pipeline-examples/pipelines/azure-pipelines-demo-2.yaml)**: Advanced level pipeline
  * Install module from PowerShell Gallery
  * Uses custom [configuration file](./pipeline-examples/config/customCloudNaming.json) located in the repository
  * Generate resource names one at a time
  * Generate multiple resource names at once

* **[azure-pipelines-install-azure-artifacts.yaml](./pipeline-examples/pipelines/azure-pipelines-install-azure-artifacts.yaml)**: Example on how to publish a customized version of the CloudNaming module to an Azure Artifacts organization-level feed.


## Status

[![Status](https://github.com/tyconsulting/CloudNaming-Module/actions/workflows/main.yml/badge.svg)](https://github.com/tyconsulting/CloudNaming-Module/actions/workflows/main.yml)