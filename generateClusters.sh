for i in $(seq 3 3 3)
    do 
        pcluster create-cluster --region us-east-1 --cluster-name global-workflow-cluster-$i --cluster-configuration da_hpc_clean.yaml --rollback-on-failure false --debug
        #pcluster delete-cluster --region us-east-1 --cluster-name da-training-cluster-$i 
    done
