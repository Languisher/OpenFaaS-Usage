#!/bin/bash

rm -rf build
mkdir build

# -------------------- parameters --------------------
# Default version if not specified
version="latest"

# Parse command line arguments
while getopts "v:" opt; do
  case ${opt} in
    v ) version=$OPTARG ;;
  esac
done

# Function to extract image tag from stack.yaml for a given function
get_image_tag() {
    local func_name=$1
    local tag=$(grep -A 1 "image: $func_name:" stack.yaml | grep "image:" | awk -F: '{print $3}' | tr -d ' ' || echo "$version")
    if [ -z "$tag" ]; then
        echo "$version"
    else
        echo "$tag"
    fi
}

# 1. Find all functions in the stack.yaml
function_names=$(grep "handler: \." stack.yaml | awk '{print $2}' | sed 's/\.\///' | tr -d '\r')

# Check if we found any functions
if [ -z "$function_names" ]; then
    echo "Error: No functions found in stack.yaml"
    exit 1
fi

echo "Found functions:"
echo "$function_names" | while read -r function_name; do
    echo "  - $function_name"
done

# Process each function
echo "$function_names" | while read -r function_name; do
    if [ -z "$function_name" ]; then
        continue
    fi
    
    echo "----------------------------------------"
    echo "Processing function: $function_name"
    
    # Get version from stack.yaml or use default
    func_version=$(get_image_tag "$function_name")
    echo "Using version: $func_version"

    # 2. Copy the template files to build directory
    echo "Setting up build environment..."
    cp -r template/python3-flask "build/$function_name"
    
    # 3. Copy handler files to function directory
    cp -r "$function_name"/* "build/$function_name/function/"
    
    # 4. Build the function image
    echo "Building $function_name:$func_version"
    if ! docker build --network=host -t "$function_name:$func_version" "build/$function_name"; then
        echo "Error: Failed to build $function_name"
        continue
    fi
done

# 5. Deploy all functions using faas-cli
echo "----------------------------------------"
echo "Deploying all functions..."

# Remove existing deployments first
echo "$function_names" | while read -r function_name; do
    echo "Removing old deployment of $function_name..."
    faas-cli remove "$function_name"
done

# Wait for removals to complete
echo "Waiting for removals to complete..."
sleep 10

# Deploy all functions
if ! faas-cli deploy; then
    echo "Error: Failed to deploy functions"
    exit 1
fi

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
sleep 10

# 6. Update image pull policy for each function
echo "----------------------------------------"
echo "Updating image pull policies..."

echo "$function_names" | while read -r function_name; do
    echo "Updating image pull policy for $function_name..."
    if ! kubectl patch deployment "$function_name" -n openfaas-fn -p "$(cat <<EOF
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "$function_name",
            "imagePullPolicy": "IfNotPresent"
          }
        ]
      }
    }
  }
}
EOF
)"; then
        echo "Warning: Failed to update image pull policy for $function_name"
    fi
done

echo "----------------------------------------"
echo "All functions have been processed!"

