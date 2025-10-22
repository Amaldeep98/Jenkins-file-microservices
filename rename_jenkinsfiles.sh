#!/bin/bash

# List of all service branches
branches=("emailservice" "adservice" "cartservice" "checkoutservice" "currencyservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

for branch in "${branches[@]}"; do
    echo "Renaming Jenkins file in $branch branch..."
    git checkout $branch
    
    # Find the Jenkins file for this branch
    jenkins_file=$(find jenkins-files/ -name "jenkisfile-*" | head -1)
    
    if [ -f "$jenkins_file" ]; then
        echo "Renaming $jenkins_file to Jenkinsfile..."
        
        # Rename the file
        mv "$jenkins_file" "Jenkinsfile"
        
        # Remove the jenkins-files directory if empty
        if [ -d "jenkins-files" ] && [ -z "$(ls -A jenkins-files)" ]; then
            rmdir jenkins-files
        fi
        
        git add .
        git commit -m "Rename Jenkins file to Jenkinsfile in $branch branch"
        echo "✅ Renamed Jenkins file in $branch"
    else
        echo "❌ No Jenkins file found in $branch"
    fi
done

echo "🎉 All Jenkins files renamed to Jenkinsfile!"
