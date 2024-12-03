#!/bin/bash

JOB_DIR="./"
JOB_FILES=($(ls ${JOB_DIR}a*.yaml 2>/dev/null | sort -V))

if [ "${#JOB_FILES[@]}" -eq 0 ]; then
    echo "No jobs starting with 'a' found. Switching to jobs starting with 'p'."
    JOB_FILES=($(ls ${JOB_DIR}p*.yaml 2>/dev/null | sort -V))
fi

if [ "${#JOB_FILES[@]}" -eq 0 ]; then
    echo "No jobs found to process."
    exit 0
fi

for job_file in "${JOB_FILES[@]}"; do
    echo "Running job: ${job_file}"
    kubectl create -f "${job_file}"
    job_number=$(basename "${job_file}" .yaml | grep -oE '^t[0-9]+')

    while true; do
        echo "Debug: Checking all pods related to job ${job_number}"
        kubectl get pods --no-headers | grep "${job_number}"
        COMPLETED_WORKERS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "worker" | grep "Completed" | wc -l)
        TOTAL_WORKERS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "worker" | wc -l)

        echo "Debug: Completed workers: ${COMPLETED_WORKERS} / Total workers: ${TOTAL_WORKERS}"

        if [ "${COMPLETED_WORKERS}" -eq "${TOTAL_WORKERS}" ] && [ "${TOTAL_WORKERS}" -gt 0 ]; then
            echo "All worker pods for job ${job_number} are Completed."
            echo "Deleting job: ${job_file}"
            kubectl delete -f "${job_file}"
            break
        fi

        echo "Waiting for worker pods of job ${job_number} to complete..."
        sleep 5
    done
done
