#!/usr/bin/env julia

"""
增强版Julia服务器启动器
支持性能监控、包管理、日志记录等功能
"""

using Pkg
using Dates

# 服务器配置
const SERVER_CONFIG = Dict(
    "host" => "localhost",
    "port" => 8080,
    "log_file" => "julia_server.log",
    "command_file" => "julia_command.txt",
    "response_file" => "julia_response.txt",
    "heartbeat_file" => "julia_heartbeat.txt",
    "max_memory" => 4.0,  # GB
    "gc_threshold" => 0.8  # 触发垃圾回收的内存阈值
)

# 预加载包列表
const PRELOAD_PACKAGES = [
    "Revise",
    "Plots",
    "DataFrames",
    "CSV",
    "BenchmarkTools",
    "FFTW",
    "ITensors",
    "LinearAlgebra",
    "Statistics",
    "Random"
]

function setup_logging()
    """设置日志系统"""
    log_file = SERVER_CONFIG["log_file"]
    open(log_file, "a") do f
        write(f, "\n=== Julia Server Started at $(now()) ===\n")
    end
    return log_file
end

function log_message(message::String)
    """记录日志消息"""
    open(SERVER_CONFIG["log_file"], "a") do f
        write(f, "[$(now())] $message\n")
    end
    println(message)
end

function load_packages()
    """加载预配置包"""
    log_message("📦 开始加载预配置包...")

    for pkg in PRELOAD_PACKAGES
        try
            @eval using $(Symbol(pkg))
            log_message("✅ $pkg 加载成功")
        catch e
            log_message("❌ $pkg 加载失败: $e")
        end
    end

    log_message("🎯 包加载完成")
end

function setup_revise()
    """配置Revise.jl热重载"""
    try
        using Revise
        # 监控当前目录的.jl文件
        revise()
        log_message("🔄 Revise.jl 热重载已激活")
    catch e
        log_message("❌ Revise.jl 配置失败: $e")
    end
end

function setup_server_files()
    """初始化通信文件"""
    files_to_clean = [
        SERVER_CONFIG["command_file"],
        SERVER_CONFIG["response_file"],
        SERVER_CONFIG["heartbeat_file"]
    ]

    for file in files_to_clean
        if isfile(file)
            rm(file)
        end
    end

    log_message("🗂️ 通信文件已初始化")
end

function monitor_memory()
    """监控内存使用情况"""
    memory_usage = Base.gc_live_bytes() / (1024^3)  # GB
    return memory_usage
end

function gc_if_needed()
    """必要时执行垃圾回收"""
    memory_usage = monitor_memory()
    if memory_usage > SERVER_CONFIG["max_memory"] * SERVER_CONFIG["gc_threshold"]
        log_message("🧹 内存使用过高 ($(round(memory_usage, digits=2))GB)，执行垃圾回收...")
        GC.gc()
        new_usage = monitor_memory()
        log_message("✅ 垃圾回收完成，内存使用: $(round(new_usage, digits=2))GB")
    end
end

function update_heartbeat()
    """更新心跳文件"""
    heartbeat_data = Dict(
        "timestamp" => string(now()),
        "memory_usage" => monitor_memory(),
        "uptime" => time()
    )

    open(SERVER_CONFIG["heartbeat_file"], "w") do f
        write(f, JSON.json(heartbeat_data))
    end
end

function process_command_enhanced(command::String)
    """增强版命令处理"""
    start_time = time()

    try
        log_message("📨 处理命令: $command")

        # 预处理命令
        processed_command = preprocess_command(command)

        # 执行命令
        result = eval(Meta.parse(processed_command))

        # 后处理结果
        response = postprocess_result(result)

        # 记录执行时间
        exec_time = round(time() - start_time, digits=3)
        log_message("✅ 命令执行成功 ($(exec_time)s)")

        return response

    catch e
        exec_time = round(time() - start_time, digits=3)
        error_msg = "❌ 执行失败 ($(exec_time)s): $e"
        log_message(error_msg)
        return error_msg
    end
end

function preprocess_command(command::String)
    """命令预处理"""
    # 特殊命令处理
    if command == "server_status"
        return "get_server_status()"
    elseif command == "server_restart"
        return "restart_server()"
    elseif command == "memory_cleanup"
        return "GC.gc(); \"内存清理完成\""
    elseif command == "package_test"
        return "test_all_packages()"
    end

    return command
end

function postprocess_result(result)
    """结果后处理"""
    # 处理不同类型的结果
    if isa(result, String)
        return result
    elseif isa(result, AbstractArray)
        return "数组结果: size=$(size(result)), type=$(typeof(result))"
    elseif isa(result, Number)
        return string(result)
    else
        return "执行成功: $(typeof(result))"
    end
end

function get_server_status()
    """获取服务器状态"""
    memory_usage = monitor_memory()
    loaded_packages = [string(pkg) for pkg in names(Main) if !startswith(string(pkg), "#")]

    status = """
    🤖 Julia服务器状态报告
    ================
    📊 内存使用: $(round(memory_usage, digits=2)) GB
    📦 已加载包: $(length(loaded_packages)) 个
    ⏱️  运行时间: $(round(time() - SERVER_START_TIME, digits=1)) 秒
    🔄 Revise状态: $(isdefined(Main, :Revise) ? "已激活" : "未激活")
    """

    return strip(status)
end

function test_all_packages()
    """测试所有预配置包"""
    log_message("🧪 开始测试预配置包...")

    results = []
    for pkg in PRELOAD_PACKAGES
        try
            @eval using $(Symbol(pkg))
            push!(results, "✅ $pkg")
        catch e
            push!(results, "❌ $pkg: $e")
        end
    end

    log_message("📋 包测试完成")
    return join(results, "\n")
end

function main_server_loop()
    """主服务循环"""
    log_message("🎯 Julia服务器启动完成，进入主循环...")

    command_file = SERVER_CONFIG["command_file"]
    response_file = SERVER_CONFIG["response_file"]

    # 心跳计数器
    heartbeat_counter = 0

    while true
        sleep(0.3)  # 检查间隔300ms

        # 检查命令文件
        if isfile(command_file)
            command = strip(read(command_file, String))

            if !isempty(command)
                # 处理命令
                response = process_command_enhanced(command)

                # 写入响应
                open(response_file, "w") do f
                    write(f, response)
                end

                # 清理命令文件
                rm(command_file)

                log_message("📤 响应已发送")
            end
        end

        # 定期更新心跳和清理内存
        heartbeat_counter += 1
        if heartbeat_counter % 20 == 0  # 每6秒更新一次
            update_heartbeat()
            gc_if_needed()
        end

        # 检查关闭信号
        if isfile("server_shutdown.txt")
            log_message("🛑 收到关闭信号，正在关闭服务器...")
            rm("server_shutdown.txt")
            break
        end
    end
end

# 服务器入口函数
function start_enhanced_server()
    """启动增强版Julia服务器"""
    global SERVER_START_TIME = time()

    println("🚀 启动增强版Julia服务器...")

    # 初始化
    setup_logging()
    setup_server_files()
    load_packages()
    setup_revise()

    # 启动主循环
    main_server_loop()

    log_message("👋 Julia服务器已关闭")
end

# 如果直接运行此脚本
if abspath(PROGRAM_FILE) == @__FILE__
    start_enhanced_server()
end