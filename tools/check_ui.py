# -*- coding: utf-8 -*-
"""验证模拟器 UI：检测主题青绿、今天圈、Dock 结构等关键特征。"""
import sys
from PIL import Image

path = sys.argv[1]
im = Image.open(path).convert('RGB')
w, h = im.size
px = im.load()

# 主题青绿近似色（#0AA69A -> RGB 10,166,154）
def is_teal(r, g, b, tol=36):
    return abs(r - 10) < tol and abs(g - 166) < tol and abs(b - 154) < tol

teal = sum(1 for y in range(0, h, 2) for x in range(0, w, 2) if is_teal(*px[x, y]))
print('teal_px   :', teal)

# 底部 340px 内的深色/彩色像素（Dock 内容检测）
dock_hits = []
for y in range(h - 340, h - 60, 2):
    for x in range(0, w, 2):
        r, g, b = px[x, y]
        if r < 200 or g < 200 or b < 200:
            dock_hits.append((x, y, r, g, b))
print('dock_px   :', len(dock_hits))
if dock_hits:
    xs = [p[0] for p in dock_hits]
    ys = [p[1] for p in dock_hits]
    print('dock x-range:', min(xs), '-', max(xs), ' y-range:', min(ys), '-', max(ys))
    # 按 x 分桶统计 Dock 栏水平分布
    buckets = {}
    for p in dock_hits:
        b = p[0] // 108
        buckets[b] = buckets.get(b, 0) + 1
    print('dock buckets (x//108):', sorted(buckets.items()))
