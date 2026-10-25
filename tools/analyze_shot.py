# -*- coding: utf-8 -*-
"""分析模拟器截图的区域主色，判断 UI 是否正常渲染。"""
import collections
import sys
from PIL import Image

path = sys.argv[1]
im = Image.open(path).convert('RGB')
w, h = im.size
print('size:', im.size)


def dom(box):
    c = im.crop(box).resize((48, 48))
    cnt = collections.Counter(c.getdata())
    return cnt.most_common(3)


print('top      :', dom((0, 0, w, 180)))
print('mid      :', dom((0, h // 3, w, h // 3 + 200)))
print('bottom   :', dom((0, h - 300, w, h - 60)))
print('corner   :', dom((w - 120, 120, w, 240)))
# 深色像素占比（黑屏检测）
gray = im.convert('L')
dark = sum(1 for p in gray.resize((100, 100)).getdata() if p < 24)
print('dark%%   : %.1f' % (dark / 10000 * 100))
