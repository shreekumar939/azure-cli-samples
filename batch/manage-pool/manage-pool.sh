#!/bin/bash

# Authenticate Batch account CLI session.
az batch account login -g myresource group -n mybatchaccount

# Create a new Windows PaaS pool with 3 Standard A1 VMs.
az batch pool create \
    --id mypool-windows \
    --os-family 4 \
    --target-dedicated 3 \
    --vm-size small \

# We can add some metadata to the pool.
az batch pool set --pool-id mypool-windows --metadata IsWindows=true VMSize=StandardA1

# Retrieve a list of available IaaS images and node agent SKUs
az batch pool node-agent-skus list

# Create a new Linux IaaS pool with an application reference and a start task that will
# copy the application files to a shared directory. The image reference and node agent SKUs
# ID can be selected from the ouptputs of the above list command.
# The image reference is in the format: {publisher}:{offer}:{sku}:{version} where {version} is
# optional and will default to 'latest'.
az batch pool create \
    --id mypool-linux \
    --vm-size Standard_A1 \
    --image canonical:ubuntuserver:16.04.0-LTS \
    --node-agent-sku-id batch.node.ubuntu 16.04 \
    --start-task-command-line "cmd /c xcopy %AZ_BATCH_APP_PACKAGE_MYAPP% %AZ_BATCH_NODE_SHARED_DIR%" \
    --start-task-wait-for-success \
    --application-package-references myapp

# Now lets resize the IaaS pool to start up some VMs.
az batch pool resize --pool-id mypool-linux --target-dedicated 5

# We can check the status of the pool to see when it has finished resizing
az batch pool show --pool-id mypool-linux

# List the compute nodes running in a pool.
az batch node list --pool-id mypool-linux

# If a particular node in the pool is having issues, it can be rebooted or reimaged.
# The ID of the node can be retrieved with the list command above.
az batch node reboot --pool-id mypool-linux --node-id node1

# Alternatively, one or more compute nodes can be deleted from the pool, and any
# work already assigned to it can be re-allocated to another node.
az batch node delete \
    --pool-id mypool-linux \
    --node-list node1 node2 \
    --node-deallocation-option requeue
