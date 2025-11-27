"""
Julia包环境管理器 - 最小依赖版本
自动检测并安装用户代码中需要的包
"""

using Pkg

# 最小核心依赖（必需）
const CORE_PACKAGES = ["Revise", "BenchmarkTools"]

#=
可选包分类（注释中提供参考）:

# 数据处理类
DATA_PACKAGES = ["DataFrames", "CSV", "JSON", "Parquet"]

# 可视化类
VISUALIZATION_PACKAGES = ["Plots", "PlotThemes", "Measures", "GR"]

# 科学计算类
SCIENTIFIC_PACKAGES = ["ITensors", "FFTW", "LinearAlgebra", "Statistics"]

# 机器学习类
ML_PACKAGES = ["Flux", "MLJ", "MLBase", "LossFunctions"]

# 优化类
OPTIMIZATION_PACKAGES = ["Optim", "JuMP", "NLopt"]

# 符号计算类
SYMBOLIC_PACKAGES = ["Symbolics", "SymPy"]

# 网络和Web类
WEB_PACKAGES = ["HTTP", "JSON", "XMLDict"]

# 测试类
TESTING_PACKAGES = ["Test", "Aqua", "BenchmarkTools"]
=#

function extract_packages_from_file(filepath::String)
    """从Julia文件中提取所有使用的包"""
    packages = Set{String}()

    try
        content = read(filepath, String)

        # 匹配 using 和 import 语句
        using_pattern = r"(?:using|import)\s+([^\s;]+)"
        for match in eachmatch(using_pattern, content)
            pkg_string = match.captures[1]

            # 处理多种情况:
            # using Pkg -> Pkg
            # using DataFrames, CSV -> ["DataFrames", "CSV"]
            # using Statistics: mean -> Statistics
            # using .MyModule -> 忽略本地模块

            for pkg in split(pkg_string, ",")
                pkg_clean = strip(pkg)

                # 移除子模块部分 (如 Statistics:mean -> Statistics)
                pkg_clean = split(pkg_clean, ":")[1]
                pkg_clean = split(pkg_clean, ".")[1]

                # 忽略标准库和本地模块
                if !startswith(pkg_clean, ".") && pkg_clean != "Main"
                    push!(packages, pkg_clean)
                end
            end
        end

        return collect(packages)

    catch e
        println("❌ 读取文件失败 $filepath: $e")
        return String[]
    end
end

function detect_required_packages(project_files::Vector{String})
    """检测项目中需要的所有包"""
    all_packages = Set{String}()

    for file in project_files
        if isfile(file) && endswith(file, ".jl")
            println("🔍 扫描文件: $file")
            file_packages = extract_packages_from_file(file)
            for pkg in file_packages
                push!(all_packages, pkg)
            end
        end
    end

    return collect(all_packages)
end

function setup_minimal_environment()
    """设置最小环境（只安装核心包）"""
    println("🎯 设置最小Julia环境...")

    for pkg in CORE_PACKAGES
        try
            println("📦 安装核心包: $pkg")
            Pkg.add(pkg)
        catch e
            println("❌ 安装核心包失败 $pkg: $e")
        end
    end

    println("✅ 最小环境设置完成")
    println("💡 核心包: $(join(CORE_PACKAGES, ", "))")
end

function setup_user_environment(project_files::Vector{String})
    """根据用户文件自动设置环境"""
    println("🚀 自动检测项目依赖...")

    # 1. 先安装核心包
    setup_minimal_environment()

    # 2. 检测用户需要的包
    required_packages = detect_required_packages(project_files)

    # 3. 移除核心包（已安装）和标准库
    standard_libs = ["LinearAlgebra", "Statistics", "Random", "Dates", "Base", "Core", "Main"]
    filter!(pkg -> !(pkg in CORE_PACKAGES) && !(pkg in standard_libs), required_packages)

    if isempty(required_packages)
        println("✅ 没有检测到额外的包需求")
        return true
    end

    println("📋 检测到需要的包: $(join(required_packages, ", "))")

    # 4. 安装用户包
    success_count = 0
    for pkg in required_packages
        try
            println("📦 安装: $pkg")
            Pkg.add(pkg)
            println("✅ $pkg 安装成功")
            success_count += 1
        catch e
            println("❌ $pkg 安装失败: $e")
        end
    end

    # 5. 预编译
    if success_count > 0
        println("🔄 预编译包...")
        Pkg.precompile()
    end

    println("📊 安装结果: $success_count/$(length(required_packages)) 成功")
    return success_count == length(required_packages)
end

function scan_current_directory()
    """扫描当前目录的所有.jl文件"""
    return filter(file -> endswith(file, ".jl"), readdir())
end

function quick_auto_setup(target_file=nothing)
    """快速自动设置"""
    println("🎯 Julia环境自动设置")

    if target_file !== nothing
        # 设置单个文件的环境
        project_files = [target_file]
    else
        # 扫描当前目录
        project_files = scan_current_directory()
    end

    if isempty(project_files)
        println("⚠️  没有找到.jl文件，使用最小环境")
        setup_minimal_environment()
        return false
    end

    println("📁 找到Julia文件: $(join(project_files, ", "))")
    return setup_user_environment(project_files)
end

function install_packages(package_names::Vector{String})
    """安装指定包列表"""
    for pkg in package_names
        try
            println("📦 安装: $pkg")
            Pkg.add(pkg)
            println("✅ $pkg 安装成功")
        catch e
            println("❌ $pkg 安装失败: $e")
        end
    end

    println("🔄 预编译包...")
    Pkg.precompile()
end

# 便捷启动函数
function setup_julia_environment(target_file::String)
    """为指定Julia文件设置环境"""
    return quick_auto_setup(target_file)
end

println("🎯 智能包管理器已加载")
println("💡 主要功能:")
println("   quick_auto_setup()              # 自动扫描并安装当前目录的包依赖")
println("   setup_julia_environment(file)    # 为单个文件设置环境")
println("   detect_required_packages(files)  # 检测文件需要的包")
println("   setup_minimal_environment()      # 最小环境（Revise + BenchmarkTools）")

# 如果直接运行此脚本
if abspath(PROGRAM_FILE) == @__FILE__
    quick_auto_setup()
end