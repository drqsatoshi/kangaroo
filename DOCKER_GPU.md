# GPU Docker workflow (Kangaroo)

This repo can build a GPU-enabled `kangaroo` binary inside a container, but **GPU access comes from the host**.

## 1) Host prerequisites (must be on a real GPU machine)

- Install NVIDIA driver on the host (so `nvidia-smi` works on the host).
- Install Docker on the host.
- Install NVIDIA Container Toolkit on the host (this is what makes `docker run --gpus all` work).

### Install NVIDIA Container Toolkit (Ubuntu 24.04)

First, confirm Docker currently does *not* have the NVIDIA runtime (typical output is only `runc`):

- `docker info | grep -i runtime -A2`

Install and configure the NVIDIA runtime:

- `sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg`
- `sudo install -m 0755 -d /etc/apt/keyrings`
- `curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit.gpg`
- `curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
	sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://#g' | \
	sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list`
- `sudo apt-get update`
- `sudo apt-get install -y nvidia-container-toolkit`

Configure Docker to use it:

- `sudo nvidia-ctk runtime configure --runtime=docker`

Restart Docker (pick the one that works on your host):

- `sudo systemctl restart docker`
- or: `sudo service docker restart`

Re-check runtimes:

- `docker info | grep -i runtime -A2`

If you still don’t see an `nvidia` runtime, the toolkit setup on the host is not complete.

Quick sanity check on the host:

- `nvidia-smi`

Then check Docker can see the GPU:

- `docker run --rm --gpus all nvidia/cuda:12.0.1-base-ubuntu22.04 nvidia-smi`

If that fails, fix the host runtime/toolkit first; rebuilding containers won’t help.

## 2) Build the image

From the repo root:

- `docker build -f Dockerfile.gpu -t kangaroo-gpu:cuda12 .`

## 3) Build the GPU binary inside the container

Mount the repo into the container and compile:

- `docker run --rm -it --gpus all -v "$PWD":/work -w /work kangaroo-gpu:cuda12 make clean`
- `docker run --rm -it --gpus all -v "$PWD":/work -w /work kangaroo-gpu:cuda12 make gpu=1 ccap=80 -j`

Set `ccap` to your GPU’s compute capability:

- A100: `ccap=80`
- T4: `ccap=75`
- L4: `ccap=89`

## 4) Verify GPU visibility from inside the container

- `docker run --rm -it --gpus all -v "$PWD":/work -w /work kangaroo-gpu:cuda12 ./kangaroo -l`

## 5) Run a puzzle (example)

- `docker run --rm -it --gpus all -v "$PWD":/work -w /work kangaroo-gpu:cuda12 ./kangaroo -puzzle 120 puzzle32.txt -gpu -gpuId 0 -t 1 -m 0.01`
