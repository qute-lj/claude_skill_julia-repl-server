"""
科学计算项目模板
适用于数据分析、数值模拟和可视化任务
"""

# 包导入区域
using Pkg

# 检查并安装必需的包
required_packages = [
    "DataFrames",
    "Plots",
    "Statistics",
    "LinearAlgebra",
    "CSV",
    "BenchmarkTools"
]

for pkg in required_packages
    try
        @eval using $(Symbol(pkg))
        println("✅ $pkg 已加载")
    catch e
        println("⚠️  $pkg 未安装，正在安装...")
        Pkg.add(pkg)
        @eval using $(Symbol(pkg))
    end
end

# 可选包
optional_packages = ["FFTW", "ITensors", "Distributions"]

for pkg in optional_packages
    try
        @eval using $(Symbol(pkg))
        println("✅ $pkg (可选) 已加载")
    catch
        println("ℹ️  $pkg (可选) 未安装")
    end
end

# 项目配置
const PROJECT_NAME = "My Scientific Project"
const PROJECT_VERSION = "1.0.0"
const AUTHOR = "Your Name"

# 全局设置
println("🚀 启动项目: $PROJECT_NAME")
println("📅 启动时间: $(now())")

# Plots配置
default(size=(800, 600), legend=true, grid=true)

# 数据路径配置
const DATA_DIR = "data"
const RESULTS_DIR = "results"
const PLOTS_DIR = "plots"

# 创建必要的目录
for dir in [DATA_DIR, RESULTS_DIR, PLOTS_DIR]
    if !isdir(dir)
        mkpath(dir)
        println("📁 创建目录: $dir")
    end
end

# 核心功能函数

"""
    load_data(filename::String)

从CSV文件加载数据
"""
function load_data(filename::String)
    filepath = joinpath(DATA_DIR, filename)
    if isfile(filepath)
        df = CSV.read(filepath, DataFrame)
        println("📊 已加载数据: $filename ($(nrow(df)) 行)")
        return df
    else
        error("❌ 文件不存在: $filepath")
    end
end

"""
    save_results(data, filename::String)

保存结果到文件
"""
function save_results(data, filename::String)
    filepath = joinpath(RESULTS_DIR, filename)
    if isa(data, DataFrame)
        CSV.write(filepath, data)
    else
        open(filepath, "w") do f
            write(f, string(data))
        end
    end
    println("💾 结果已保存: $filename")
end

"""
    create_plot(data...; title="", filename=nothing)

创建并保存图表
"""
function create_plot(data...; title="", filename=nothing)
    p = plot(data..., title=title)

    if filename !== nothing
        filepath = joinpath(PLOTS_DIR, filename)
        savefig(p, filepath)
        println("📈 图表已保存: $filename")
    end

    return p
end

"""
    run_benchmark(func, args...; samples=100)

对函数进行基准测试
"""
function run_benchmark(func, args...; samples=100)
    println("⏱️  开始基准测试: $(string(func))")

    benchmark_result = @benchmark $func($args...) samples=samples

    stats = (
        avg_time_ms = round(mean(benchmark_result.times) / 1e6, digits=2),
        min_time_ms = round(minimum(benchmark_result.times) / 1e6, digits=2),
        max_time_ms = round(maximum(benchmark_result.times) / 1e6, digits=2),
        memory_mb = round(benchmark_result.memory / (1024^2), digits=1)
    )

    println("📊 基准测试结果:")
    println("   平均时间: $(stats.avg_time_ms) ms")
    println("   最小时间: $(stats.min_time_ms) ms")
    println("   最大时间: $(stats.max_time_ms) ms")
    println("   内存使用: $(stats.memory_mb) MB")

    return stats
end

# 数据处理函数

"""
    clean_data(df::DataFrame)

基本数据清洗
"""
function clean_data(df::DataFrame)
    println("🧹 开始数据清洗...")

    # 删除缺失值
    clean_df = dropmissing(df)
    removed_rows = nrow(df) - nrow(clean_df)

    if removed_rows > 0
        println("   删除了 $removed_rows 行缺失数据")
    end

    # 删除重复行
    clean_df = unique(clean_df)
    duplicate_rows = nrow(df) - nrow(clean_df) - removed_rows

    if duplicate_rows > 0
        println("   删除了 $duplicate_rows 行重复数据")
    end

    println("✅ 数据清洗完成: $(nrow(clean_df)) 行, $(ncol(clean_df)) 列")
    return clean_df
end

"""
    basic_statistics(df::DataFrame)

计算基本统计信息
"""
function basic_statistics(df::DataFrame)
    println("📈 计算基本统计信息...")

    numeric_cols = names(df, Union{Missing,Number})
    stats = Dict()

    for col in numeric_cols
        col_data = df[!, col] |> skipmissing |> collect
        if !isempty(col_data)
            stats[col] = (
                mean = mean(col_data),
                std = std(col_data),
                min = minimum(col_data),
                max = maximum(col_data),
                median = median(col_data)
            )
        end
    end

    return stats
end

# 可视化函数

"""
    plot_distribution(df::DataFrame, column::Symbol)

绘制数据分布图
"""
function plot_distribution(df::DataFrame, column::Symbol)
    data = df[!, column] |> skipmissing |> collect
    p = histogram(data,
        title="Distribution of $column",
        xlabel=string(column),
        ylabel="Frequency",
        alpha=0.7,
        bins=30
    )

    filename = "distribution_$(string(column)).png"
    return create_plot(p, filename=filename)
end

"""
    plot_correlation_matrix(df::DataFrame)

绘制相关性矩阵热图
"""
function plot_correlation_matrix(df::DataFrame)
    numeric_cols = names(df, Union{Missing,Number})
    if length(numeric_cols) < 2
        println("⚠️  需要至少两个数值列来计算相关性")
        return nothing
    end

    # 计算相关性矩阵
    numeric_data = df[!, numeric_cols]
    corr_matrix = cor(Matrix(numeric_data))

    p = heatmap(corr_matrix,
        title="Correlation Matrix",
        xlabel="Features",
        ylabel="Features",
        color=:RdBu,
        clim=(-1, 1)
    )

    return create_plot(p, filename="correlation_matrix.png")
end

# 数值分析函数

"""
    perform_fft(signal::Vector{Float64})

对信号执行FFT分析
"""
function perform_fft(signal::Vector{Float64})
    if !@isdefined(FFTW)
        println("⚠️  FFTW.jl 未安装，无法执行FFT分析")
        return nothing
    end

    println("🎵 执行FFT分析...")

    # 执行FFT
    fft_result = fft(signal)
    frequencies = fftfreq(length(signal))
    power_spectrum = abs.(fft_result).^2

    # 绘制频谱
    half_n = div(length(signal), 2)
    p = plot(frequencies[1:half_n], power_spectrum[1:half_n],
        title="Power Spectrum",
        xlabel="Frequency",
        ylabel="Power",
        yscale=:log10
    )

    create_plot(p, filename="fft_spectrum.png")

    return (
        fft_result = fft_result,
        frequencies = frequencies,
        power_spectrum = power_spectrum
    )
end

# 项目状态函数

"""
    project_status()

显示项目当前状态
"""
function project_status()
    println("\n" * "="^50)
    println("📊 项目状态报告")
    println("="^50)
    println("项目名称: $PROJECT_NAME")
    println("版本: $PROJECT_VERSION")
    println("作者: $AUTHOR")
    println("Julia版本: $(VERSION)")

    # 检查目录
    println("\n📁 项目目录:")
    for dir in [DATA_DIR, RESULTS_DIR, PLOTS_DIR]
        status = isdir(dir) ? "✅ 存在" : "❌ 不存在"
        count = isdir(dir) ? length(readdir(dir)) : 0
        println("   $dir: $status ($count 个文件)")
    end

    # 内存使用情况
    memory_mb = Base.gc_live_bytes() / (1024^2)
    println("\n💾 内存使用: $(round(memory_mb, digits=2)) MB")

    # 加载的包
    loaded_packages = [string(pkg) for pkg in names(Main) if !startswith(string(pkg), "#")]
    println("\n📦 已加载包: $(length(loaded_packages))")

    println("="^50)
end

# 初始化项目
println("\n🎉 项目模板加载完成!")
println("💡 可用函数:")
println("   load_data(filename) - 加载CSV数据")
println("   save_results(data, filename) - 保存结果")
println("   clean_data(df) - 数据清洗")
println("   basic_statistics(df) - 基本统计")
println("   plot_distribution(df, column) - 分布图")
println("   plot_correlation_matrix(df) - 相关性热图")
println("   run_benchmark(func, args...) - 基准测试")
println("   project_status() - 项目状态")
println("\n开始你的科学计算之旅吧! 🚀")

# 显示初始状态
project_status()