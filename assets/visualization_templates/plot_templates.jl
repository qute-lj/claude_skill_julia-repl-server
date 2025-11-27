"""
Julia可视化模板集合
提供常用的科学绘图模板和样式
"""

using Plots

# 默认样式设置
default(size=(800, 600),
        legend=:topright,
        grid=true,
        alpha=0.8,
        dpi=300)

# 颜色主题
const COLORS = [:#1f77b4, :#ff7f0e, :#2ca02c, :#d62728, :#9467bd,
                :#8c564b, :#e377c2, :#7f7f7f, :#bcbd22, :#17becf]

"""
    line_plot(x, y; title="", xlabel="", ylabel="", label="")

创建高质量的线图
"""
function line_plot(x, y;
                  title="",
                  xlabel="",
                  ylabel="",
                  label="Data",
                  color=:auto,
                  linewidth=2)

    if color == :auto
        color = COLORS[1]
    end

    p = plot(x, y,
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
        label=label,
        color=color,
        linewidth=linewidth,
        markershape=:circle,
        markersize=4)

    return p
end

"""
    scatter_plot(x, y; title="", xlabel="", ylabel="", label="")

创建散点图
"""
function scatter_plot(x, y;
                     title="",
                     xlabel="",
                     ylabel="",
                     label="Data",
                     color=:auto,
                     size=50)

    if color == :auto
        color = COLORS[1]
    end

    p = scatter(x, y,
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
        label=label,
        color=color,
        markersize=size,
        markerstrokewidth=1,
        markerstrokecolor=:black,
        alpha=0.7)

    return p
end

"""
    histogram_plot(data; title="", xlabel="", ylabel="Frequency", bins=30)

创建直方图
"""
function histogram_plot(data;
                        title="",
                        xlabel="",
                        ylabel="Frequency",
                        bins=30,
                        color=:auto,
                        alpha=0.7)

    if color == :auto
        color = COLORS[1]
    end

    p = histogram(data,
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
        bins=bins,
        color=color,
        alpha=alpha,
        normalize=:probability,
        label="")

    return p
end

"""
    box_plot(data, labels; title="", ylabel="")

创建箱线图
"""
function box_plot(data::Vector, labels;
                  title="",
                  ylabel="",
                  color=:auto)

    if color == :auto
        color = COLORS[1]
    end

    p = boxplot(data,
        title=title,
        ylabel=ylabel,
        label=labels,
        color=color,
        legend=false,
        alpha=0.8)

    return p
end

"""
    heatmap_plot(data; title="", xlabel="", ylabel="", color=:viridis)

创建热图
"""
function heatmap_plot(data;
                     title="",
                     xlabel="",
                     ylabel="",
                     color=:viridis)

    p = heatmap(data,
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
        color=color,
        aspect_ratio=:equal,
        legend=false)

    return p
end

"""
    correlation_plot(corr_matrix; title="Correlation Matrix")

创建相关性矩阵热图
"""
function correlation_plot(corr_matrix; title="Correlation Matrix")
    p = heatmap(corr_matrix,
        title=title,
        xlabel="Variables",
        ylabel="Variables",
        color=:RdBu,
        clim=(-1, 1),
        aspect_ratio=:equal,
        legend=false)

    return p
end

"""
    multi_line_plot(x_data, y_data_list; labels, title="", xlabel="", ylabel="")

创建多条线图
"""
function multi_line_plot(x_data, y_data_list, labels;
                        title="",
                        xlabel="",
                        ylabel="")

    p = plot(title=title, xlabel=xlabel, ylabel=ylabel)

    for (i, (y_data, label)) in enumerate(zip(y_data_list, labels))
        color = COLORS[mod1(i, length(COLORS))]
        plot!(p, x_data, y_data,
              label=label,
              color=color,
              linewidth=2,
              markershape=:circle,
              markersize=3)
    end

    return p
end

"""
    subplot_grid(plots...; nrows, ncols, title="")

创建子图网格
"""
function subplot_grid(plots...; nrows, ncols, title="")
    p = plot(plots..., layout=(nrows, ncols), plot_title=title)
    return p
end

"""
    scientific_plot(x, y; title="", xlabel="", ylabel="", label="Data")

科学出版物风格的图表
"""
function scientific_plot(x, y;
                        title="",
                        xlabel="",
                        ylabel="",
                        label="Data")

    # 科学出版风格设置
    default(fontfamily="serif",
            guidefont=12,
            tickfont=10,
            legendfont=10,
            titlefont=14,
            linewidth=2,
            markerstrokecolor=:black,
            markerstrokewidth=0.5)

    p = plot(x, y,
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
        label=label,
        color=:black,
        markershape=:circle,
        markersize=4,
        grid=true,
        gridstyle=:solid,
        gridalpha=0.3,
        legend=:best)

    return p
end

"""
    time_series_plot(time_data, value_data; title="", ylabel="", label="")

时间序列图
"""
function time_series_plot(time_data, value_data;
                         title="",
                         ylabel="",
                         label="Value")

    p = plot(time_data, value_data,
        title=title,
        xlabel="Time",
        ylabel=ylabel,
        label=label,
        color=:blue,
        linewidth=2,
        markershape=:circle,
        markersize=3,
        alpha=0.8)

    return p
end

"""
    error_bars_plot(x, y, y_error; title="", xlabel="", ylabel="", label="")

带误差棒的图表
"""
function error_bars_plot(x, y, y_error;
                        title="",
                        xlabel="",
                        ylabel="",
                        label="Data")

    p = scatter(x, y,
        yerror=y_error,
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
        label=label,
        color=:red,
        markersize=5,
        markerstrokecolor=:black,
        alpha=0.8)

    return p
end

"""
    save_publication_plot(p, filename; format="png", dpi=300)

保存出版物质量的图表
"""
function save_publication_plot(p, filename; format="png", dpi=300)

    # 创建输出目录
    output_dir = "plots"
    if !isdir(output_dir)
        mkpath(output_dir)
    end

    filepath = joinpath(output_dir, "$filename.$format")

    savefig(p, filepath)
    println("📈 图表已保存: $filepath")

    return filepath
end

"""
    create_style_template()

创建样式模板
"""
function create_style_template()
    # 学术风格
    academic_style = (
        fontfamily="serif",
        guidefont=12,
        tickfont=10,
        legendfont=10,
        titlefont=14,
        linewidth=2,
        size=(800, 600),
        dpi=300
    )

    # 演示风格
    presentation_style = (
        fontfamily="sans-serif",
        guidefont=14,
        tickfont=12,
        legendfont=12,
        titlefont=18,
        linewidth=3,
        size=(1200, 800),
        dpi=150
    )

    # 快速草图风格
    sketch_style = (
        guidefont=10,
        tickfont=8,
        legendfont=8,
        titlefont=12,
        linewidth=1.5,
        size=(600, 400),
        dpi=100
    )

    return (
        academic=academic_style,
        presentation=presentation_style,
        sketch=sketch_style
    )
end

"""
    apply_plot_style(p, style_name)

应用预设样式
"""
function apply_plot_style(p, style_name)
    styles = create_style_template()

    if haskey(styles, style_name)
        style = styles[style_name]

        # 应用样式
        for (key, value) in pairs(style)
            if key != :size && key != :dpi
                p = plot(p, key => value)
            end
        end

        return p
    else
        println("⚠️  未知的样式: $style_name")
        return p
    end
end

# 演示函数
"""
    plot_demo()

展示所有可用的绘图模板
"""
function plot_demo()
    println("🎨 创建演示图表...")

    # 生成示例数据
    x = 1:10
    y1 = rand(10)
    y2 = rand(10) .+ 2
    y3 = randn(100)

    # 创建不同类型的图表
    p1 = line_plot(x, y1, title="线图示例", xlabel="X轴", ylabel="Y轴")
    p2 = scatter_plot(x, y2, title="散点图示例", xlabel="X轴", ylabel="Y轴")
    p3 = histogram_plot(y3, title="直方图示例", xlabel="值", ylabel="频率")

    # 多线图
    y_data_list = [rand(10), rand(10) .+ 1, rand(10) .+ 2]
    labels = ["数据1", "数据2", "数据3"]
    p4 = multi_line_plot(x, y_data_list, labels, title="多线图示例")

    # 组合图表
    combined_plot = subplot_grid(p1, p2, p3, p4, nrows=2, ncols=2, title="绘图模板演示")

    # 保存演示图表
    save_publication_plot(combined_plot, "plot_demo")

    println("✅ 演示图表创建完成!")
    return combined_plot
end

println("🎨 可视化模板已加载")
println("💡 可用函数:")
println("   line_plot() - 线图")
println("   scatter_plot() - 散点图")
println("   histogram_plot() - 直方图")
println("   box_plot() - 箱线图")
println("   heatmap_plot() - 热图")
println("   correlation_plot() - 相关性图")
println("   multi_line_plot() - 多线图")
println("   subplot_grid() - 子图网格")
println("   scientific_plot() - 科学出版风格")
println("   save_publication_plot() - 保存高质量图表")
println("   plot_demo() - 运行演示")