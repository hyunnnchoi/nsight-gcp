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
        
        if [[ "${job_file}" == a*.yaml ]]; then
            # Check if controller-0 exists
            CONTROLLER_EXISTS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "controller-0" | wc -l)
            echo "Debug: Controller exists: ${CONTROLLER_EXISTS}"
            
            if [ "${CONTROLLER_EXISTS}" -gt 0 ]; then
                # If controller-0 exists, check if it's completed
                CONTROLLER_COMPLETED=$(kubectl get pods --no-headers | grep "${job_number}" | grep "controller-0" | grep "Completed" | wc -l)
                echo "Debug: Controller completed: ${CONTROLLER_COMPLETED}"

                if [ "${CONTROLLER_COMPLETED}" -eq "${CONTROLLER_EXISTS}" ]; then
                    echo "Controller pod for job ${job_number} is Completed."
                    echo "Deleting job: ${job_file}"
                    kubectl delete -f "${job_file}"
                    break
                fi
            fi

            # If no controller-0 or it's not completed, check workers
            COMPLETED_WORKERS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "worker" | grep "Completed" | wc -l)
            TOTAL_WORKERS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "worker" | wc -l)

            echo "Debug: Completed workers: ${COMPLETED_WORKERS} / Total workers: ${TOTAL_WORKERS}"

            if [ "${COMPLETED_WORKERS}" -eq "${TOTAL_WORKERS}" ] && [ "${TOTAL_WORKERS}" -gt 0 ]; then
                echo "All worker pods for job ${job_number} are Completed."
                echo "Deleting job: ${job_file}"
                kubectl delete -f "${job_file}"
                break
            fi
        else
            # For p*.yaml jobs
            COMPLETED_WORKERS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "worker" | grep "Completed" | wc -l)
            TOTAL_WORKERS=$(kubectl get pods --no-headers | grep "${job_number}" | grep "worker" | wc -l)

            echo "Debug: Completed workers: ${COMPLETED_WORKERS} / Total workers: ${TOTAL_WORKERS}"

            if [ "${COMPLETED_WORKERS}" -eq "${TOTAL_WORKERS}" ] && [ "${TOTAL_WORKERS}" -gt 0 ]; then
                echo "All worker pods for job ${job_number} are Completed."
                echo "Deleting job: ${job_file}"
                kubectl delete -f "${job_file}"
                break
            fi
        fi

        echo "Waiting for pods of job ${job_number} to complete..."
        sleep 5
    done
done
