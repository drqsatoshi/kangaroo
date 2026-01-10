## Gemini (Cloud Shell) – Detailed Solution

This doc is written for the **Gemini CLI inside Google Cloud Shell**, using your fork:

- Repo: `https://github.com/drqsatoshi/kangaroo`
- Goal: build CPU version in Cloud Shell, and (optionally) build GPU version on a real GPU machine.

---

## 1) Cloud Shell reality check (why GPU build fails)

Cloud Shell typically:
- has **no NVIDIA GPU**
- has **no CUDA toolkit** (`nvcc` missing)

So a GPU build will fail with something like:

```text
make: /usr/local/cuda-8.0/bin/nvcc: No such file or directory
```

That’s expected in Cloud Shell.

---

## 2) Make sure you have the updated fork (includes `-puzzle`)

If you see:

```text
Unexpected -puzzle argument
```

…it means **your Cloud Shell clone is missing the commit that added `-puzzle`**.

### Fix: pull latest changes and rebuild

In Cloud Shell:

```bash
cd kangaroo

git remote -v
# should show origin = github.com/drqsatoshi/kangaroo

git pull --ff-only

make clean
make -j
```

### Verify `-puzzle` exists

```bash
./kangaroo -h | grep -n "puzzle" || true
```

If it prints a usage line like:

```text
-puzzle n puzzleFile: Extract puzzle #n block from puzzleFile and run it
```

…then you’re on the correct version.

---

## 3) CPU build/run in Cloud Shell (works)

### Build (CPU)

```bash
cd kangaroo
make clean
make -j
```

### Sanity test with the small example (`in.txt`)

This one is intentionally small and should finish quickly on CPU:

```bash
./kangaroo -t 4 in.txt
```

---

## 4) Running puzzle #120 (two ways)

### Method A (recommended): use `-puzzle` (auto-extracts the block)

```bash
cd kangaroo
./kangaroo -puzzle 120 puzzle32.txt
```

This will create `puzzle120.txt` automatically and run it.

You can add CPU tuning flags:

```bash
./kangaroo -t 4 -d 45 -puzzle 120 puzzle32.txt
```

### Method B (manual): create a 3-line config file

If you don’t have `-puzzle`, you can still run by creating a valid one-range config file:

```bash
cat > puzzle120_input.txt << 'EOF'
800000000000000000000000000000
FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
02CEB6CBBCDBDF5EF7150682150F4CE2C6F4807B349827DCDBDD1F2EFA885A2630
EOF

./kangaroo -t 4 -d 45 puzzle120_input.txt
```

---

## 5) Important warning: puzzle #120 is enormous on CPU

Puzzle #120 has range width about **$2^{119}$**, so CPU-only runs are not practical.

In Cloud Shell you can:
- confirm it starts
- verify your input file is correct
- watch it print performance counters

…but you should not expect it to finish.

If you want a short “startup-only” run:

```bash
timeout 3s ./kangaroo -t 4 -d 45 puzzle120_input.txt
```

---

## 6) GPU build/run (do this on a GPU VM, not Cloud Shell)

### 6.1 Create a GPU VM (example suggestions)

Use a machine with a real NVIDIA GPU.

**Best (fastest) option:** **A100** (compute capability 8.0).

Other options (cheaper, still works):
- L4 (compute capability 8.9)
- T4 (compute capability 7.5)

Install NVIDIA driver + CUDA toolkit so `nvcc` exists.

Verify:

```bash
nvidia-smi
nvcc --version
```

### 6.2 Build with Makefile overrides

You do **not** need to edit the Makefile. Use overrides:

Build command template:

```bash
make clean
make gpu=1 CUDA=/usr/local/cuda CXXCUDA=/usr/bin/g++ ccap=80 -j
```

Pick the right `ccap`:
- T4: `ccap=75`
- A100: `ccap=80`
- L4: `ccap=89`

If you want “whatever works best”, pick **A100** and use `ccap=80`.

### 6.2.1 Practical GCE setup (recommended path)

On Google Compute Engine, the simplest approach is:
1) Create a VM with an **A100 GPU**.
2) Install NVIDIA driver + CUDA toolkit (so `nvidia-smi` and `nvcc` work).
3) Clone and build.

After CUDA is installed, verify:

```bash
nvidia-smi
nvcc --version
```

Then build:

```bash
git clone https://github.com/drqsatoshi/kangaroo
cd kangaroo
make clean
make gpu=1 CUDA=/usr/local/cuda CXXCUDA=/usr/bin/g++ ccap=80 -j
```

### 6.3 Run on GPU

```bash
./kangaroo -gpu -gpuId 0 -puzzle 120 puzzle32.txt
```

---

## 7) Quick debugging checklist (Gemini-friendly)

### “Unexpected -puzzle argument”
- You’re running an older binary.
- Fix: `git pull --ff-only && make clean && make -j`

### “nvcc not found”
- You’re in Cloud Shell or CUDA isn’t installed.
- Fix: move to a GPU machine + install CUDA.

### Input parse errors
- Kangaroo input must be:
  1) start range (hex)
  2) end range (hex)
  3) one or more public keys (hex starting with `02`/`03`/`04`)

---

## 8) Copy/paste Gemini prompt (recommended)

Use this in Gemini CLI to get consistent results:

```text
I’m in Google Cloud Shell. I cloned https://github.com/drqsatoshi/kangaroo.
I want to run puzzle #120.
Please give me exact commands to:
1) git pull + rebuild
2) verify -puzzle exists
3) run puzzle #120 with -t 4 -d 45
4) explain why GPU build fails in Cloud Shell
```
