# Changes
# - FCFS-based execution
# - job 배치된 노드 기록

import sys
import argparse
import os

# Xsailor local vs. GCP
is_GCP = False
nodes = []
if is_GCP:
    nodes = ['xsailor-worker-t6', 'xsailor-worker-t7', 'xsailor-worker-t8', 'xsailor-worker-t9']

# select from ['k8s', 'vol', 'colo', 'spot']
parser = argparse.ArgumentParser(prog='YamlShGenerator', description='generates sh and job manifest yaml')
parser.add_argument('-s', '--scheduler', required=True, choices=['k8s', 'gangk8s', 'gangbinpack', 'vol', 'colo', 'spot'], help='select from k8s, gangk8s, gangbinpack, vol, colo, spot')
args = parser.parse_args()
scheduler_name = args.scheduler

# volcano-scheduler pod name gets automatically assigned
volcano_pod_name = os.popen("kubectl get pod -A | grep volcano-scheduler | awk '{print $2}'").read().strip()

# [WARNING] GPU num should be checked
total_gpu_num = 4 * len(nodes) if nodes else 8
print(f'Training with total gpu num: {total_gpu_num}')

# [(model name, # of workers, # of iterations)]
# Nov08trace_ar.txt
# train_trace = [('alexnet', 2, 663), ('resnet56', 2, 442), ('resnet110', 2, 240), ('densenet100_k12', 2, 208),
#                ('resnet44', 4, 362), ('densenet40_k12', 4, 146), ('resnet50', 4, 172), ('vgg16', 3, 70),
#                ('inception3', 3, 207), ('googlenet', 3, 235)]

# Nov12trace_ar.txt
#train_trace = [('gpt2', 3, 522), ('resnet50', 2, 209), ('densenet40_k12', 2, 172), ('bert', 3, 403),
#               ('densenet100_k12', 3, 168), ('gpt2', 2, 588), ('inception3', 4, 181), ('bert', 4, 405),
#               ('gpt2', 2, 588), ('vgg16', 4, 64)]

# always pending1.txt
#train_trace = [('resnet50', 3, 209), ('resnet50', 3, 209), ('gpt2', 2, 522)]

# always pending2.txt
#train_trace = [('gpt2', 2, 522), ('resnet50', 3, 209), ('resnet50', 3, 209)]

train_trace = [('alexnet', 1, 10), ('alexnet', 2, 10), ('alexnet', 4, 10), ('alexnet', 8, 10), ('resnet110', 1, 10), ('resnet110', 2, 10), ('resnet110', 4, 10), ('resnet110', 8, 10), ('resnet44', 1, 10), ('resnet44', 2, 10), ('resnet44', 4, 10), ('resnet44', 8, 10), ('resnet56', 1, 10), ('resnet56', 2, 10), ('resnet56', 4, 10), ('resnet56', 8, 10), ('densenet40_k12', 1, 10), ('densenet40_k12', 2, 10), ('densenet40_k12', 4, 10), ('densenet40_k12', 8, 10), ('googlenet', 1, 10), ('googlenet', 2, 10), ('googlenet', 4, 10), ('googlenet', 8, 10), ('densenet100_k12', 1, 10), ('densenet100_k12', 2, 10), ('densenet100_k12', 4, 10), ('densenet100_k12', 8, 10), ('vgg16', 1, 10), ('vgg16', 2, 10), ('vgg16', 4, 10), ('vgg16', 8, 10), ('resnet50', 1, 10), ('resnet50', 2, 10), ('resnet50', 4, 10), ('resnet50', 8, 10), ('inception3', 1, 10), ('inception3', 2, 10), ('inception3', 4, 10), ('inception3', 8, 10), ('bert', 1, 10), ('bert', 2, 10), ('bert', 4, 10), ('bert', 8, 10), ('gpt2', 1, 10), ('gpt2', 2, 10), ('gpt2', 4, 10), ('gpt2', 8, 10)]

CIFAR10_model = ("densenet40_k12", "densenet100_k12", "densenet100_k24","resnet20", "resnet32", "resnet44", "resnet56", "resnet110", "alexnet")
ImageNet_model = ("overfeat", "inception3", "inception4", "resnet50", "resnet101", "resnet152", "googlenet", "vgg11", "vgg16", "vgg19")
SQuAD_model = ("bert", "gpt2",)

# unit: MB/s
# GCP AR -- ar_network_summary(Nov01)
model_bandwidth = {
    "cifar10_alexnet_sync_batch8192": "108",
    "cifar10_alexnet_sync_batch12288": "215",
    "cifar10_alexnet_sync_batch16384": "323",
    "cifar10_resnet110_sync_batch2048": "28",
    "cifar10_resnet110_sync_batch3072": "57",
    "cifar10_resnet110_sync_batch4096": "87",
    "cifar10_resnet44_sync_batch2048": "32",
    "cifar10_resnet44_sync_batch3072": "64",
    "cifar10_resnet44_sync_batch4096": "67",
    "cifar10_resnet56_sync_batch2048": "27",
    "cifar10_resnet56_sync_batch3072": "56",
    "cifar10_resnet56_sync_batch4096": "86",
    "cifar10_densenet100_k12_sync_batch256": "64",
    "cifar10_densenet100_k12_sync_batch384": "121",
    "cifar10_densenet100_k12_sync_batch512": "138",
    "cifar10_densenet40_k12_sync_batch2048": "6",
    "cifar10_densenet40_k12_sync_batch3072": "13",
    "cifar10_densenet40_k12_sync_batch4096": "21",
    "imagenet_vgg16_sync_batch256": "2116",
    "imagenet_vgg16_sync_batch384": "4231",
    "imagenet_vgg16_sync_batch512": "5769",
    "imagenet_googlenet_sync_batch512": "215",
    "imagenet_googlenet_sync_batch768": "430",
    "imagenet_googlenet_sync_batch1024": "647",
    "imagenet_inception3_sync_batch128": "670",
    "imagenet_inception3_sync_batch192": "1175",
    "imagenet_inception3_sync_batch256": "1543",
    "imagenet_resnet50_sync_batch256": "391",
    "imagenet_resnet50_sync_batch384": "784",
    "imagenet_resnet50_sync_batch512": "1178",
    "squad_bert_sync_batch8": "1315",
    "squad_bert_sync_batch12": "1468",
    "squad_bert_sync_batch16": "1953",
    "squad_gpt2_sync_batch8": "997",
    "squad_gpt2_sync_batch12": "1895",
    "squad_gpt2_sync_batch16": "2144",
} if is_GCP else {
    "cifar10_densenet100_k12_sync_batch32": "238",
    "cifar10_densenet100_k12_sync_batch48": "334",
    "cifar10_densenet100_k12_sync_batch64": "377",
    "cifar10_densenet100_k12_sync_batch128": "519",
    "imagenet_resnet50_sync_batch32": "2083",
    "imagenet_resnet50_sync_batch48": "3789",
    "imagenet_resnet50_sync_batch64": "4927",
    "imagenet_resnet50_sync_batch128": "6404",
    "imagenet_inception3_sync_batch32": "1557",
    "imagenet_inception3_sync_batch48": "2995",
    "imagenet_inception3_sync_batch64": "3454",
    "imagenet_vgg16_sync_batch32": "3315",
    "imagenet_vgg16_sync_batch48": "4438",
    "imagenet_vgg16_sync_batch64": "6655",
    "imagenet_vgg16_sync_batch128": "12402",
    "squad_bert_sync_batch8": "5596",
    "squad_bert_sync_batch12": "8490",
    "squad_bert_sync_batch16": "11844",
    "imdb_gpt2_sync_batch8": "995",
    "imdb_gpt2_sync_batch12": "1988",
    "imdb_gpt2_sync_batch16": "1995",
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

cpu_image="chiefmate/cv-cpu:0.0.1-network"
gpu_image="chiefmate/cv-gpu:0.0.2-network"
squad_nlp_gpu_image = "chiefmate/nlp-keras:0.0.1x"

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
    elif model in SQuAD_model:
        return "squad"
    else:
        return "unknown"

def create_job_config(id, model, worker_num, iter_num):
    dataset = get_dataset(model)
    batch_size = get_batch_size(model)
    job_name_no_id = f"{dataset}_{model}_sync_batch{batch_size * worker_num}"
    bandwidth = model_bandwidth.get(job_name_no_id, "0")
    if bandwidth == 0:
        print(f'[WARNING] job {id}_{job_name_no_id}\'s bandwidth is zero')

    job_name = f"a{id}-{dataset}-{model}-sync-batch{batch_size * worker_num}"  # worker_num includes chief worker (BERT, GPT2)
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

def generate_squad_nlp_tfjob_yaml(job_name, job_config):
    job_name = job_name.replace('_', '-')
    #job_name = 'id0-imdb-gpt2-sync-batch16'
    job_name_ub = job_name.replace('-', '_')
    print(f'NLP job name: {job_name}')
    model_name = job_config['model_name']
    dataset_name = job_config['dataset_name']
    worker_num = job_config['worker_num']
    worker_replica_num = worker_num - 1 if worker_num > 1 else worker_num       # subtract one if Chief exists
    network_bandwidth = job_config['network_bandwidth']

    tfjob_template = f'''apiVersion: kubeflow.org/v1
kind: "TFJob"
metadata:
  name: {job_name}
spec:
  runPolicy:
    cleanPodPolicy: {clean_pod_policy}
  tfReplicaSpecs:'''

    # CHIEF
    if worker_num > 1:
        tfjob_template += f'''
    CHIEF:
      replicas: 1
      template:'''
        # chief scheduler metadata
        if scheduler_name == 'vol':
            tfjob_template += f'''
        metadata:
          annotations:
            "scheduling.volcano.sh/group-name": {job_name}'''
        elif scheduler_name == 'spot':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "spot"'''
        elif scheduler_name == 'gangk8s':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "k8s"'''
        elif scheduler_name == 'gangbinpack':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
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
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "colo"'''
        tfjob_template += f'''
        spec:
          containers:
          - name: tensorflow
            command: ["/bin/sh", "-c"]
            env:
            - name: ROOT_DATA_DIR
              value: "/data"
            args:
              - JOB=`python /workspace/job_name.py`;
                mkdir -p /result/{job_name_ub};
                echo "{job_name_ub}" > /workspace/model.txt;
                STARTTIME=`date "+%H:%M:%S.%N"`; echo "$STARTTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_start_time.txt;
                top -d 0.1 -b | grep python > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_cpu.txt
                & python /workspace/nlp_jobs/{model_name}_dist_squad.py
                > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_log.txt;
                ENDTIME=`date "+%H:%M:%S.%N"`; echo "$ENDTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_end_time.txt
            ports:
              - containerPort: 2222
                name: tfjob-port
            image: {squad_nlp_gpu_image}
            imagePullPolicy: IfNotPresent
            resources:
              requests:
                cpu: {k8s_cpu_request}
                nvidia.com/gpu: {k8s_gpu_limit}
              limits:
                cpu: {k8s_cpu_limit}
                nvidia.com/gpu: {k8s_gpu_limit}
            volumeMounts:
            - mountPath: /result
              name: tfjob-data
            - mountPath: /data
              name: tfjob-dataset
            - mountPath: /dev/shm
              name: shmdir
          volumes:
          - name: tfjob-data
            persistentVolumeClaim:
              claimName: {result_volume_claim}
          - name: tfjob-dataset
            persistentVolumeClaim:
              claimName: {nlp_data_volume_claim}
          - name: shmdir
            emptyDir:
              medium: Memory
              sizeLimit: "8G"
          nodeSelector:
            twonode: worker'''
    if scheduler_name == 'spot' or scheduler_name == 'colo' or scheduler_name == 'tiresias' or scheduler_name == 'gangk8s' or scheduler_name == 'gangbinpack':
        tfjob_template += '''
          schedulerName: tensorspot-scheduler'''
    elif scheduler_name == 'vol':
        tfjob_template += '''
          schedulerName: volcano'''
    # WORKER
    tfjob_template += f'''
    WORKER:
      replicas: {worker_replica_num}
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
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "spot"'''
    elif scheduler_name == 'gangk8s':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "k8s"'''
    elif scheduler_name == 'gangbinpack':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
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
            "tensorspot/num_chief": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "colo"'''
    tfjob_template += f'''
        spec:
          containers:
          - name: tensorflow
            command: ["/bin/sh", "-c"]
            env:
            - name: ROOT_DATA_DIR
              value: "/data"
            args:
              - JOB=`python /workspace/job_name.py`;
                mkdir -p /result/{job_name_ub};
                echo "{job_name_ub}" > /workspace/model.txt;
                STARTTIME=`date "+%H:%M:%S.%N"`; echo "$STARTTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_start_time.txt;
                top -d 0.1 -b | grep python > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_cpu.txt
                & python /workspace/nlp_jobs/{model_name}_{'dist' if worker_num > 1 else 'single'}_squad.py
                > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_log.txt;
                ENDTIME=`date "+%H:%M:%S.%N"`; echo "$ENDTIME" > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_end_time.txt
            ports:
              - containerPort: 2222
                name: tfjob-port
            image: {squad_nlp_gpu_image}
            imagePullPolicy: IfNotPresent
            resources:
              requests:
                cpu: {k8s_cpu_request}
                nvidia.com/gpu: {k8s_gpu_limit}
              limits:
                cpu: {k8s_cpu_limit}
                nvidia.com/gpu: {k8s_gpu_limit}
            volumeMounts:
            - mountPath: /result
              name: tfjob-data
            - mountPath: /data
              name: tfjob-dataset
            - mountPath: /dev/shm
              name: shmdir
          volumes:
          - name: tfjob-data
            persistentVolumeClaim:
              claimName: {result_volume_claim}
          - name: tfjob-dataset
            persistentVolumeClaim:
              claimName: {nlp_data_volume_claim}
          - name: shmdir
            emptyDir:
              medium: Memory
              sizeLimit: "8G"
          nodeSelector:
              twonode: worker'''
    if scheduler_name == 'spot' or scheduler_name == 'colo' or scheduler_name == 'tiresias' or scheduler_name == 'gangk8s' or scheduler_name == 'gangbinpack':
        tfjob_template += '''
          schedulerName: tensorspot-scheduler'''
    elif scheduler_name == 'vol':
        tfjob_template += '''
          schedulerName: volcano'''
    filename = f'net_script/{job_name_ub}_{scheduler_name}.yaml'
    save_yaml(tfjob_template, filename)
    return

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
    skewness = model_skewness[model_name]
    num_batches = job_config['iter_num']

    # num_batches = 500
    # if model_name == 'vgg16':
    #     num_batches = 50

    if worker_num > 1:
        command = f'python /tf_cnn_benchmarks/tf_cnn_benchmarks.py --variable_update=distributed_all_reduce --model={model_name} --data_name={dataset_name} --display_every=1 --batch_size={batch_size} --cross_replica_sync=true --num_batches={num_batches} --num_warmup_batches=0  --controller_host=${{CONTROLLER_HOST}} --all_reduce_spec=nccl/xring > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_log.txt;'
    else:
        command = f'python /tf_cnn_benchmarks/tf_cnn_benchmarks.py --variable_update=replicated --model={model_name} --data_name={dataset_name} --display_every=1 --batch_size={batch_size} --num_batches={num_batches} --num_warmup_batches=0 > /result/{job_name_ub}/{job_name_ub}_${{JOB}}_log.txt;'

    tfjob_template = f'''apiVersion: kubeflow.org/v1
kind: "TFJob"
metadata:
  name: {job_name}
spec:
  runPolicy:
    cleanPodPolicy: {clean_pod_policy}'''

    # if scheduler_name == 'vol':
    #     tfjob_template += f'''
    # schedulingPolicy:
    #   queue: tfjobqueue
    #   minResources:
    #     nvidia.com/gpu: {worker_num}'''

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
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "spot"'''
    elif scheduler_name == 'gangk8s':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "k8s"'''
    elif scheduler_name == 'gangbinpack':
        tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
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
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "colo"'''
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
                {command}
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
                nvidia.com/gpu: {k8s_gpu_limit}
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
    if scheduler_name == 'spot' or scheduler_name == 'colo' or scheduler_name == 'tiresias' or scheduler_name == 'gangk8s' or scheduler_name == 'gangbinpack':
        tfjob_template += '''
          schedulerName: tensorspot-scheduler'''
    elif scheduler_name == 'vol':
        tfjob_template += '''
          schedulerName: volcano'''

    if worker_num > 1:
        tfjob_template += f'''
    CONTROLLER:
      replicas: 1
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
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "spot"'''
        elif scheduler_name == 'gangk8s':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "k8s"'''
        elif scheduler_name == 'gangbinpack':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "binpack"'''
        elif scheduler_name == 'colo':
            tfjob_template += f'''
        metadata:
          annotations:
            "tensorspot/num_controller": "{0 if worker_num < 2 else 1}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/placement_policy": "colo"'''
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
                {command}
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
        if scheduler_name == 'spot' or scheduler_name == 'colo' or scheduler_name == 'tiresias' or scheduler_name == 'gangk8s' or scheduler_name == 'gangbinpack':
            tfjob_template += '''
          schedulerName: tensorspot-scheduler'''
        elif scheduler_name == 'vol':
            tfjob_template += '''
          schedulerName: volcano'''

    # tfjob_yaml = yaml.safe_load(tfjob_template)
    filename = f'net_script/{job_name_ub}_{scheduler_name}.yaml'
    save_yaml(tfjob_template, filename)
    return

def create_shell_script(job_configs):
    job_names = job_configs.keys()
    job_names_ub = [job_name.replace('-', '_') for job_name in job_names]
    sys.stdout = open(f'{scheduler_name}.sh','w')

    if is_GCP:
        template_head = '''
#!/bin/bash
STARTTIME=`date "+%H:%M:%S.%N"`
STARTLOGTIME=$(($(date +%s%N)/1000000000))
TFPATH="/home/jhlee21/tfjob"
# GCP
SAVEPATH="/home/jhlee21/share_dir/tfjob"
sudo rm -rf ${SAVEPATH}/*
echo "$STARTTIME" > ${SAVEPATH}/start_makespan.txt
# GCP'''
        template_end = '''
ENDTIME=`date "+%H:%M:%S.%N"`
echo "$ENDTIME" > ${SAVEPATH}/end_makespan.txt
ENDLOGTIME=$(($(date +%s%N)/1000000000))
LOGTIME=$(($ENDLOGTIME - $STARTLOGTIME))
kubectl logs -n kube-system kube-scheduler-xsailor-master  > ${SAVEPATH}/scheduler_full_log.txt'''
        if scheduler_name == 'vol':
            template_end += f'''
kubectl logs -n volcano-system {volcano_pod_name} > ${{SAVEPATH}}/scheduler_log.txt'''
        elif scheduler_name == 'k8s' or scheduler_name == 'binpack':
            template_end += '''
kubectl logs -n kube-system --since $(($LOGTIME+5))s kube-scheduler-xsailor-master > ${SAVEPATH}/scheduler_log.txt'''
        else:
            template_end += '''
kubectl logs -n kube-system tensorspot-scheduler > ${SAVEPATH}/scheduler_log.txt'''
        for node in nodes:
            template_head += f'''
gcloud compute ssh --zone us-central1-a {node} --command "sudo sh /home/jhlee21/gpu.sh &" &'''
            template_end += f'''
gcloud compute ssh --zone us-central1-a {node} --command "sudo sh /home/jhlee21/gpu_off.sh"'''
    else:
        template_head = '''
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
ssh xsailor3@163.152.20.155 "sudo sh /home/jhlee21/gpu_off.sh"'''
    # begin to print yaml
    print(template_head)
    print(f"""
MODEL="""+'"'+job_names_ub[0]+'"'+f"""
mkdir -p ${{SAVEPATH}}/${{MODEL}}
#### Training the model
date "+%H:%M:%S.%N" > ${{SAVEPATH}}/${{MODEL}}_job_create.txt
kubectl create -f ${{TFPATH}}/net_script/${{MODEL}}_{scheduler_name}.yaml
sleep 0.1s""")
    for i, job_name in enumerate(job_names):
        if i == 0:
            continue
        job_name_ub = job_name.replace('-', '_')
        worker_num = job_configs[job_name]['worker_num']

        # job들이 순서대로 실행하는 것을 보장하기 위해 가용 GPU 개수 생길 때까지 기다렸다 실행
        print(f"""
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
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
    for completed_pod in ${{COMPLETED}}; do
    COMPLETED_JOB_POD=`echo ${{completed_pod}} | awk -F '-' '{{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {{
        jobname = jobname "-" $i
        }}
        print jobname
    }}'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${{COMPLETED_JOB_POD}} | awk '{{print $1 "\\t" $7}}' > ${{SAVEPATH}}/${{COMPLETED_JOB}}_node_info.txt

    echo $(date "+%H:%M:%S.%N") > ${{SAVEPATH}}/${{COMPLETED_JOB}}_job_finished.txt
    kubectl delete -f ${{TFPATH}}/net_script/${{COMPLETED_JOB}}_{scheduler_name}.yaml
fi
sleep 0.1s;
WORKERNUM=`kubectl get pod -o wide | grep -e "worker-" -e "chief-" | wc -l`
done""")

        print("""
MODEL="""+'"'+job_name_ub+'"'+f"""
sudo rm -rf ${{SAVEPATH}}/${{MODEL}}
mkdir -p ${{SAVEPATH}}/${{MODEL}}
#### Training the model
date "+%H:%M:%S.%N" > ${{SAVEPATH}}/${{MODEL}}_job_create.txt
kubectl create -f ${{TFPATH}}/net_script/${{MODEL}}_{scheduler_name}.yaml
sleep 0.1s""")

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
    for completed_pod in ${{COMPLETED}}; do
      COMPLETED_JOB_POD=`echo ${{completed_pod}} | awk -F '-' '{{
        jobname = $1
        for (i = 2; i <= NF - 2; i++) {{
          jobname = jobname "-" $i
        }}
        print jobname
      }}'`
    done
    # Save node information for all pods in the job
    kubectl get pod -o wide | grep ${{COMPLETED_JOB_POD}} | awk '{{print $1 "\\t" $7}}' > ${{SAVEPATH}}/${{COMPLETED_JOB}}_node_info.txt
    echo $(date "+%H:%M:%S.%N") > ${{SAVEPATH}}/${{COMPLETED_JOB}}_job_finished.txt
    kubectl delete -f ${{TFPATH}}/net_script/${{COMPLETED_JOB}}_{scheduler_name}.yaml
  fi
  sleep 0.1s;
  RUNNING=`kubectl get pod -o wide | awk '{{print $1}}' | sed -n '1p'`
done""")
    print(template_end)

if __name__ == '__main__':
    print(f'scheduler: {scheduler_name}')
    print('variable update strategy: distributed_all_reduce')
    print(f'Total {len(train_trace)} jobs')
    # Create job configs
    job_configs = {}
    for i, (model, worker_num, iter_num) in enumerate(train_trace):
        job_name, config = create_job_config(i, model, worker_num, iter_num)
        job_configs[job_name] = config
    # Create yaml files
    for i, (job_name, job_config) in enumerate(job_configs.items()):
        if job_config['model_name'] in SQuAD_model:
            generate_squad_nlp_tfjob_yaml(job_name, job_config)
        else:
            generate_cnn_tfjob_yaml(job_name, job_config)
    # Create shell files
    create_shell_script(job_configs)
