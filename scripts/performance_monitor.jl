"""
Julia服务器性能监控器
用于监控服务器性能、内存使用和响应时间
"""

using Statistics
using Dates
using JSON

mutable struct PerformanceMonitor
    start_time::Float64
    response_times::Vector{Float64}
    memory_samples::Vector{Float64}
    command_count::Int
    error_count::Int
    last_gc_time::Float64

    function PerformanceMonitor()
        new(time(), Float64[], Float64[], 0, 0, time())
    end
end

const MONITOR = PerformanceMonitor()

function log_command_response(execution_time::Float64)
    """记录命令响应时间"""
    push!(MONITOR.response_times, execution_time)
    MONITOR.command_count += 1
end

function log_error()
    """记录错误"""
    MONITOR.error_count += 1
end

function sample_memory()
    """采样内存使用情况"""
    memory_mb = Base.gc_live_bytes() / (1024^2)
    push!(MONITOR.memory_samples, memory_mb)
    return memory_mb
end

function get_performance_stats()
    """获取性能统计信息"""
    uptime = time() - MONITOR.start_time
    avg_response_time = isempty(MONITOR.response_times) ? 0.0 : mean(MONITOR.response_times)
    max_response_time = isempty(MONITOR.response_times) ? 0.0 : maximum(MONITOR.response_times)
    current_memory = sample_memory()
    avg_memory = isempty(MONITOR.memory_samples) ? 0.0 : mean(MONITOR.memory_samples)
    max_memory = isempty(MONITOR.memory_samples) ? 0.0 : maximum(MONITOR.memory_samples)

    error_rate = MONITOR.command_count > 0 ? MONITOR.error_count / MONITOR.command_count : 0.0

    stats = Dict(
        "uptime_seconds" => round(uptime, digits=1),
        "total_commands" => MONITOR.command_count,
        "total_errors" => MONITOR.error_count,
        "error_rate_percent" => round(error_rate * 100, digits=2),
        "avg_response_time_ms" => round(avg_response_time * 1000, digits=2),
        "max_response_time_ms" => round(max_response_time * 1000, digits=2),
        "current_memory_mb" => round(current_memory, digits=1),
        "avg_memory_mb" => round(avg_memory, digits=1),
        "max_memory_mb" => round(max_memory, digits=1),
        "last_gc_time" => MONITOR.last_gc_time
    )

    return stats
end

function format_performance_report()
    """生成性能报告"""
    stats = get_performance_stats()

    report = """
    📊 Julia服务器性能报告
    ===================

    🕐 运行时间: $(stats["uptime_seconds"]) 秒
    📈 命令统计: $(stats["total_commands"]) 次执行, $(stats["total_errors"]) 次错误
    ❌ 错误率: $(stats["error_rate_percent"])%

    ⏱️  响应时间:
       - 平均: $(stats["avg_response_time_ms"]) ms
       - 最大: $(stats["max_response_time_ms"]) ms

    🧠 内存使用:
       - 当前: $(stats["current_memory_mb"]) MB
       - 平均: $(stats["avg_memory_mb"]) MB
       - 峰值: $(stats["max_memory_mb"]) MB
    """

    return strip(report)
end

function save_performance_log()
    """保存性能日志到文件"""
    stats = get_performance_stats()
    log_entry = Dict(
        "timestamp" => string(now()),
        "stats" => stats
    )

    open("performance_log.json", "a") do f
        write(f, JSON.json(log_entry) * "\n")
    end

    return stats
end

function benchmark_function(func, args...; samples=100)
    """对函数进行基准测试"""
    times = Float64[]

    for i in 1:samples
        start_time = time()
        try
            func(args...)
            execution_time = time() - start_time
            push!(times, execution_time)
        catch e
            println("基准测试错误: $e")
        end
    end

    if isempty(times)
        return nothing
    end

    results = Dict(
        "function" => string(func),
        "samples" => length(times),
        "avg_time" => mean(times),
        "min_time" => minimum(times),
        "max_time" => maximum(times),
        "std_time" => std(times),
        "median_time" => median(times)
    )

    return results
end

function run_standard_benchmarks()
    """运行标准基准测试"""
    println("🚀 运行标准基准测试...")

    benchmarks = []

    # 矩阵乘法基准测试
    matrix_bench = benchmark_function() do
        A = rand(100, 100)
        B = rand(100, 100)
        A * B
    end

    if matrix_bench !== nothing
        matrix_bench["name"] = "100×100 矩阵乘法"
        matrix_bench["gflops"] = (2 * 100^3) / (matrix_bench["avg_time"] * 1e9)
        push!(benchmarks, matrix_bench)
    end

    # FFT基准测试
    fft_bench = benchmark_function() do
        x = rand(1024)
        fft(x)
    end

    if fft_bench !== nothing
        fft_bench["name"] = "1024点FFT"
        push!(benchmarks, fft_bench)
    end

    # 排序基准测试
    sort_bench = benchmark_function() do
        x = rand(10000)
        sort(x)
    end

    if sort_bench !== nothing
        sort_bench["name"] = "10k元素排序"
        push!(benchmarks, sort_bench)
    end

    # 生成基准测试报告
    report = "🏁 基准测试结果\n" * "="^30 * "\n"

    for bench in benchmarks
        report *= "\n📊 $(bench["name"]):\n"
        report *= "   平均时间: $(round(bench["avg_time"] * 1000, digits=2)) ms\n"
        report *= "   最小时间: $(round(bench["min_time"] * 1000, digits=2)) ms\n"
        report *= "   最大时间: $(round(bench["max_time"] * 1000, digits=2)) ms\n"

        if haskey(bench, "gflops")
            report *= "   性能: $(round(bench["gflops"], digits=2)) GFLOPS\n"
        end
    end

    println(report)
    return report
end

function monitor_system_resources()
    """监控系统资源使用"""
    memory_mb = sample_memory()

    # 检查内存是否过高
    if memory_mb > 2000  # 2GB阈值
        println("⚠️  内存使用过高: $(round(memory_mb, digits=1)) MB")
        return false
    end

    # 检查是否需要垃圾回收
    if time() - MONITOR.last_gc_time > 60  # 1分钟
        println("🧹 执行定期垃圾回收...")
        GC.gc()
        MONITOR.last_gc_time = time()
        new_memory = sample_memory()
        println("✅ 垃圾回收完成，释放了 $(round(memory_mb - new_memory, digits=1)) MB")
    end

    return true
end

function create_performance_dashboard()
    """创建性能监控面板"""
    stats = get_performance_stats()

    # 简单的文本面板
    dashboard = """
    ╔══════════════════════════════════════╗
    ║         Julia服务器监控面板          ║
    ╠══════════════════════════════════════╣
    ║ 状态: 🟢 正常运行                      ║
    ║ 运行时间: $(lpad("$(stats["uptime_seconds"])s", 25)) ║
    ║ 命令执行: $(lpad("$(stats["total_commands"]) 次", 25)) ║
    ║ 错误次数: $(lpad("$(stats["total_errors"]) 次", 25)) ║
    ║ 错误率: $(lpad("$(stats["error_rate_percent"])%", 25)) ║
    ╠══════════════════════════════════════╣
    ║ 响应时间: $(lpad("$(stats["avg_response_time_ms"]) ms", 23)) ║
    ║ 内存使用: $(lpad("$(stats["current_memory_mb"]) MB", 23)) ║
    ║ 峰值内存: $(lpad("$(stats["max_memory_mb"]) MB", 23)) ║
    ╚══════════════════════════════════════╝
    """

    return dashboard
end

# 便捷函数
function quick_status()
    """快速状态检查"""
    println(format_performance_report())
    return get_performance_stats()
end

function run_benchmarks()
    """运行基准测试"""
    return run_standard_benchmarks()
end

function show_dashboard()
    """显示监控面板"""
    println(create_performance_dashboard())
end

# 定期监控任务
function start_monitoring_task(interval_seconds=30)
    """启动定期监控任务"""
    while true
        sleep(interval_seconds)
        monitor_system_resources()
        save_performance_log()
    end
end

# 自动初始化
println("📊 性能监控器已加载")
println("💡 使用 quick_status() 查看状态, run_benchmarks() 运行基准测试")