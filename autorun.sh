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
        POD_OUTPUT=$(kubectl get pods --no-headers | grep "${job_number}")
        echo "Debug: Pod output:"
        echo "${POD_OUTPUT}"

        if [[ "${job_file}" == a*.yaml ]]; then
            # Check if any controller pod exists
            CONTROLLER_POD=$(echo "${POD_OUTPUT}" | grep "controller")
            echo "Debug: Controller pod output:"
            echo "${CONTROLLER_POD}"
            
            CONTROLLER_EXISTS=$(echo "${CONTROLLER_POD}" | wc -l)
            echo "Debug: Controller exists count: ${CONTROLLER_EXISTS}"

            if [ "${CONTROLLER_EXISTS}" -gt 0 ]; then
                # If any controller pod exists, check if it's completed
                CONTROLLER_COMPLETED=$(echo "${CONTROLLER_POD}" | grep "Completed" | wc -l)
                echo "Debug: Controller completed count: ${CONTROLLER_COMPLETED}"

                if [ "${CONTROLLER_COMPLETED}" -eq "${CONTROLLER_EXISTS}" ]; then
                    echo "Controller pod for job ${job_number} is Completed."
                    echo "Deleting job: ${job_file}"
                    kubectl delete -f "${job_file}"
                    break
                fi
            fi

            # If no controller pod or it's not completed, check workers
            COMPLETED_WORKERS=$(echo "${POD_OUTPUT}" | grep "worker" | grep "Completed" | wc -l)
            TOTAL_WORKERS=$(echo "${POD_OUTPUT}" | grep "worker" | wc -l)

            echo "Debug: Completed workers: ${COMPLETED_WORKERS} / Total workers: ${TOTAL_WORKERS}"

            if [ "${COMPLETED_WORKERS}" -eq "${TOTAL_WORKERS}" ] && [ "${TOTAL_WORKERS}" -gt 0 ]; then
                echo "All worker pods for job ${job_number} are Completed."
                echo "Deleting job: ${job_file}"
                kubectl delete -f "${job_file}"
                break
            fi
        else
            # For p*.yaml jobs
            COMPLETED_WORKERS=$(echo "${POD_OUTPUT}" | grep "worker" | grep "Completed" | wc -l)
            TOTAL_WORKERS=$(echo "${POD_OUTPUT}" | grep "worker" | wc -l)

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
