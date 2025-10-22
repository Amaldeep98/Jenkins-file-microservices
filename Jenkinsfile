pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        SOURCE_IMAGE = "us-central1-docker.pkg.dev/google-samples/microservices-demo/loadgenerator"
        ECR_URI = "183611507646.dkr.ecr.us-east-1.amazonaws.com"
        REPO_NAME = "microservices-demo/loadgenerator"
        GITHUB_REPO = "https://github.com/Amaldeep98/microservice-helm-charts.git"
        CHART_DIR = "helm-charts/loadgenerator"
    }

    stages {
        stage('Get Latest Tag') {
            steps {
                script {
                    env.LATEST_TAG = sh(
                        script: '''
                            #!/bin/bash
                            set -e
                            echo " Fetching latest image tag from source registry..." >&2
                            TAG_JSON=$(curl -s https://us-central1-docker.pkg.dev/v2/google-samples/microservices-demo/loadgenerator/tags/list)
                            LATEST_TAG=$(echo "$TAG_JSON" | jq -r '.tags[]' | sort | tail -n 1)

                            if [ -z "$LATEST_TAG" ]; then
                                echo " Failed to get latest tag!" >&2
                                exit 1
                            fi

                            echo " Latest tag detected: $LATEST_TAG" >&2
                            echo "$LATEST_TAG"
                        ''',
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Sync Image to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh '''
                        #!/bin/bash
                        set -e

                        echo " Logging in to ECR..."
                        aws configure set default.region ${AWS_REGION}
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

                        echo " Ensuring ECR repository exists..."
                        aws ecr describe-repositories --repository-names ${REPO_NAME} --region ${AWS_REGION} || \
                            aws ecr create-repository --repository-name ${REPO_NAME} --region ${AWS_REGION}

                        echo " Checking if ${LATEST_TAG} already exists in ECR..."
                        if aws ecr describe-images --repository-name ${REPO_NAME} --region ${AWS_REGION} \
                            --query 'imageDetails[].imageTags[]' --output text | grep -w "${LATEST_TAG}"; then
                            echo " Tag ${LATEST_TAG} already exists in ECR. Skipping pull and push."
                        else
                            echo " Pulling image from GCP and pushing to ECR..."
                            docker pull ${SOURCE_IMAGE}:${LATEST_TAG}
                            docker tag ${SOURCE_IMAGE}:${LATEST_TAG} ${ECR_URI}/${REPO_NAME}:${LATEST_TAG}
                            docker push ${ECR_URI}/${REPO_NAME}:${LATEST_TAG}
                        fi
                    '''
                }
            }
        }

        stage('Verify Sync') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh '''
                        #!/bin/bash
                        set -e

                        echo " Verifying image presence in ECR..."
                        aws configure set default.region ${AWS_REGION}
                        if aws ecr describe-images --repository-name ${REPO_NAME} --region ${AWS_REGION} \
                            --query 'imageDetails[*].imageTags' | grep -q "${LATEST_TAG}"; then
                            echo " Sync Verified!"
                        else
                            echo " Sync verification failed!"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Update Helm Chart and Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        #!/bin/bash
                        set -e

                        # Clone repo if not present
                        if [ ! -d "microservice-helm-charts" ]; then
                            echo " Cloning GitHub repo..."
                            git clone ${GITHUB_REPO}
                            cd microservice-helm-charts
                        else
                            cd microservice-helm-charts
                            git pull origin main
                        fi

                        CHART_NAME=$(basename ${CHART_DIR})

                        git config --global user.email "jenkins@example.com"
                        git config --global user.name "Jenkins CI"

                        # Update Chart.yaml version using sed
                        sed -i "s/^version: .*/version: $LATEST_TAG/" ${CHART_DIR}/Chart.yaml

                        # Update values.yaml image.tag using sed (assumes '  tag: old' format)
                        sed -i "s/^  *tag: .*/  tag: $LATEST_TAG/" ${CHART_DIR}/values.yaml

                        mkdir -p charts
                        helm package ${CHART_DIR} --destination charts
                        helm repo index charts --url https://raw.githubusercontent.com/Amaldeep98/microservice-helm-charts/main/charts

                        git add ${CHART_DIR}/Chart.yaml ${CHART_DIR}/values.yaml charts/${CHART_NAME}-${LATEST_TAG}.tgz index.yaml
                        git commit -m "Update loadgenerator Helm chart to $LATEST_TAG" || echo "No changes to commit"
                        git push https://${GIT_USER}:${GIT_TOKEN}@github.com/Amaldeep98/microservice-helm-charts.git main
                    '''
                }
            }
        }
    }
}
