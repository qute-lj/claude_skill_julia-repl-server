# 🚀 Julia REPL Server - Claude Skill

<div align="center">

[![Julia](https://img.shields.io/badge/Julia-1.12+-blue.svg)](https://julialang.org)
[![Claude Skill](https://img.shields.io/badge/Claude%20Skill-v1.0-orange.svg)](https://claude.com/claude-code)

**零等待Julia开发环境**

</div>

## 📋 核心功能

- **⚡ 零编译时间** - 平均响应时间仅 1.136μs
- **🔄 热重载支持** - 基于 Revise.jl 的即时代码更新
- **📦 智能包管理** - 自动检测并安装用户代码所需的包
- **🛡️ 错误隔离** - 错误不会中断服务器会话

## 🚀 快速开始

### 1. 设置环境

```bash
# 进入技能目录
cd julia-repl-server

# 自动检测并安装包依赖
julia scripts/package_manager.jl
```

### 2. 启动服务器

```bash
# 启动持久Julia服务器
julia scripts/julia_server_launcher.jl
```

### 3. 使用技能

在 Claude Code 中：

```julia
# 执行你的Julia文件
execute_julia("include(\"my_analysis.jl\")")

# 热重载执行（代码修改后立即生效）
execute_julia("includet(\"my_functions.jl\")")

# 执行Julia命令
execute_julia("using DataFrames; df = DataFrame(x=1:100, y=rand(100))")
```

## 📁 项目结构

```
julia-repl-server/
├── SKILL.md                           # 技能定义文件
├── scripts/                           # 核心脚本
│   ├── julia_server_launcher.jl       # Julia服务器
│   └── package_manager.jl             # 智能包管理器
├── references/                        # 参考文档
│   ├── julia_packages_guide.md        # Julia包使用指南
│   └── performance_benchmarks.md      # 性能基准测试
└── assets/                            # 资源文件
    ├── project_templates/             # 项目模板
    ├── sample_datasets/               # 示例数据
    └── visualization_templates/       # 可视化模板
```

## 🎯 核心特性

### 智能包管理

自动扫描用户目录中的 `.jl` 文件，检测 `using`/`import` 语句：

```julia
# 你的 my_analysis.jl 包含：
# using DataFrames, CSV, Plots

# 自动检测并安装：
quick_auto_setup()
```

### 热重载开发

```julia
# 使用 Revise.jl 支持代码修改后立即生效
execute_julia("includet(\"my_code.jl\")")

# 修改代码后直接测试，无需重启
execute_julia("my_function(test_data)")
```

### 性能表现

| 测试项目 | 结果 |
|----------|------|
| **平均执行时间** | **1.136μs** |
| **20×20矩阵乘法** | **14.08 GFLOPS** |
| **内存分配** | **3287 bytes** |
| **启动等待** | **零（一次性）** |

## 💡 使用示例

### 数据科学工作流

```julia
# 1. 设置环境
quick_auto_setup()

# 2. 加载数据
execute_julia("using CSV, DataFrames; df = CSV.read(\"data.csv\", DataFrame)")

# 3. 数据分析
execute_julia("describe(df)")

# 4. 可视化
execute_julia("using Plots; plot(df.x, df.y)")
```

### 科学计算工作流

```julia
# 1. 环境设置
setup_julia_environment("tensor_network.jl")

# 2. 执行计算
execute_julia("include(\"tensor_network.jl\")")

# 3. 性能测试
execute_julia("@benchmark my_tensor_calculation()")
```

## 🔧 故障排除

### 常见问题

**服务器无响应：**
```bash
# 重启服务器
julia scripts/julia_server_launcher.jl
```

**包导入失败：**
```julia
# 重新安装包
execute_julia("using Pkg; Pkg.build(\"PackageName\")")
```

**内存不足：**
```julia
# 清理内存
execute_julia("GC.gc()")
```

## 📊 性能基准

### 标准测试

```julia
# 矩阵运算性能
execute_julia("@benchmark rand(1000, 1000) * rand(1000, 1000)")

# 数据处理性能
execute_julia("@benchmark filter(row -> row.x > 0.5, df)")

# 内存使用
execute_julia("Base.gc_live_bytes() / (1024^2)")  # MB
```

## 🤝 贡献

基于原始 [`julia_server_for_Claude_Code`](../) 项目改进，专为 Claude Code 技能化而设计。

## 📄 许可证

MIT License

---

<div align="center">

**🚀 立即体验零等待的Julia开发！**

*零编译时间 + 热重载 + 智能包管理*

</div>