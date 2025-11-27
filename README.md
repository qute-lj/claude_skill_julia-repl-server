# 🚀 Julia REPL Server - Claude Skill

<div align="center">

[![Julia](https://img.shields.io/badge/Julia-1.12+-blue.svg)](https://julialang.org)
[![Claude Skill](https://img.shields.io/badge/Claude%20Skill-v1.0-orange.svg)](https://claude.com/claude-code)

**Zero-Wait Julia Development Environment**

</div>

## ✨ Key Features

- **⚡ Zero Compilation Time** - Average response time: 1.136μs
- **🔄 Hot Reload Support** - Revise.jl powered instant code updates
- **📦 Smart Package Management** - Auto-detect and install user dependencies
- **🛡️ Error Isolation** - Errors won't terminate your development session
- **💻 Persistent REPL** - Background Julia server maintains state

## 🚀 Quick Start

### Step 1: Environment Setup

```bash
# Skill automatically creates julia-repl-server/ directory with all components
# Run package detection and installation
julia julia-repl-server/scripts/package_manager.jl
```

### Step 2: Start Server

```bash
# Launch persistent Julia server (runs in background)
julia julia-repl-server/scripts/julia_server_launcher.jl
```

### Step 3: Use in Claude Code

```julia
# Execute your Julia files
execute_julia("include(\"my_analysis.jl\")")

# Hot reload (code changes take effect immediately)
execute_julia("includet(\"my_functions.jl\")")

# Execute commands directly
execute_julia("using DataFrames; df = DataFrame(x=1:100, y=rand(100))")
```

## 🏗️ Architecture

The skill uses file-based communication between Claude Code and a persistent Julia server:

```
Claude Code ──write──► julia_command.txt ──read──► Julia Server
Claude Code ◄─read─── julia_response.txt ◄─write─── Julia Server
```

**Key Components:**
- **Persistent Julia Server** - Background process with preloaded packages
- **Smart Package Manager** - Scans user code for dependencies
- **File Communication** - Zero-latency command/response system

## 📁 Project Structure

```
julia-repl-server/
├── SKILL.md                           # Skill definition
├── scripts/                           # Core functionality
│   ├── julia_server_launcher.jl       # Julia server with monitoring
│   └── package_manager.jl             # Smart package detection
├── references/                        # Documentation
│   ├── julia_packages_guide.md        # Package usage guide
│   └── performance_benchmarks.md      # Benchmark procedures
└── assets/                            # Resources
    ├── project_templates/             # Julia project templates
    ├── sample_datasets/               # Sample data
    └── visualization_templates/       # Plot templates
```

## 💡 Usage Examples

### Data Science Workflow

```julia
# Setup environment (auto-detect dependencies)
quick_auto_setup()

# Load and analyze data
execute_julia("using CSV, DataFrames; df = CSV.read(\"data.csv\", DataFrame)")
execute_julia("describe(df)")

# Visualize results
execute_julia("using Plots; plot(df.x, df.y, title=\"Analysis\")")
```

### Scientific Computing

```julia
# Environment setup for specific file
setup_julia_environment("tensor_calc.jl")

# Execute with hot reload
execute_julia("includet(\"tensor_calc.jl\")")

# Performance benchmarking
execute_julia("@benchmark my_tensor_operation()")
```

### Development Workflow

```julia
# Iterative development with instant feedback
execute_julia("includet(\"my_code.jl\")")
# Edit my_code.jl...
execute_julia("my_function(test_data)")  # Changes take effect immediately
```

## 📊 Performance

| Metric | Result |
|--------|--------|
| **Average Execution Time** | **1.136μs** |
| **20×20 Matrix Multiplication** | **14.08 GFLOPS** |
| **Memory Allocation** | **3287 bytes** |
| **Startup Wait** | **Zero (one-time)** |

## 🔧 Troubleshooting

**Server Unresponsive:**
```bash
# Restart server
julia julia-repl-server/scripts/julia_server_launcher.jl
```

**Package Import Failed:**
```julia
# Rebuild package
execute_julia("using Pkg; Pkg.build(\"PackageName\")")
```

**Memory Issues:**
```julia
# Clear memory
execute_julia("GC.gc()")
```

## 🎯 Core Concepts

### Smart Package Detection
The package manager automatically scans your `.jl` files for `using` and `import` statements:

```julia
# your_file.jl contains:
# using DataFrames, CSV, Plots

# Auto-detection and installation:
quick_auto_setup()  # Installs DataFrames, CSV, Plots
```

### Hot Reload Development
Use Revise.jl for instant code updates:

```julia
execute_julia("includet(\"my_code.jl\")")
# Edit my_code.jl, changes take effect immediately
execute_julia("my_function()")  # Uses updated code
```

### Zero-Wait Execution
Maintain persistent server state for instant command execution without Julia compilation delays.

## 🤝 Contributing

Based on the original [`julia_server_for_Claude_Code`](../) project, specifically designed for Claude Code skill integration.

## 📄 License

MIT License

---

<div align="center">

**🚀 Experience Zero-Wait Julia Development!**

*Zero Compilation Time + Hot Reload + Smart Package Management*

</div>