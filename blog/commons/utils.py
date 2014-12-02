#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: 帮助类
Desc : 
"""
from datetime import datetime, timedelta, time
import pytz

MIN_TAG = 8
MAX_TAG = 24



def tag_font(tags):
    """
    标签云的字体大小算法
    思路如下：最小字体为MIN_TAG，文章数每增加一个字体增加2px，但是到MAX_TAG后封顶
    """
    return [(k, v, MIN_TAG + (v - 1) * 2 if MIN_TAG + (v - 1) * 2 <= MAX_TAG else MAX_TAG)
            for k, v in tags.items()]


def seconds(dt):
    return (dt - datetime(1970, 1, 1)) / timedelta(seconds=1)


if __name__ == '__main__':
    print(tag_font({'校园': 3, 'python': 9, 'java': 1, '哈哈': 2}))
    for a,b,c in tag_font({'校园': 3, 'python': 9, 'java': 1, '哈哈': 2}):
        print(a,b,c)
    print(time(tzinfo=pytz.timezone('Asia/Shanghai')).tzname())
    print(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))