#!/bin/bash

branches=("cartservice" "checkoutservice" "currencyservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

for branch in "${branches[@]}"; do
    echo "Fixing $branch branch..."
    git checkout $branch
    
    # Remove emailservice file if it exists
    if [ -f "jenkins-files/jenkisfile-emailservice" ]; then
        rm jenkins-files/jenkisfile-emailservice
        git add .
        git commit -m "Remove emailservice from $branch branch - keep only $branch pipeline"
        echo "✅ Removed emailservice from $branch"
    else
        echo "✅ $branch already clean"
    fi
done

echo "🎉 All branches cleaned!"
