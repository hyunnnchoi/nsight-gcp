# Changes
# - CPU request, limit can be adjusted
# - yaml.safe_load() deleted due to linebreaks

import sys
import argparse

# Xsailor local vs. GCP
is_GCP = False
nodes = []
if is_GCP:
    nodes = ['xsailor-worker-t6', 'xsailor-worker-t7', 'xsailor-worker-t8', 'xsailor-worker-t9']

# select from ['k8s', 'vol', 'colo', 'spot', 'tiresias']
parser = argparse.ArgumentParser(prog='YamlShGenerator', description='generates sh and job manifest yaml')
parser.add_argument('-s', '--scheduler', required=True, help='select from k8s, vol, colo, spot, tiresias')
args = parser.parse_args()
scheduler_name = args.scheduler

# [WARNING] GPU num should be checked
total_gpu_num = 4 * len(nodes) if nodes else 8
print(f'Training with total gpu num: {total_gpu_num}')

# [(model name, # of workers, # of iterations)]
#traceOct8-3ps
# train_trace = [('densenet40_k12', 2, 1609), ('inception3', 3, 318), ('googlenet', 4, 1024), ('resnet44', 4, 1593), ('densenet40_k12', 3, 1478),
# ('resnet56', 3, 1403), ('densenet40_k12', 3, 1506), ('densenet100_k12', 1, 782), ('densenet100_k12', 1, 781), ('vgg16', 2, 58),
# ('resnet44', 3, 1684), ('densenet100_k12', 4, 537), ('vgg16', 3, 54), ('resnet56', 2, 1417), ('resnet50', 2, 452),
# ('alexnet', 1, 11062), ('resnet50', 1, 585), ('resnet110', 1, 1856), ('alexnet', 4, 3516), ('resnet50', 2, 454),
# ('vgg16', 1, 164), ('densenet40_k12', 4, 1386), ('inception3', 4, 291), ('resnet56', 2, 1585), ('alexnet', 2, 3762),
# ('resnet110', 3, 809), ('resnet44', 3, 1686), ('resnet44', 3, 1727), ('googlenet', 3, 1108), ('googlenet', 1, 1441),
# ('alexnet', 4, 3470), ('googlenet', 2, 1150), ('resnet110', 4, 701), ('densenet100_k12', 1, 795), ('vgg16', 1, 176),
# ('inception3', 1, 415), ('inception3', 4, 292), ('resnet110', 2, 870), ('resnet50', 4, 365), ('resnet56', 2, 1593)]
train_trace = [
  ('densenet100_k12', 1, 600), ('densenet100_k12', 2, 600), ('densenet100_k12', 4, 600), ('densenet100_k12', 8, 600), 
 ('densenet40_k12', 1, 600), ('densenet40_k12', 2, 600),('densenet40_k12', 4, 600),('densenet40_k12', 8, 600),
 ('alexnet', 1, 600), ('alexnet', 2, 600), ('alexnet', 4, 600), ('alexnet', 8, 600),
 ('resnet110', 1, 600), ('resnet110', 2, 600), ('resnet110', 4, 600), ('resnet110', 8, 600),
 ('resnet44', 1, 600), ('resnet44', 2, 600), ('resnet44', 4, 600), ('resnet44', 8, 600),
 ('googlenet', 1, 600), ('googlenet', 2, 600), ('googlenet', 4, 600), ('googlenet', 8, 600),
 ('inception3', 1, 600), ('inception3', 2, 600), ('inception3', 4, 600), ('inception3', 8, 600),
 ('densenet100_k12', 1, 1), ('densenet100_k12', 2, 1), ('densenet100_k12', 4, 1), ('densenet100_k12', 8, 1), 
 ('densenet40_k12', 1, 1), ('densenet40_k12', 2, 1),('densenet40_k12', 4, 1),('densenet40_k12', 8, 1),
 ('alexnet', 1, 1), ('alexnet', 2, 1), ('alexnet', 4, 1), ('alexnet', 8, 1),
 ('resnet110', 1, 1), ('resnet110', 2, 1), ('resnet110', 4, 1), ('resnet110', 8, 1),
 ('resnet44', 1, 1), ('resnet44', 2, 1), ('resnet44', 4, 1), ('resnet44', 8, 1),
 ('googlenet', 1, 1), ('googlenet', 2, 1), ('googlenet', 4, 1), ('googlenet', 8, 1),
 ('inception3', 1, 1), ('inception3', 2, 1), ('inception3', 4, 1), ('inception3', 8, 1)
 ]

# cifar10 5가지 (densenet100-k12, densenet40-k12, alexnet, resnet110, resnet44)
# imagenet 2가지 (googlenet, inception3)

CIFAR10_model = ("densenet40_k12", "densenet100_k12", "densenet100_k24","resnet20", "resnet32", "resnet44", "resnet56", "resnet110", "alexnet")
ImageNet_model = ("overfeat", "inception3", "inception4", "resnet50", "resnet101", "resnet152", "googlenet", "vgg11", "vgg16", "vgg19")

# unit: MB/s
# GCP PS -- csv3 ps + Sep20
model_bandwidth = {
    "cifar10_alexnet_sync_batch32": "148",
    "cifar10_alexnet_sync_batch48": "316",
    "cifar10_alexnet_sync_batch64": "484",
    "cifar10_resnet110_sync_batch32": "300",
    "cifar10_resnet110_sync_batch48": "403",
    "cifar10_resnet110_sync_batch64": "499",
    "cifar10_resnet44_sync_batch32": "263",
    "cifar10_resnet44_sync_batch48": "348",
    "cifar10_resnet44_sync_batch64": "434",
    "cifar10_resnet56_sync_batch32": "276",
    "cifar10_resnet56_sync_batch48": "369",
    "cifar10_resnet56_sync_batch64": "441",
    "cifar10_densenet100_k12_sync_batch32": "294",
    "cifar10_densenet100_k12_sync_batch48": "418",
    "cifar10_densenet100_k12_sync_batch64": "515",
    "cifar10_densenet100_k12_sync_batch128": "897",
    "cifar10_densenet40_k12_sync_batch32": "128",
    "cifar10_densenet40_k12_sync_batch48": "181",
    "cifar10_densenet40_k12_sync_batch64": "229",
    "imagenet_vgg16_sync_batch32": "2219",
    "imagenet_vgg16_sync_batch48": "3329",
    "imagenet_vgg16_sync_batch64": "4437",
    "imagenet_vgg16_sync_batch128": "6174",
    "imagenet_googlenet_sync_batch32": "807",
    "imagenet_googlenet_sync_batch48": "1107",
    "imagenet_googlenet_sync_batch64": "1494",
    "imagenet_inception3_sync_batch32": "1725",
    "imagenet_inception3_sync_batch48": "2576",
    "imagenet_inception3_sync_batch64": "3092",
    "imagenet_resnet50_sync_batch32": "2569",
    "imagenet_resnet50_sync_batch48": "3686",
    "imagenet_resnet50_sync_batch64": "4797",
    "imagenet_resnet50_sync_batch64": "5172",
    "cifar10_densenet100_k24_sync_batch32": "659",
    "cifar10_densenet100_k24_sync_batch48": "973",
    "cifar10_densenet100_k24_sync_batch64": "1239",
    "cifar10_resnet20_sync_batch32": "210",
    "cifar10_resnet20_sync_batch48": "282",
    "cifar10_resnet20_sync_batch64": "333",
    "cifar10_resnet32_sync_batch32": "235",
    "cifar10_resnet32_sync_batch48": "331",
    "cifar10_resnet32_sync_batch64": "406",
} if is_GCP else {
    "cifar10_densenet100_k12_sync_batch32": "294",
    "cifar10_densenet100_k12_sync_batch48": "418",
    "cifar10_densenet100_k12_sync_batch64": "515",
    "cifar10_densenet100_k12_sync_batch128": "897",
    "imagenet_resnet50_sync_batch32": "2569",
    "imagenet_resnet50_sync_batch48": "3686",
    "imagenet_resnet50_sync_batch64": "4797",
    "imagenet_resnet50_sync_batch64": "5172",
    "imagenet_inception3_sync_batch32": "1725",
    "imagenet_inception3_sync_batch48": "2576",
    "imagenet_inception3_sync_batch64": "3092",
    "imagenet_vgg16_sync_batch32": "2219",
    "imagenet_vgg16_sync_batch48": "3329",
    "imagenet_vgg16_sync_batch64": "4437",
    "imagenet_vgg16_sync_batch128": "6174",
}

model_skewness = {
    "alexnet": "2.6",
    "vgg16": "5.1",
    "googlenet": "4.2",
    "inception3": "4.2",
    "resnet50": "3.8",
    "resnet110": "2.3",
    "resnet44": "2.4",
    "resnet56": "2.3",
    "densenet100_k12": "1.9",
    "densenet40_k12": "1.9",
}

cpu_image="potato4332/tf2-cpu-docker:0.5.5x"
gpu_image="potato4332/tf2-gpu-docker:0.4.5x"

result_volume_claim = "tfjob-data-volume-claim"
nlp_data_volume_claim = "tfjob-nfs-dataset-storage-claim"

# for K8s
k8s_cpu_request="1"
k8s_cpu_limit="5"
k8s_gpu_limit="1"

# for Tethys
gpu_request="1.0"
gpu_limit="1.0"
gpu_mem_limit="16160000000"#30G #"5368709120" #5 G

clean_pod_policy = 'None'

model_batch_size = {
    "alexnet": 4096,
    "resnet110": 1024,
    "resnet44": 1024,
    "resnet56": 1024,
    "densenet40_k12": 1024,
    "googlenet": 256,
    "densenet100_k12": 128,
    "vgg16": 128,
    "resnet50": 128,
    "inception3": 64,
    "bert": 4,
    "gpt2": 4,
}

def get_batch_size(model):
    # per device batch size
    return model_batch_size.get(model, 1)

def get_dataset(model):
    if model in CIFAR10_model:
        return "cifar10"
    elif model in ImageNet_model:
        return "imagenet"
    else:
        return "unknown"

def create_job_config(id, model, worker_num, iter_num):
    dataset = get_dataset(model)
    batch_size = get_batch_size(model)
    job_name_no_id = f"{dataset}_{model}_sync_batch{batch_size * worker_num}"
    bandwidth = model_bandwidth.get(job_name_no_id, "0")

    job_name = f"id{id}-{dataset}-{model}-sync-batch{batch_size * worker_num}"  # worker_num includes chief worker (BERT, GPT2)
    config = {
        'model_name': model,
        'dataset_name': dataset,
        'batch_size': batch_size,
        'worker_num': worker_num,
        'network_bandwidth': bandwidth,
        'iter_num': iter_num,
    }
    return job_name, config

def save_yaml(data, filename):
    with open(filename, 'w') as file:
        file.write(data)

def generate_cnn_tfjob_yaml(job_name, job_config):
    job_name = job_name.replace('_', '-')
    #job_name = 'id0-cifar10-resnet56-sync-batch10'
    print(f'CNN job name: {job_name}')
    job_name_ub = job_name.replace('-', '_')

    model_name = job_config['model_name']       #'resnet56'
    dataset_name = job_config['dataset_name']   #'cifar10'
    worker_num = job_config['worker_num']
    batch_size = job_config['batch_size']
    network_bandwidth = job_config['network_bandwidth']
    num_batches = job_config['iter_num']
    skewness = model_skewness.get(model_name, 0)  # needs fix
    if skewness == 0:
        print(f'{model}\'s skewness is set zero')

    ps_num = worker_num if worker_num > 1 else 0

    # num_batches = 500
    # if model_name == 'vgg16':
    #     num_batches = 50

    if worker_num > 1:
        worker_command = f'python /tf_cnn_benchmarks/tf_cnn_benchmarks.py --variable_update=parameter_server --model={model_name} --data_name={dataset_name} --display_every=1 --batch_size={batch_size} --cross_replica_sync=true --num_batches={num_batches} --num_warmup_batches=0;'
        ps_command = f'python /tf_cnn_benchmarks/tf_cnn_benchmarks.py --variable_update=parameter_server --model={model_name} --data_name={dataset_name} --display_every=1 --batch_size={batch_size} --cross_replica_sync=true --num_batches={num_batches} --num_warmup_batches=0 > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_log.txt;'
    else:
        worker_command = f'python /tf_cnn_benchmarks/tf_cnn_benchmarks.py --variable_update=parameter_server --model={model_name} --data_name={dataset_name} --display_every=1 --batch_size={batch_size} --cross_replica_sync=true --num_batches={num_batches} --num_warmup_batches=0;'

    tfjob_template = f'''apiVersion: kubeflow.org/v1
kind: "TFJob"
metadata:
  name: {job_name}
spec:
  runPolicy:
    cleanPodPolicy: {clean_pod_policy}'''
    tfjob_template += f'''
  tfReplicaSpecs:
    WORKER:
      replicas: {worker_num}
      template:'''
    if scheduler_name == 'vol':
        tfjob_template += f'''
        metadata:
          annotations:
            "scheduling.volcano.sh/group-name": {job_name}'''
    elif scheduler_name == 'spot':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "spot"'''
    elif scheduler_name == 'spotk8s':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "k8s"'''
    elif scheduler_name == 'spotbinpack':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "binpack"'''
    elif scheduler_name == 'colo':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "colo"'''
    elif scheduler_name == 'tiresias':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "tiresias"
            "tensorspot/skewness_level": "{skewness}"'''

    tfjob_template += f'''
        spec:
          containers:
          - name: tensorflow
            command: ["/bin/sh", "-c"]
            args:
              - cd /tf_cnn_benchmarks/NVML;
                make;
                JOB=`python /tf_cnn_benchmarks/job_name.py`;
                CONTROLLER_HOST=`python -c "import os, json; tf_config = json.loads(os.environ.get('TF_CONFIG') or '{{}}'); cluster_config = tf_config.get('cluster', {{}}); controller_host = cluster_config.get('controller'); print(','.join(controller_host))"`;
                mkdir -p /result/{job_name_ub};
                top -d 0.1 -b | grep tf_cnn > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_cpu.txt &
                echo "{job_name_ub}" > /tf_cnn_benchmarks/model.txt;
                STARTTIME=`date "+%H:%M:%S.%N"`;
                echo "$STARTTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_start_time.txt;
                {worker_command}
                ENDTIME=`date "+%H:%M:%S.%N"`;
                echo "$ENDTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_end_time.txt
            ports:
            - containerPort: 2222
              name: tfjob-port
            image: {gpu_image}
            imagePullPolicy: IfNotPresent
            resources:
              requests:
                cpu: {k8s_cpu_request}
              limits:
                cpu: {k8s_cpu_limit}
                nvidia.com/gpu: {k8s_gpu_limit}
            volumeMounts:
            - mountPath: /result
              name: tfjob-data
            - mountPath: /dev/shm
              name: shmdir
          volumes:
          - name: tfjob-data
            persistentVolumeClaim:
              claimName: {result_volume_claim}
          - name: shmdir
            emptyDir:
              medium: Memory
              sizeLimit: "8G"
          nodeSelector:
            twonode: worker'''
    if scheduler_name == 'spot' or scheduler_name == 'colo' or scheduler_name == 'tiresias' or scheduler_name == 'spotk8s' or scheduler_name == 'spotbinpack':
        tfjob_template += '''
          schedulerName: tensorspot-scheduler'''
    elif scheduler_name == 'vol':
        tfjob_template += '''
          schedulerName: volcano'''
    if worker_num > 1:
        tfjob_template += f'''
    PS:
      replicas: {ps_num}
      template:'''

        if scheduler_name == 'vol':
            tfjob_template += f'''
        metadata:
          annotations:
            "scheduling.volcano.sh/group-name": {job_name}'''
        elif scheduler_name == 'spot':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "spot"'''
        elif scheduler_name == 'spotk8s':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "k8s"'''
        elif scheduler_name == 'spotbinpack':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "binpack"'''
        elif scheduler_name == 'colo':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "colo"'''
        elif scheduler_name == 'tiresias':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "tiresias"
            "tensorspot/skewness_level": "{skewness}"'''

        tfjob_template += f'''
        spec:
          containers:
          - name: tensorflow
            command: ["/bin/sh", "-c"]
            args:
              - JOB=`python /tf_cnn_benchmarks/job_name.py`;
                CONTROLLER_HOST=`python -c "import os, json; tf_config = json.loads(os.environ.get('TF_CONFIG') or '{{}}'); cluster_config = tf_config.get('cluster', {{}}); controller_host = cluster_config.get('controller'); print(','.join(controller_host))"`;
                mkdir -p /result/{job_name_ub};
                echo "{job_name_ub}" > /tf_cnn_benchmarks/model.txt;
                top -d 0.1 -b | grep tf_cnn > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_cpu.txt &
                {ps_command}
                ENDTIME=`date "+%H:%M:%S.%N"`;
                echo "$ENDTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_end_time.txt
            ports:
            - containerPort: 2222
              name: tfjob-port
            image: {cpu_image}
            imagePullPolicy: IfNotPresent
            resources:
              requests:
                cpu: {k8s_cpu_request}
              limits:
                cpu: {k8s_cpu_limit}
            volumeMounts:
            - mountPath: /result
              name: tfjob-data
            - mountPath: /dev/shm
              name: shmdir
          volumes:
          - name: tfjob-data
            persistentVolumeClaim:
              claimName: {result_volume_claim}
          - name: shmdir
            emptyDir:
              medium: Memory
              sizeLimit: "8G"
          nodeSelector:
            twonode: worker'''
        if scheduler_name == 'spot' or scheduler_name == 'colo' or scheduler_name == 'tiresias' or scheduler_name == 'spotk8s' or scheduler_name == 'spotbinpack':
            tfjob_template += '''
          schedulerName: tensorspot-scheduler'''
        elif scheduler_name == 'vol':
            tfjob_template += '''
          schedulerName: volcano'''

    filename = f'net_script/{job_name_ub}_{scheduler_name}.yaml'
    save_yaml(tfjob_template, filename)
    return

def create_shell_script(job_configs):
    job_names = job_configs.keys()
    job_names_ub = [job_name.replace('-', '_') for job_name in job_names]
    sys.stdout = open(f'{scheduler_name}.sh','w')

    if is_GCP:
        template_head = '''#!/bin/bash
STARTTIME=`date "+%H:%M:%S.%N"`
STARTLOGTIME=$(($(date +%s%N)/1000000000))
TFPATH="/home/jhlee21/tfjob"
# GCP
SAVEPATH="/home/jhlee21/share_dir/tfjob"
sudo rm -rf ${SAVEPATH}/*
echo "$STARTTIME" > ${SAVEPATH}/start_makespan.txt
# GCP
'''
        template_end = '''
ENDTIME=`date "+%H:%M:%S.%N"`
echo "$ENDTIME" > ${SAVEPATH}/end_makespan.txt
ENDLOGTIME=$(($(date +%s%N)/1000000000))
LOGTIME=$(($ENDLOGTIME - $STARTLOGTIME))
kubectl logs -n kube-system --since $(($LOGTIME+5))s kube-scheduler-xsailor-master > ${SAVEPATH}/scheduler_log.txt
kubectl logs -n kube-system kube-scheduler-xsailor-master  > ${SAVEPATH}/scheduler_full_log.txt
'''
        if scheduler_name != 'k8s' and scheduler_name != 'binpack':
            template_end += '''
kubectl logs -n kube-system tensorspot-scheduler > ${SAVEPATH}/scheduler_log.txt

# GCP
'''
        for node in nodes:
            template_head += f'''gcloud compute ssh --zone us-central1-a {node} --command "sudo sh /home/jhlee21/gpu.sh &" &
'''
            template_end += f'''gcloud compute ssh --zone us-central1-a {node} --command "sudo sh /home/jhlee21/gpu_off.sh"
'''
    else:
        template_head = '''#!/bin/bash
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

'''
        template_end = '''
ENDTIME=`date "+%H:%M:%S.%N"`
echo "$ENDTIME" > ${SAVEPATH}/end_makespan.txt
ENDLOGTIME=$(($(date +%s%N)/1000000000))
LOGTIME=$(($ENDLOGTIME - $STARTLOGTIME))
kubectl logs -n kube-system --since $(($LOGTIME+5))s kube-scheduler-xsailor-master > ${SAVEPATH}/scheduler_log.txt
kubectl logs -n kube-system kube-scheduler-xsailor-master  > ${SAVEPATH}/scheduler_full_log.txt
# On-prem
ssh xsailor2@163.152.20.132 "sudo sh /home/jhlee21/gpu_off.sh"
ssh xsailor3@163.152.20.155 "sudo sh /home/jhlee21/gpu_off.sh"
'''
    # begin to print yaml
    print(template_head)
    print(f"""
MODEL="""+'"'+job_names_ub[0]+'"'+f"""
mkdir -p ${{SAVEPATH}}/${{MODEL}}
#### Training the model
date "+%H:%M:%S.%N" > ${{SAVEPATH}}/${{MODEL}}_job_create.txt
kubectl create -f ${{TFPATH}}/net_script/${{MODEL}}_{scheduler_name}.yaml
sleep 0.1s
""")
    for i, job_name in enumerate(job_names):
        if i == 0:
            continue
        job_name_ub = job_name.replace('-', '_')
        worker_num = job_configs[job_name]['worker_num']

        # 아래 부분 k8s만 적용
        if scheduler_name == 'k8s' or scheduler_name == 'binpack':
            print(f"""WORKERNUM=`kubectl get pod -o wide | grep worker- | wc -l`
    while [ $WORKERNUM -gt """+str(total_gpu_num - worker_num)+f""" ]
    do
    COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{{print $1}}' | sed -n '1p'`
    if [ -n "${{COMPLETED}}" ]; then
        for completed_pod in ${{COMPLETED}}; do
        COMPLETED_JOB=`echo ${{completed_pod}} | awk -F '-' '{{
            jobname = $1
            for (i = 2; i <= NF - 2; i++) {{
            jobname = jobname "_" $i
            }}
            print jobname
            }}'`
        done
        echo $(date "+%H:%M:%S.%N") > ${{SAVEPATH}}/${{COMPLETED_JOB}}_job_finished.txt
        kubectl delete -f ${{TFPATH}}/net_script/${{COMPLETED_JOB}}_{scheduler_name}.yaml

        # 수정필요 -- yaml도 수정해야함 . Complete 되면 바로 terminate하도록 해야함
        # RUNNING=`kubectl get pod | awk '{{print $1}}' | sed -n '1p'`
        # while [ -n "${{RUNNING}}" ]
        # do
        # RUNNING=`kubectl get pod | awk '{{print $1}}' | sed -n '1p'`
        # for p in $(kubectl get pods | grep -e "Terminating" -e "Completed" | awk '{{print $1}}'); do kubectl delete pod $p --grace-period=0 --force;done
        # done
        # 수정필요

    fi
    sleep 0.1s;
    WORKERNUM=`kubectl get pod -o wide | grep worker- | wc -l`
    done
""")

        print(f"""
MODEL="""+'"'+job_name_ub+'"'+f"""
sudo rm -rf ${{SAVEPATH}}/${{MODEL}}
mkdir -p ${{SAVEPATH}}/${{MODEL}}
#### Training the model
date "+%H:%M:%S.%N" > ${{SAVEPATH}}/${{MODEL}}_job_create.txt
kubectl create -f ${{TFPATH}}/net_script/${{MODEL}}_{scheduler_name}.yaml
sleep 0.1s
""")

    # Wait until the last job ends
    print(f"""
RUNNING=`kubectl get pod -o wide | awk '{{print $1}}' | sed -n '1p'`
while [ -n "${{RUNNING}}" ]
do
  COMPLETED=`kubectl get pod -o wide | grep Completed | awk '{{print $1}}' | sed -n '1p'`
  if [ -n "${{COMPLETED}}" ]; then
    for completed_pod in ${{COMPLETED}}; do
      COMPLETED_JOB=`echo ${{completed_pod}} | awk -F '-' '{{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {{
          jobname = jobname "_" $i
        }}
        print jobname
      }}'`
    done
    echo $(date "+%H:%M:%S.%N") > ${{SAVEPATH}}/${{COMPLETED_JOB}}_job_finished.txt
    kubectl delete -f ${{TFPATH}}/net_script/${{COMPLETED_JOB}}_{scheduler_name}.yaml
  fi
  sleep 0.1s;
  RUNNING=`kubectl get pod -o wide | awk '{{print $1}}' | sed -n '1p'`
done
""")
    print(template_end)

if __name__ == '__main__':
    print(f'scheduler: {scheduler_name}')
    print('variable update strategy: parameter server')
    print(f'Total {len(train_trace)} jobs')
    # Create job configs
    job_configs = {}
    for i, (model, worker_num, iter_num) in enumerate(train_trace):
        job_name, config = create_job_config(i, model, worker_num, iter_num)
        job_configs[job_name] = config
    # Create yaml files
    for i, (job_name, job_config) in enumerate(job_configs.items()):
        generate_cnn_tfjob_yaml(job_name, job_config)
    # Create shell files
    create_shell_script(job_configs)
