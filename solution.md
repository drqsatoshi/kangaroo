## Solution: build/run Kangaroo in Cloud Shell vs GPU

### What’s happening
- **Cloud Shell has no NVIDIA GPU and usually no CUDA toolkit**, so the GPU build fails with errors like:
  - `make: /usr/local/cuda-8.0/bin/nvcc: No such file or directory`
- **CPU build works** (you can compile and run), but **puzzle #120 is far too large** to finish on CPU in any reasonable time.

---

## Option A (Cloud Shell / CPU-only): works, but only for small ranges

### Build (CPU)
```bash
make clean
make -j
```

### Run a normal config file
```bash
./kangaroo -t 4 in.txt
```

### Run a puzzle block using the `-puzzle` helper
```bash
./kangaroo -puzzle 120 puzzle32.txt
```

Add threads/DP as needed:
```bash
./kangaroo -t 4 -d 45 -puzzle 120 puzzle32.txt
```

---

## Option B (Recommended): GPU build on a real GPU machine

### 1) Use a machine with an NVIDIA GPU
Examples:
- GCE VM with **T4 / L4 / A100**
- Any Linux box with NVIDIA drivers installed

### 2) Install CUDA toolkit (must include `nvcc`)
Common install path:
- `/usr/local/cuda`

Verify:
```bash
nvcc --version
nvidia-smi
```

### 3) Build with Makefile overrides (no Makefile edits required)
```bash
make clean
make gpu=1 CUDA=/usr/local/cuda CXXCUDA=/usr/bin/g++ ccap=86 -j
```

Pick `ccap` based on GPU:
- **T4**: `ccap=75`
- **A100**: `ccap=80`
- **L4**: `ccap=89`

### 4) Run on GPU
```bash
./kangaroo -gpu -gpuId 0 -puzzle 120 puzzle32.txt
```

---

## Key takeaway
- **Cloud Shell**: fine for compiling + small CPU demos, not for CUDA/GPU.
- **GPU machine**: required for practical performance on large puzzles (like #120).
