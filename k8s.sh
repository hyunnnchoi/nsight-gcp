
#!/bin/bash
STARTTIME=`date "+%H:%M:%S.%N"`
STARTLOGTIME=$(($(date +%s%N)/1000000000))
TFPATH="/home/jhlee21/tfjob"
# xsailor
SAVEPATH="/mnt/sdb/share_dir/tfjob"

sudo rm -rf ${SAVEPATH}/*
echo "$STARTTIME" > ${SAVEPATH}/start_makespan.txt

# ssh on-prem
ssh xsailor2@163.152.20.132 "sudo sh /home/jhlee21/gpu.sh &" &
ssh xsailor3@163.152.20.155 "sudo sh /home/jhlee21/gpu.sh &" &


MODEL="a0_squad_gpt2l_sync_batch8"
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a1_cifar10_alexnet_sync_batch32768"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a2_squad_bert_sync_batch8"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a3_cifar10_resnet110_sync_batch2048"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a4_squad_gpt2xl_sync_batch8"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a5_squad_gpt2xl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a6_imagenet_vgg16_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a7_imagenet_vgg16_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a8_cifar10_alexnet_sync_batch8192"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a9_cifar10_densenet100_k12_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a10_squad_bert_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a11_squad_gpt2l_sync_batch8"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a12_imagenet_vgg16_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a13_squad_gpt2xl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a14_imagenet_vgg16_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a15_squad_bert_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a16_squad_gpt2l_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a17_cifar10_alexnet_sync_batch8192"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a18_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a19_squad_bertl_sync_batch8"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a20_squad_bert_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a21_cifar10_densenet100_k12_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a22_squad_gpt2_sync_batch8"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a23_squad_gpt2_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a24_squad_bertl_sync_batch8"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a25_imagenet_vgg16_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a26_cifar10_resnet110_sync_batch4096"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a27_cifar10_densenet100_k12_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a28_squad_gpt2_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a29_imagenet_resnet50_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a30_squad_bert_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a31_cifar10_densenet100_k12_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a32_squad_bertl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a33_cifar10_densenet100_k12_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a34_cifar10_resnet110_sync_batch4096"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a35_squad_gpt2_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a36_imagenet_vgg16_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a37_squad_bert_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a38_cifar10_resnet110_sync_batch8192"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a39_cifar10_resnet110_sync_batch8192"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a40_squad_gpt2xl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 6 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a41_imagenet_resnet50_sync_batch256"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a42_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a43_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a44_cifar10_densenet100_k12_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a45_squad_bertl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a46_imagenet_vgg16_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a47_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a48_squad_gpt2xl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a49_cifar10_resnet110_sync_batch4096"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a50_squad_bertl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a51_squad_bert_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a52_cifar10_resnet110_sync_batch8192"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a53_cifar10_resnet110_sync_batch8192"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a54_squad_gpt2_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a55_cifar10_densenet100_k12_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a56_cifar10_densenet100_k12_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a57_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a58_squad_gpt2xl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a59_squad_gpt2xl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a60_squad_gpt2_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a61_cifar10_densenet100_k12_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a62_cifar10_alexnet_sync_batch16384"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a63_cifar10_resnet110_sync_batch4096"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a64_squad_bert_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a65_cifar10_alexnet_sync_batch32768"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a66_imagenet_vgg16_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a67_squad_gpt2_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a68_squad_bert_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a69_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a70_cifar10_alexnet_sync_batch32768"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a71_squad_gpt2_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a72_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a73_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a74_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a75_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a76_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a77_squad_gpt2xl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a78_cifar10_densenet100_k12_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a79_squad_bert_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a80_squad_gpt2xl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a81_imagenet_vgg16_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a82_cifar10_alexnet_sync_batch32768"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a83_squad_gpt2_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a84_cifar10_alexnet_sync_batch16384"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a85_squad_gpt2xl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a86_cifar10_alexnet_sync_batch32768"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a87_cifar10_resnet110_sync_batch4096"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a88_squad_bertl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a89_imagenet_vgg16_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a90_squad_bertl_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a91_squad_bertl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a92_imagenet_resnet50_sync_batch1024"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a93_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a94_squad_gpt2_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a95_cifar10_alexnet_sync_batch16384"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a96_squad_bertl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a97_imagenet_resnet50_sync_batch512"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 4 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a98_squad_bertl_sync_batch16"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
while [ $WORKERNUM -gt 0 ]
do
COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "_" $i
        }
        print jobname
        }'`
    done
    for completed_pod in ${COMPLETED}; do
    COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
        jobname = jobname "-" $i
        }
        print jobname
    }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done

MODEL="a99_squad_gpt2l_sync_batch32"
sudo rm -rf ${SAVEPATH}/${MODEL}
mkdir -p ${SAVEPATH}/${MODEL}
#### Training the model
date "+%H:%M:%S.%N" > ${SAVEPATH}/${MODEL}_job_create.txt
kubectl create -f ${TFPATH}/net_script/${MODEL}_k8s.yaml
sleep 0.1s

RUNNING=`kubectl get pod -o wide | awk '{print $1}' | sed -n '1p'`
while [ -n "${RUNNING}" ]
do
  COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{print $1}' | sed -n '1p'`
  if [ -n "${COMPLETED}" ]; then
    for completed_pod in ${COMPLETED}; do
      COMPLETED_JOB=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
          jobname = jobname "_" $i
        }
        print jobname
      }'`
    done
    for completed_pod in ${COMPLETED}; do
      COMPLETED_JOB_POD=`echo ${completed_pod} | awk -F '-' '{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {
          jobname = jobname "-" $i
        }
        print jobname
      }'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${COMPLETED_JOB_POD} | awk '{print $1 "\t" $7}' > ${SAVEPATH}/${COMPLETED_JOB}_node_info.txt
    echo $(date "+%H:%M:%S.%N") > ${SAVEPATH}/${COMPLETED_JOB}_job_finished.txt
    kubectl delete -f ${TFPATH}/net_script/${COMPLETED_JOB}_k8s.yaml
  fi
  sleep 0.1s;
  RUNNING=`kubectl get pod -o wide | awk '{print $1}' | sed -n '1p'`
done

ENDTIME=`date "+%H:%M:%S.%N"`
echo "$ENDTIME" > ${SAVEPATH}/end_makespan.txt
ENDLOGTIME=$(($(date +%s%N)/1000000000))
LOGTIME=$(($ENDLOGTIME - $STARTLOGTIME))
kubectl logs -n kube-system --since $(($LOGTIME+5))s kube-scheduler-xsailor-master > ${SAVEPATH}/scheduler_log.txt
kubectl logs -n kube-system kube-scheduler-xsailor-master  > ${SAVEPATH}/scheduler_full_log.txt
# On-prem
ssh xsailor2@163.152.20.132 "sudo sh /home/jhlee21/gpu_off.sh"
ssh xsailor3@163.152.20.155 "sudo sh /home/jhlee21/gpu_off.sh"
