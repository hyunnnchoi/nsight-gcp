# Changes
# - CPU request, limit can be adjusted
# - yaml.safe_load() deleted due to linebreaks

import sys
import argparse
import csv
import math

# Xsailor local vs. GCP
is_GCP = False
nodes = []
if is_GCP:
    nodes = ['xsailor-worker-t6', 'xsailor-worker-t7', 'xsailor-worker-t8', 'xsailor-worker-t9']

# select from ['k8s', 'vol', 'colo', 'spot', 'tiresias', 'binpack']
parser = argparse.ArgumentParser(prog='YamlShGenerator', description='generates sh and job manifest yaml')
parser.add_argument('-s', '--scheduler', required=True, help='select from k8s, vol, colo, spot, tiresias, binpack')
args = parser.parse_args()
scheduler_name = args.scheduler

# Placement policy mapping
placement_policy_map = {
    'k8s': 'k8s',
    'colo': 'colo', 
    'spot': 'spot',
    'tiresias': 'tiresias',
    'binpack': 'binpack'
}

def get_annotations(ps_num, worker_num, network_bandwidth, skewness=None):
    """공통 어노테이션 생성 함수"""
    if scheduler_name == 'vol':
        return ''  # Volcano는 group-name만 필요
    
    if scheduler_name in placement_policy_map:
        annotations = f'''
        metadata:
          annotations:
            "tensorspot/num_ps": "{ps_num}"
            "tensorspot/num_worker": "{worker_num}"
            "tensorspot/net_request": "{network_bandwidth}"
            "tensorspot/gpu_limit": "{gpu_limit}"
            "tensorspot/gpu_request": "{gpu_request}"
            "tensorspot/gpu_mem": "{gpu_mem_limit}"
            "tensorspot/placement_policy": "{placement_policy_map[scheduler_name]}"'''
        
        # tiresias는 skewness_level 추가
        if scheduler_name == 'tiresias' and skewness:
            annotations += f'''
            "tensorspot/skewness_level": "{skewness}"'''
        
        return annotations
    
    return ''

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

# Load train_trace from CSV file
def load_train_trace_from_csv(csv_file_path):
    train_trace = []
    with open(csv_file_path, 'r') as file:
        csv_reader = csv.reader(file)
        header = next(csv_reader)  # Skip header row
        for row in csv_reader:
            model = row[1]  # model column
            gpu_workers = int(row[7])  # gpu_workers column
            num_iteration = int(row[4])  # num_iteration column
            train_trace.append((model, gpu_workers, num_iteration))
    return train_trace

# Load train_trace from CSV
train_trace = load_train_trace_from_csv('motivation_v8_trace_ps_1_5.csv')

# cifar10 5가지 (densenet100-k12, densenet40-k12, alexnet, resnet110, resnet44)
# imagenet 2가지 (googlenet, inception3)

CIFAR10_model = ("densenet40_k12", "densenet100_k12", "densenet100_k24","resnet20", "resnet32", "resnet44", "resnet56", "resnet110", "alexnet")
ImageNet_model = ("overfeat", "inception3", "inception4", "resnet50", "resnet101", "resnet152", "googlenet", "vgg11", "vgg16", "vgg19")

# unit: MB/s
# Updated from ps_v100_8gpu_network_summary.csv - Sum of Max TX+RX (MB/s) floored to int
model_bandwidth = {
    "cifar10_alexnet_sync_batch8192": "241",      # 241.1033449 -> 241
    "cifar10_alexnet_sync_batch16384": "480",     # 480.0371628 -> 480
    "cifar10_alexnet_sync_batch32768": "965",     # 965.0947227 -> 965
    "cifar10_densenet100_k12_sync_batch256": "127",   # 127.656065 -> 127
    "cifar10_densenet100_k12_sync_batch512": "260",   # 260.0924282 -> 260
    "cifar10_densenet100_k12_sync_batch1024": "502",  # 502.4424076 -> 502
    "cifar10_densenet40_k12_sync_batch2048": "17",    # 17.59345818 -> 17
    "cifar10_densenet40_k12_sync_batch4096": "35",    # 35.29934597 -> 35
    "cifar10_densenet40_k12_sync_batch8192": "70",    # 70.84373093 -> 70
    "cifar10_resnet110_sync_batch2048": "81",         # 81.91839695 -> 81
    "cifar10_resnet110_sync_batch4096": "164",        # 164.0720015 -> 164
    "cifar10_resnet110_sync_batch8192": "327",        # 327.1458616 -> 327
    "cifar10_resnet44_sync_batch2048": "72",          # 72.66229534 -> 72
    "cifar10_resnet44_sync_batch4096": "145",         # 145.8101931 -> 145
    "cifar10_resnet44_sync_batch8192": "291",         # 291.4035492 -> 291
    "imagenet_googlenet_sync_batch512": "483",       # 483.8511963 -> 483
    "imagenet_googlenet_sync_batch1024": "967",      # 967.5105858 -> 967
    "imagenet_googlenet_sync_batch2048": "1912",     # 1912.98443 -> 1912
    "imagenet_inception3_sync_batch128": "1298",     # 1298.285733 -> 1298
    "imagenet_inception3_sync_batch256": "2733",     # 2733.556463 -> 2733
    "imagenet_inception3_sync_batch512": "4504",     # 4504.685592 -> 4504
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
    else:
        tfjob_template += get_annotations(ps_num, worker_num, network_bandwidth, skewness)

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
    if scheduler_name in placement_policy_map:
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
        else:
            tfjob_template += get_annotations(ps_num, worker_num, network_bandwidth, skewness)

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
    if scheduler_name in placement_policy_map:
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
        template_head = f'''#!/bin/bash
STARTTIME=`date "+%H:%M:%S.%N"`
STARTEPOCH=`date +%s`  # 스크립트 시작 시간 (epoch 초)
STARTLOGTIME=$(($(date +%s%N)/1000000000))
TFPATH="/home/jhlee21/tfjob"
SAVEPATH="/home/jhlee21/share_dir/tfjob"

PEM_KEY="/home/ubuntu/tethys-v/tethys.pem"

sudo rm -rf ${{SAVEPATH}}/*
echo "$STARTTIME" > ${{SAVEPATH}}/start_makespan.txt

# GCP - 동적으로 노드 IP 가져와서 GPU 스크립트 실행
NODE_IPS=$(kubectl get nodes -o wide --no-headers | awk '{{print $6}}')
for node_ip in $NODE_IPS; do
    ssh -i ${{PEM_KEY}} -o StrictHostKeyChecking=no ubuntu@$node_ip "sudo sh /home/jhlee21/gpu.sh &" &
done

# 사용 가능한 총 GPU 수 체크하는 함수
total_gpu_num=$(kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\\.com/gpu" | grep -v NAME | awk '{{if ($2 ~ /^[0-9]+$/) sum += $2}} END {{print sum}}')
configured_gpu_num={total_gpu_num}
if [ "$total_gpu_num" -ne "$configured_gpu_num" ]; then
    echo "ERROR: GPU count mismatch!"
    echo "  Configured in environment: $configured_gpu_num"
    echo "  Detected from k8s cluster: $total_gpu_num"
    echo "Please check your environment configuration or cluster setup."
    exit 1
else
    echo "GPU count verification passed: $total_gpu_num"
fi

# 사용 가능한 총 GPU 수 체크하는 함수
get_available_gpus() {{
    # 워커와 치프 파드 수 계산 (각각 1개 GPU 사용)
    USED_GPUS=$(kubectl get pods | grep -E "(-worker-|-chief-)" | wc -l)
    # 사용 가능한 GPU 수 계산
    AVAILABLE_GPUS=$((total_gpu_num - USED_GPUS))
    
    echo $AVAILABLE_GPUS
}}

# 노드에 작업이 스케줄링될 때까지 대기하는 함수
wait_for_pod_scheduling() {{
    JOB_NAME=$1
    WORKER_COUNT=$2
    JOB_NAME_DASH=$(echo $JOB_NAME | tr '_' '-')

    echo "Waiting for job $JOB_NAME to be scheduled to nodes..."

    # 모든 워커/치프 포드가 노드에 할당될 때까지 대기
    SCHEDULED_PODS=0
    TIMEOUT=259200  # 72시간 타임아웃
    START_TIME=$(date +%s)

    while [ $SCHEDULED_PODS -lt $WORKER_COUNT ]
    do
        # 현재 이 작업의 Running 상태이거나 ContainerCreating 상태인 포드 수 계산
        SCHEDULED_PODS=$(kubectl get pods | grep $JOB_NAME_DASH | grep -E "(Running|ContainerCreating|Completed)" | wc -l)

        # 현재 시간 체크
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        # 타임아웃 체크
        if [ $ELAPSED_TIME -gt $TIMEOUT ]; then
            echo "WARNING: Timeout waiting for pods to be scheduled. Continuing anyway."
            kubectl get pods | grep $JOB_NAME_DASH
            break
        fi

        if [ $SCHEDULED_PODS -lt $WORKER_COUNT ]; then
            sleep 1
            echo "Waiting for $JOB_NAME pods to be scheduled ($SCHEDULED_PODS/$WORKER_COUNT scheduled)"
        else
            echo "All pods for $JOB_NAME have been scheduled to nodes"
            kubectl get pods -o wide | grep $JOB_NAME_DASH
            echo "Node allocation for $JOB_NAME:" > ${{SAVEPATH}}/${{JOB_NAME}}_node_allocation.txt
            kubectl get pods -o wide | grep $JOB_NAME_DASH | awk '{{print $1 "\\t" $7}}' >> ${{SAVEPATH}}/${{JOB_NAME}}_node_allocation.txt

            # 각 포드의 생성 시간 기록
            for pod in $(kubectl get pods | grep $JOB_NAME_DASH | awk '{{print $1}}'); do
                echo "$(date "+%H:%M:%S.%N")" > ${{SAVEPATH}}/${{pod}}_create.txt
            done
            
            break
        fi
    done
}}

# 완료된 작업 정리 함수
cleanup_completed_jobs() {{
    SCHEDULER="$1"
    
    COMPLETED_CONTROLLERS=$(kubectl get pod -o wide | grep -e "controller-" -e "chief-" | grep Completed | awk '{{print $1}}')
    if [ -n "${{COMPLETED_CONTROLLERS}}" ]; then
        for completed_pod in ${{COMPLETED_CONTROLLERS}}; do
            # 작업 이름 추출
            COMPLETED_JOB=$(echo ${{completed_pod}} | awk -F '-' '{{
                jobname = $1
                for (i = 2; i <= NF - 2; i++) {{
                    jobname = jobname "_" $i
                }}
                print jobname
            }}')

            # 작업 포드 이름 추출
            COMPLETED_JOB_POD=$(echo ${{completed_pod}} | awk -F '-' '{{
                jobname = $1
                for (i = 2; i <= NF - 2; i++) {{
                    jobname = jobname "-" $i
                }}
                print jobname
            }}')

            echo "Job ${{COMPLETED_JOB}} completed, freeing resources"

            # 노드 정보 저장
            kubectl get pod -o wide | grep ${{COMPLETED_JOB_POD}} | awk '{{print $1 "\\t" $7}}' > ${{SAVEPATH}}/${{COMPLETED_JOB}}_node_info.txt
            # 작업 완료 시간 기록
            echo "$(date "+%H:%M:%S.%N")" > ${{SAVEPATH}}/${{COMPLETED_JOB}}_job_completed.txt

            # 작업 삭제
            kubectl delete -f ${{TFPATH}}/net_script/${{COMPLETED_JOB}}_${{SCHEDULER}}.yaml
        done
        return 0
    fi
    return 1
}}

# 자원과 arrival_time을 고려하여 대기하는 함수 (스케줄러에 따라 다른 로직 적용)
wait_for_resources_or_arrival() {{
    ARRIVAL_TIME=$1
    JOB_NAME=$2
    WORKER_NUM=$3
    SCHEDULER="$4"

    echo "Checking resources for job ${{JOB_NAME}} (arrival time: ${{ARRIVAL_TIME}}s, workers: $WORKER_NUM)"
    echo $ARRIVAL_TIME > ${{SAVEPATH}}/${{JOB_NAME}}_arrival_timestamp.txt

    while true; do
        # arrival time 체크
        CURRENT_EPOCH=$(date +%s)
        TIME_PASSED=$((CURRENT_EPOCH - STARTEPOCH))

        # arrival time이 되지 않았으면 계속 대기
        if [ $TIME_PASSED -lt $ARRIVAL_TIME ]; then
            TIME_REMAINING=$((ARRIVAL_TIME - TIME_PASSED))
            echo "Waiting for arrival time for job ${{JOB_NAME}} (Remaining: ${{TIME_REMAINING}}s)"
            sleep 1
            continue
        fi

        # k8s 스케줄러에만 Gang 스케줄링 적용
        if [ "$SCHEDULER" = "k8s" ]; then
            # Gang 스케줄링 로직: 사용 가능한 GPU 수 확인
            AVAILABLE_GPUS=$(get_available_gpus)
            echo "Current available GPUs: $AVAILABLE_GPUS (needed: $WORKER_NUM)"

            # 완료된 작업 확인 및 정리
            cleanup_completed_jobs $SCHEDULER

            # 자원이 해제되었으므로 다시 확인
            AVAILABLE_GPUS=$(get_available_gpus)
            echo "Available GPUs after cleanup: $AVAILABLE_GPUS (needed: $WORKER_NUM)"

            # Gang 스케줄링: 필요한 모든 GPU가 사용 가능할 때만 작업 제출
            if [ $AVAILABLE_GPUS -ge $WORKER_NUM ]; then
                echo "Sufficient GPUs available ($AVAILABLE_GPUS >= $WORKER_NUM). Starting job ${{JOB_NAME}} now."
                return 0
            else
                echo "Waiting for sufficient GPU resources for job ${{JOB_NAME}} ($AVAILABLE_GPUS/$WORKER_NUM available)"
                sleep 5
                continue
            fi
        else
            # 다른 스케줄러는 기존 로직 사용 (대기 중인 포드 확인)
            PENDING_PODS=$(kubectl get pods | grep -e "Pending" | wc -l)

            # 대기 중인 포드가 없으면 (이전 작업들이 모두 자원 할당 받은 상태) 즉시 작업 시작
            if [ $PENDING_PODS -eq 0 ]; then
                echo "Arrival time reached and no pending pods. Starting job ${{JOB_NAME}} now."
                CURRENT_EPOCH=$(date +%s)
                TIME_PASSED=$((CURRENT_EPOCH - STARTEPOCH))
                echo $TIME_PASSED > ${{SAVEPATH}}/${{JOB_NAME}}_queuehead_timestamp.txt
                return 0
            else
                # 대기 중인 포드가 있으면 완료된 작업 확인 및 정리
                if cleanup_completed_jobs $SCHEDULER; then
                    # 완료된 작업이 정리되었으므로 대기 중인 포드 다시 확인
                    PENDING_PODS=$(kubectl get pods | grep -e "Pending" | wc -l)
                    if [ $PENDING_PODS -eq 0 ]; then
                        echo "All previous jobs allocated. Starting job ${{JOB_NAME}} now."
                        return 0
                    fi
                fi

                echo "Arrival time reached but waiting for previous jobs to be allocated resources first."
                sleep 0.5
            fi
        fi
    done
}}

echo "총 GPU 수: {total_gpu_num}"

'''
    else:
        template_head = f'''#!/bin/bash
STARTTIME=`date "+%H:%M:%S.%N"`
STARTEPOCH=`date +%s`  # 스크립트 시작 시간 (epoch 초)
STARTLOGTIME=$(($(date +%s%N)/1000000000))
TFPATH="/home/jhlee21/tfjob"
SAVEPATH="/mnt/sdb/share_dir/tfjob"

PEM_KEY="/home/ubuntu/tethys-v/tethys.pem"

sudo rm -rf ${{SAVEPATH}}/*
echo "$STARTTIME" > ${{SAVEPATH}}/start_makespan.txt

# On-prem - 동적으로 노드 IP 가져와서 GPU 스크립트 실행
NODE_IPS=$(kubectl get nodes -o wide --no-headers | awk '{{print $6}}')
for node_ip in $NODE_IPS; do
    ssh -i ${{PEM_KEY}} -o StrictHostKeyChecking=no ubuntu@$node_ip "sudo sh /home/jhlee21/gpu.sh &" &
done

# 사용 가능한 총 GPU 수 체크하는 함수
total_gpu_num=$(kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\\.com/gpu" | grep -v NAME | awk '{{if ($2 ~ /^[0-9]+$/) sum += $2}} END {{print sum}}')
configured_gpu_num={total_gpu_num}
if [ "$total_gpu_num" -ne "$configured_gpu_num" ]; then
    echo "ERROR: GPU count mismatch!"
    echo "  Configured in environment: $configured_gpu_num"
    echo "  Detected from k8s cluster: $total_gpu_num"
    echo "Please check your environment configuration or cluster setup."
    exit 1
else
    echo "GPU count verification passed: $total_gpu_num"
fi

# 사용 가능한 총 GPU 수 체크하는 함수
get_available_gpus() {{
    # 워커와 치프 파드 수 계산 (각각 1개 GPU 사용)
    USED_GPUS=$(kubectl get pods | grep -E "(-worker-|-chief-)" | wc -l)
    # 사용 가능한 GPU 수 계산
    AVAILABLE_GPUS=$((total_gpu_num - USED_GPUS))
    
    echo $AVAILABLE_GPUS
}}

# 노드에 작업이 스케줄링될 때까지 대기하는 함수
wait_for_pod_scheduling() {{
    JOB_NAME=$1
    WORKER_COUNT=$2
    JOB_NAME_DASH=$(echo $JOB_NAME | tr '_' '-')

    echo "Waiting for job $JOB_NAME to be scheduled to nodes..."

    # 모든 워커/치프 포드가 노드에 할당될 때까지 대기
    SCHEDULED_PODS=0
    TIMEOUT=259200  # 72시간 타임아웃
    START_TIME=$(date +%s)

    while [ $SCHEDULED_PODS -lt $WORKER_COUNT ]
    do
        # 현재 이 작업의 Running 상태이거나 ContainerCreating 상태인 포드 수 계산
        SCHEDULED_PODS=$(kubectl get pods | grep $JOB_NAME_DASH | grep -E "(Running|ContainerCreating|Completed)" | wc -l)

        # 현재 시간 체크
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        # 타임아웃 체크
        if [ $ELAPSED_TIME -gt $TIMEOUT ]; then
            echo "WARNING: Timeout waiting for pods to be scheduled. Continuing anyway."
            kubectl get pods | grep $JOB_NAME_DASH
            break
        fi

        if [ $SCHEDULED_PODS -lt $WORKER_COUNT ]; then
            sleep 1
            echo "Waiting for $JOB_NAME pods to be scheduled ($SCHEDULED_PODS/$WORKER_COUNT scheduled)"
        else
            echo "All pods for $JOB_NAME have been scheduled to nodes"
            kubectl get pods -o wide | grep $JOB_NAME_DASH
            echo "Node allocation for $JOB_NAME:" > ${{SAVEPATH}}/${{JOB_NAME}}_node_allocation.txt
            kubectl get pods -o wide | grep $JOB_NAME_DASH | awk '{{print $1 "\\t" $7}}' >> ${{SAVEPATH}}/${{JOB_NAME}}_node_allocation.txt

            # 각 포드의 생성 시간 기록
            for pod in $(kubectl get pods | grep $JOB_NAME_DASH | awk '{{print $1}}'); do
                echo "$(date "+%H:%M:%S.%N")" > ${{SAVEPATH}}/${{pod}}_create.txt
            done
            
            break
        fi
    done
}}

# 완료된 작업 정리 함수
cleanup_completed_jobs() {{
    SCHEDULER="$1"
    
    COMPLETED_CONTROLLERS=$(kubectl get pod -o wide | grep -e "controller-" -e "chief-" | grep Completed | awk '{{print $1}}')
    if [ -n "${{COMPLETED_CONTROLLERS}}" ]; then
        for completed_pod in ${{COMPLETED_CONTROLLERS}}; do
            # 작업 이름 추출
            COMPLETED_JOB=$(echo ${{completed_pod}} | awk -F '-' '{{
                jobname = $1
                for (i = 2; i <= NF - 2; i++) {{
                    jobname = jobname "_" $i
                }}
                print jobname
            }}')

            # 작업 포드 이름 추출
            COMPLETED_JOB_POD=$(echo ${{completed_pod}} | awk -F '-' '{{
                jobname = $1
                for (i = 2; i <= NF - 2; i++) {{
                    jobname = jobname "-" $i
                }}
                print jobname
            }}')

            echo "Job ${{COMPLETED_JOB}} completed, freeing resources"

            # 노드 정보 저장
            kubectl get pod -o wide | grep ${{COMPLETED_JOB_POD}} | awk '{{print $1 "\\t" $7}}' > ${{SAVEPATH}}/${{COMPLETED_JOB}}_node_info.txt
            # 작업 완료 시간 기록
            echo "$(date "+%H:%M:%S.%N")" > ${{SAVEPATH}}/${{COMPLETED_JOB}}_job_completed.txt

            # 작업 삭제
            kubectl delete -f ${{TFPATH}}/net_script/${{COMPLETED_JOB}}_${{SCHEDULER}}.yaml
        done
        return 0
    fi
    return 1
}}

# 자원과 arrival_time을 고려하여 대기하는 함수 (스케줄러에 따라 다른 로직 적용)
wait_for_resources_or_arrival() {{
    ARRIVAL_TIME=$1
    JOB_NAME=$2
    WORKER_NUM=$3
    SCHEDULER="$4"

    echo "Checking resources for job ${{JOB_NAME}} (arrival time: ${{ARRIVAL_TIME}}s, workers: $WORKER_NUM)"
    echo $ARRIVAL_TIME > ${{SAVEPATH}}/${{JOB_NAME}}_arrival_timestamp.txt

    while true; do
        # arrival time 체크
        CURRENT_EPOCH=$(date +%s)
        TIME_PASSED=$((CURRENT_EPOCH - STARTEPOCH))

        # arrival time이 되지 않았으면 계속 대기
        if [ $TIME_PASSED -lt $ARRIVAL_TIME ]; then
            TIME_REMAINING=$((ARRIVAL_TIME - TIME_PASSED))
            echo "Waiting for arrival time for job ${{JOB_NAME}} (Remaining: ${{TIME_REMAINING}}s)"
            sleep 1
            continue
        fi

        # k8s 스케줄러에만 Gang 스케줄링 적용
        if [ "$SCHEDULER" = "k8s" ]; then
            # Gang 스케줄링 로직: 사용 가능한 GPU 수 확인
            AVAILABLE_GPUS=$(get_available_gpus)
            echo "Current available GPUs: $AVAILABLE_GPUS (needed: $WORKER_NUM)"

            # 완료된 작업 확인 및 정리
            cleanup_completed_jobs $SCHEDULER

            # 자원이 해제되었으므로 다시 확인
            AVAILABLE_GPUS=$(get_available_gpus)
            echo "Available GPUs after cleanup: $AVAILABLE_GPUS (needed: $WORKER_NUM)"

            # Gang 스케줄링: 필요한 모든 GPU가 사용 가능할 때만 작업 제출
            if [ $AVAILABLE_GPUS -ge $WORKER_NUM ]; then
                echo "Sufficient GPUs available ($AVAILABLE_GPUS >= $WORKER_NUM). Starting job ${{JOB_NAME}} now."
                return 0
            else
                echo "Waiting for sufficient GPU resources for job ${{JOB_NAME}} ($AVAILABLE_GPUS/$WORKER_NUM available)"
                sleep 5
                continue
            fi
        else
            # 다른 스케줄러는 기존 로직 사용 (대기 중인 포드 확인)
            PENDING_PODS=$(kubectl get pods | grep -e "Pending" | wc -l)

            # 대기 중인 포드가 없으면 (이전 작업들이 모두 자원 할당 받은 상태) 즉시 작업 시작
            if [ $PENDING_PODS -eq 0 ]; then
                echo "Arrival time reached and no pending pods. Starting job ${{JOB_NAME}} now."
                CURRENT_EPOCH=$(date +%s)
                TIME_PASSED=$((CURRENT_EPOCH - STARTEPOCH))
                echo $TIME_PASSED > ${{SAVEPATH}}/${{JOB_NAME}}_queuehead_timestamp.txt
                return 0
            else
                # 대기 중인 포드가 있으면 완료된 작업 확인 및 정리
                if cleanup_completed_jobs $SCHEDULER; then
                    # 완료된 작업이 정리되었으므로 대기 중인 포드 다시 확인
                    PENDING_PODS=$(kubectl get pods | grep -e "Pending" | wc -l)
                    if [ $PENDING_PODS -eq 0 ]; then
                        echo "All previous jobs allocated. Starting job ${{JOB_NAME}} now."
                        return 0
                    fi
                fi

                echo "Arrival time reached but waiting for previous jobs to be allocated resources first."
                sleep 0.5
            fi
        fi
    done
}}

echo "총 GPU 수: {total_gpu_num}"

'''

    # begin to print shell script
    print(template_head)
    
    # 각 작업에 대해 새로운 구조로 생성
    for i, (job_name, job_config) in enumerate(job_configs.items()):
        job_name_ub = job_name.replace('-', '_')
        worker_num = job_config['worker_num']
        model_name = job_config['model_name']
        dataset_name = job_config['dataset_name']
        batch_size = job_config['batch_size']
        
        # arrival_time은 현재 0으로 설정 (필요에 따라 수정 가능)
        arrival_time = 0
        
        print(f"""
# 작업: {job_name_ub} (모델: {model_name}, 워커: {worker_num}, 도착시간: {arrival_time}초)
wait_for_resources_or_arrival {arrival_time} {job_name_ub} {worker_num} {scheduler_name}
# 작업 생성 시간 기록
echo "$(date "+%H:%M:%S.%N")" > ${{SAVEPATH}}/{job_name_ub}_job_create.txt
kubectl apply -f ${{TFPATH}}/net_script/{job_name_ub}_{scheduler_name}.yaml
wait_for_pod_scheduling {job_name_ub} {worker_num}

""")

    # Template end
    template_end = f'''

ENDTIME=`date "+%H:%M:%S.%N"`
echo "$ENDTIME" > ${{SAVEPATH}}/end_makespan.txt
ENDLOGTIME=$(($(date +%s%N)/1000000000))
LOGTIME=$(($ENDLOGTIME - $STARTLOGTIME))

# 스케줄러 전체 로그
kubectl logs -n kube-system kube-scheduler-xsailor-master > ${{SAVEPATH}}/scheduler_full_log.txt

kubectl logs -n kube-system tensorspot-scheduler > ${{SAVEPATH}}/scheduler_log.txt

'''
    
    if is_GCP:
        for node in nodes:
            template_end += f'''gcloud compute ssh --zone us-central1-a {node} --command "sudo sh /home/jhlee21/gpu_off.sh"
'''
    else:
        template_end += '''
# On-prem
ssh xsailor2@163.152.20.132 "sudo sh /home/jhlee21/gpu_off.sh"
ssh xsailor3@163.152.20.155 "sudo sh /home/jhlee21/gpu_off.sh"
'''

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
