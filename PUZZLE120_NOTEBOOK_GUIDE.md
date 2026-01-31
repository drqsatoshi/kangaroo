# Puzzle #120 GPU Notebook Guide

## Quick Start

The `puzzle120_gpu_1hour.ipynb` notebook provides a ready-to-use solution for running the Kangaroo ECDLP solver on Puzzle #120 with GPU acceleration for exactly 1 hour.

## Puzzle #120 Details

- **Bitcoin Address**: 17s2b9ksz5y7abUm92cHwG8jEPCzK3dLnT
- **Start Range**: `800000000000000000000000000000` (hex)
- **End Range**: `FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF` (hex)  
- **Public Key**: `02CEB6CBBCDBDF5EF7150682150F4CE2C6F4807B349827DCDBDD1F2EFA885A2630`
- **Range Width**: ~119 bits
- **Difficulty**: Extremely High (estimated years on single GPU)

## What This Notebook Does

### ✅ Automated Setup
- Detects GPU and CUDA installation
- Determines compute capability automatically
- Compiles Kangaroo with GPU support
- Validates puzzle configuration

### ✅ Optimized Execution
- Runs GPU solver for exactly 60 minutes
- Uses recommended parameters (DP bits = 25)
- Saves work file every 5 minutes
- Displays real-time progress

### ✅ Work Management
- Automatically saves progress
- Provides work file information
- Shows resumption commands
- Supports merging with other work files

## How to Use

### Option 1: Google Colab

1. **Upload to Colab**:
   - Go to [Google Colab](https://colab.research.google.com/)
   - File → Upload notebook
   - Select `puzzle120_gpu_1hour.ipynb`

2. **Enable GPU**:
   - Runtime → Change runtime type
   - Hardware accelerator → GPU
   - Select GPU type (T4, V100, A100, etc.)

3. **Run**:
   - Click Runtime → Run all
   - Or execute cells sequentially (Shift+Enter)

4. **Download Work File**:
   - Work file downloads automatically in Section 10
   - Save it to continue later

### Option 2: Kaggle

1. **Import Notebook**:
   - Go to [Kaggle](https://www.kaggle.com/)
   - Code → New Notebook → Import
   - Select `puzzle120_gpu_1hour.ipynb`

2. **Settings**:
   - Accelerator → GPU
   - GPU type: P100 or T4 (depending on availability)
   - Internet: ON (for cloning repository)

3. **Run**:
   - Run all cells
   - Monitor output in real-time

4. **Save Work**:
   - Download work file before session expires
   - Use "Save Version" to preserve output

### Option 3: Local Jupyter

**Prerequisites**:
- Python 3.6+
- Jupyter Notebook
- NVIDIA GPU with CUDA support
- CUDA Toolkit installed

**Steps**:

```bash
# Install Jupyter if needed
pip install jupyter notebook

# Clone repository
git clone https://github.com/drqsatoshi/kangaroo.git
cd kangaroo

# Launch notebook
jupyter notebook puzzle120_gpu_1hour.ipynb
```

## Understanding the Output

### During Execution

You'll see output like:

```
[7828.45 MK/s][GPU 7828.45 MK/s][Count 2^43.22][Dead 2][24:56 (Avg 20:24)][4.8/6.9GB]
```

- **MK/s**: Million keys per second (performance metric)
- **Count**: Total operations performed (in powers of 2)
- **Dead**: Dead kangaroos (duplicate paths)
- **Time**: Elapsed time
- **Memory**: RAM usage

### After 1 Hour

The notebook will:
1. Automatically terminate the solver
2. Save the final work file
3. Display statistics
4. Show resumption commands

### Work File Information

After the run, you'll see:

```
Work File Information:
- DP bits: 25
- Operations: 2^XX.XX
- Time: 1:00:00
- DP Count: XXXXX
- Kangaroos: 2^XX.XX
```

## Resuming Your Work

### Continue on Same Machine

```bash
./kangaroo -gpu -gpuId 0 -d 25 -ws \
  -i puzzle120_work_YYYYMMDD_HHMMSS.work \
  -w puzzle120_work_YYYYMMDD_HHMMSS.work \
  -wi 300 -o result.txt
```

### Run Another 1-Hour Session

Simply run the notebook again. To continue from your previous work:
1. Upload your previous work file
2. Modify Section 5 to add `-i previous_work.work` option
3. Run the notebook

### Merge Multiple Work Files

If you've run multiple 1-hour sessions:

```bash
./kangaroo -wm work1.work work2.work work3.work merged.work
```

This will:
- Combine all progress
- Check for collisions (key found!)
- Create a merged work file

## Performance Expectations

### Single GPU Performance

| GPU Model | MKey/s (approx) | Operations/hour |
|-----------|----------------|-----------------|
| Tesla T4 | ~1,500 | 5.4 × 10^12 |
| Tesla V100 | ~2,000 | 7.2 × 10^12 |
| RTX 3090 | ~3,000 | 1.08 × 10^13 |
| Tesla A100 | ~3,500 | 1.26 × 10^13 |

### Time to Solve Puzzle #120

- **Expected operations**: ~2^60.5 = 1.8 × 10^18
- **Single Tesla V100**: ~7,900 years
- **256× Tesla V100**: ~31 years
- **This puzzle requires collaborative/distributed effort**

## Important Notes

### ⚠️ Realistic Expectations

- **Puzzle #120 cannot be solved in 1 hour** even with the most powerful GPUs
- Each 1-hour run contributes a tiny fraction of the required work
- The value is in:
  - Learning how the solver works
  - Testing your GPU performance
  - Contributing to collaborative efforts
  - Building work files for resumption

### 💡 Best Practices

1. **Save work files regularly**: The notebook saves every 5 minutes
2. **Backup your work**: Download and store work files safely
3. **Merge periodically**: Combine work files to check for solutions
4. **Monitor resources**: Watch GPU temperature and memory
5. **Use screen/tmux**: For long-running local sessions

### 🔐 Security & Ethics

- This is an **educational tool** for understanding cryptography
- Only use on puzzles/challenges you have permission to solve
- The Bitcoin puzzle #120 is a public challenge
- Do not attempt to attack real Bitcoin addresses
- Real Bitcoin uses full 256-bit keys (computationally secure)

## Distributed Solving

For serious attempts at Puzzle #120, consider distributed solving:

### Server Setup

```bash
./kangaroo -s -d 25 -w server.work -wi 300 -wsplit -o result.txt puzzle120.txt
```

### Client Setup (multiple machines)

```bash
# Machine 1
./kangaroo -gpu -gpuId 0 -w client1.work -wi 600 -wss -c server_ip

# Machine 2  
./kangaroo -gpu -gpuId 0 -w client2.work -wi 600 -wss -c server_ip

# Machine N
./kangaroo -gpu -gpuId 0 -w clientN.work -wi 600 -wss -c server_ip
```

## Troubleshooting

### GPU Not Detected

**Problem**: Notebook says "No GPU detected"

**Solutions**:
- Check runtime settings (Colab/Kaggle)
- Verify CUDA installation: `nvidia-smi`
- Try fallback to CPU build: `make all` (very slow)

### Build Fails

**Problem**: Compilation errors during GPU build

**Solutions**:
- Check compute capability matches your GPU
- Verify CUDA path: `/usr/local/cuda`
- Try older CUDA version
- Check gcc version compatibility

### Out of Memory

**Problem**: "Out of memory" during execution

**Solutions**:
- Increase DP bits: change `DP_BITS = 26` or `27`
- Reduce GPU grid size
- Close other applications
- Use smaller batch size

### Work File Not Saved

**Problem**: No work file after run

**Solutions**:
- Check disk space
- Verify write permissions
- Increase save interval for testing
- Check for error messages during save

## FAQ

**Q: Can this solve Puzzle #120 in 1 hour?**  
A: No. Puzzle #120 requires years even on powerful GPU clusters.

**Q: What's the point of running for 1 hour?**  
A: Learning, benchmarking, contributing to distributed efforts, and generating work files.

**Q: Can I run for longer than 1 hour?**  
A: Yes! Modify `RUN_TIME_SECONDS = 3600` to any duration.

**Q: How do I combine work from multiple runs?**  
A: Use the merge command: `./kangaroo -wm file1.work file2.work merged.work`

**Q: Is my work wasted if I don't find the key?**  
A: No! Work files can be resumed, merged, and contribute to overall progress.

**Q: Can I use multiple GPUs?**  
A: Yes! Change `GPU_IDS = "0,1,2,3"` to use multiple GPUs.

## Additional Resources

- **Main Notebook**: [kangaroo_ecdlp_solver.ipynb](kangaroo_ecdlp_solver.ipynb) - Comprehensive guide
- **Documentation**: [NOTEBOOK_README.md](NOTEBOOK_README.md) - Notebook documentation
- **Repository**: [drqsatoshi/kangaroo](https://github.com/drqsatoshi/kangaroo)
- **Original**: [JeanLucPons/Kangaroo](https://github.com/JeanLucPons/Kangaroo)
- **Discussion**: [BitcoinTalk Thread](https://bitcointalk.org/index.php?topic=5244940.0)

## Contributing

If you make improvements to this notebook:
1. Fork the repository
2. Make your changes
3. Submit a pull request
4. Share your findings!

---

**Happy Hunting! 🦘 Remember: Persistence and collaboration are key!**
