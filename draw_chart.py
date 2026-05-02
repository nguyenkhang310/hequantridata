import matplotlib.pyplot as plt
import numpy as np
import os

# Data
labels = ['Lost Update', 'Dirty Read', 'Non-Repeatable Read', 'Phantom Read', 'Deadlock']
before_optimization = [12.0, 5.0, 7.0, 3.0, 8.5]
after_optimization = [0.0, 0.0, 0.0, 0.0, 0.1]

x = np.arange(len(labels))
width = 0.35

fig, ax = plt.subplots(figsize=(10, 6))

# Plot bars
rects1 = ax.bar(x - width/2, before_optimization, width, label='Trước khi dùng Khóa (Locking)', color='#ff6b6b')
rects2 = ax.bar(x + width/2, after_optimization, width, label='Sau khi tối ưu Transaction', color='#4ecdc4')

# Add text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('Tỷ lệ lỗi phát sinh (%)', fontsize=12, fontweight='bold')
ax.set_title('BIỂU ĐỒ SO SÁNH TỶ LỆ RỦI RO DỮ LIỆU KHI ĐĂNG KÝ HỌC PHẦN ĐỒNG THỜI', fontsize=14, fontweight='bold', pad=20)
ax.set_xticks(x)
ax.set_xticklabels(labels, fontsize=10)
ax.legend(fontsize=11)

# Add values on top of bars
def autolabel(rects):
    for rect in rects:
        height = rect.get_height()
        ax.annotate(f'{height}%',
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

autolabel(rects1)
autolabel(rects2)

# Styling
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.grid(axis='y', linestyle='--', alpha=0.7)
fig.tight_layout()

# Save the plot
output_path = os.path.join('docs', 'performance_chart.png')
plt.savefig(output_path, dpi=300, bbox_inches='tight')
print(f"Chart saved to {output_path}")
