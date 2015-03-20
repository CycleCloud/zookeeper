CycleCloud ZooKeeper Sample Cluster
===================================

The CycleCloud ZooKeeper sample demonstrates configuring and launching a basic Apache
ZooKeeper ( https://zookeeper.apache.org/ ) cluster from CycleCloud.


Pre-Requisites
--------------

This sample requires the following:

  1. CycleCloud must be installed and running.

     a. If this is not the case, see the CycleCloud QuickStart Guide for assistance.

  2. The CycleCloud CLI must be installed and configured for use.

  3. You must have access to log in to CycleCloud.

  4. You must have access to upload data and launch instances in your chosen Cloud Provider account.

  5. You must have access to a configured CycleCloud "Locker" for Cluster-Init and Chef storage.

  6. Optional: To use the deployment script, you must have Pogo installed and configured.

     a. You may use your preferred tool to interact with your storage "Locker" instead.


**NOTE:**
::
   
  The instructions in this guide assume the use of Amazon Web Services for the Cloud Provider account.


Usage
=====

A. Importing the Cluster Template
---------------------------------

To import the cluster:

  1. Open a terminal session with the CycleCloud CLI enabled.

  2. Switch to the ZooKeeper sample directory.

  3. Run ``cyclecloud import_cluster -t ZooKeeper -f ./zookeeper.txt``.  The expected output looks
     like this:::

       $ cyclecloud import_cluster -t ZooKeeper -f ./zookeeper.txt
       Importing cluster zookeeper and creating cluster zookeeper as a template....
       ----------------------
       ZooKeeper : *template*
       ----------------------
       Keypair: $keypair
       Cluster nodes:
           proxy: off
       Total nodes: 1


B. Deploying the Custom Chef Cookbooks
--------------------------------------

  1. From the same terminal used to import the cluster, run the deploy script:::

       


C. Creating a ZooKeeper Cluster
-------------------------------

  1. Log in to your CycleCloud from your browser.

  2. Click the **"Clusters"** to navigate to the CycleCloud "Clusters" page, if you are not already there.

  3. Click the **"+"** button in the "Clusters" frame to create a new cluster.

  4. In the cluster creation page, click on the **ZooKeeper** cluster icon.

  5. At a minimum, select the Cloud Provider Credentials to use and enter a Name for the cluster.

  6. Click the **"Start"** button.


D. Starting and Stopping the ZooKeeper Cluster
----------------------------------------------

  1. Select the newly created ZooKeeper cluster from the **Clusters** frame on the CycleCloud
     "Clusters" page

  2. To start the cluster, click the **Start** link in the cluster status frame.
     
  3. Later, to stop a started cluster, click the **Terminate** link in the cluster status frame.
     


  
