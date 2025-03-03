<<<<<<< HEAD
# OpenFaaS Function Build & Deploy Script

This repository contains tools for building and deploying OpenFaaS functions, with a focus on automating the build and deployment process for multiple functions defined in a single `stack.yaml` file.

## Project Structure

```
.
├── build-runtime.sh        # Main build and deployment script
├── stack.yaml             # OpenFaaS function definitions
├── template/              # Function templates
│   └── python3-flask/     # Python Flask template
├── test.sh               # Test script for function invocation
└── functions/            # Individual function directories
    ├── function1/        # First function
    │   ├── handler.py    # Function logic
    │   └── requirements.txt
    └── function2/        # Second function
        ├── handler.py
        └── requirements.txt
```

## Prerequisites

- Docker installed and running
- OpenFaaS installed and running (`gateway` accessible at http://127.0.0.1:8080)
- `faas-cli` installed and configured
- `kubectl` installed and configured with access to your OpenFaaS namespace
- Python 3.x installed (for Python functions)

## Build & Deploy Script (build-runtime.sh)

The `build-runtime.sh` script automates the entire build and deployment process for OpenFaaS functions.

### Usage

```bash
# Build and deploy with default version (latest)
./build-runtime.sh

# Build and deploy with specific version
./build-runtime.sh -v 1.0
```

### What the Script Does

1. **Function Discovery**
   - Automatically finds all functions defined in stack.yaml
   - Extracts function names and version information
   - Validates function configurations

2. **Build Process (Per Function)**
   - Creates clean build environment
   - Copies function template (python3-flask)
   - Copies function-specific code
   - Builds Docker image with proper versioning

3. **Deployment**
   - Removes existing function deployments
   - Deploys all functions using faas-cli
   - Updates image pull policies for local development

### Script Output

The script provides detailed progress information:

```bash
Found functions:
  - function1
  - function2
----------------------------------------
Processing function: function1
Using version: 1.0
Setting up build environment...
Building function1:1.0
[Build output...]
----------------------------------------
Deploying all functions...
[Deployment output...]
```

### Error Handling

The script includes comprehensive error checking:
- Validates function existence
- Checks for build failures
- Monitors deployment status
- Reports any issues during the process

## Function Development

### 1. Create New Function

```bash
faas-cli new my-function --lang python3-flask
```

### 2. Update stack.yaml

Add your function to `stack.yaml`:
```yaml
functions:
  my-function:
    lang: python3-flask
    handler: ./my-function
    image: my-function:v1.0
```

### 3. Build and Deploy

```bash
# Build and deploy with version 1.0
./build-runtime.sh -v 1.0
```

### 4. Test Function

```bash
# Test synchronously
curl -X POST http://127.0.0.1:8080/function/my-function \
     -H "Content-Type: application/json" \
     -d '{"name": "test"}'

# Test asynchronously
curl -X POST http://127.0.0.1:8080/async-function/my-function \
     -H "Content-Type: application/json" \
     -d '{"name": "test"}'
```

## Troubleshooting

1. **Build Issues**
   - Check Docker daemon is running
   - Verify network connectivity
   - Check function dependencies
   ```bash
   # View build logs
   docker build --network=host -t function-name:version build/function-name
   ```

2. **Deployment Issues**
   - Verify OpenFaaS is running
   ```bash
   curl http://127.0.0.1:8080/system/functions
   ```
   - Check function status
   ```bash
   kubectl get deployments -n openfaas-fn
   kubectl describe deployment function-name -n openfaas-fn
   ```

3. **Runtime Issues**
   - Check function logs
   ```bash
   kubectl logs -n openfaas-fn -l faas_function=function-name
   ```
   - Check function invocation
   ```bash
   faas-cli logs function-name
   ```

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

[Your License Here]
=======
# OpenFaaS-Usage
>>>>>>> e15d7c9997e7cbcea5ff62b0319cadccca5c38bb
