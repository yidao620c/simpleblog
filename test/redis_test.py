#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: redis test
Desc : 
"""
import redis
import sys
import platform

if __name__ == '__main__':
    print(sys.version)
    print(platform.python_version())

    r = redis.StrictRedis(host='192.168.203.95', port=6379, db=0)
    r2 = redis.StrictRedis(host='192.168.203.95', port=6379, db=0)

    print(">>>>>>>>>>TEST REDIS LIST>>>>>>>>>>")
    r.lpush("list1", 3)
    r.lpush("list1", 2)
    r.lpush("list1", 1)
    r.rpush("list1", 4)
    r2.rpush("list1", 5)
    print(r.lrange("list1", 0, -1))
    print(r.llen("list1"))
    r.ltrim("list1", 0, 2)
    print(r.lrange("list1", 0, -1))
    print(r.lindex("list1", 1))
    print('TEST %s END' % (r.type("list1")))
    r.delete("list1")

    print(">>>>>>>>>>TEST REDIS STRING>>>>>>>>>>")
    r.set("str1", '1234567890')
    print(r2.get("str1"))
    print('TEST %s END' % (r.type("str1")))
    r.delete("str1")

    print(">>>>>>>>>>TEST REDIS SET>>>>>>>>>>")
    r.sadd("set1", "222")
    r.sadd("set1", "111")
    r.sadd("set1", "333")
    print(r.scard("set1"))
    print(r.smembers("set1"))
    r2.sadd("set2", "444")
    r2.sadd("set2", "333")
    r2.sadd("set2", "555")
    print(r.sunion("set1", "set2"))
    print(r.sinter("set1", "set2"))
    print('TEST %s END' % (r.type("set1")))
    r.delete("set1")
    r.delete("set2")

    print(">>>>>>>>>>TEST REDIS ZSET>>>>>>>>>>")
    r.zadd("sort1", -2, "222")
    r.zadd("sort1", -1, "111")
    r.zadd("sort1", -3, "333")
    r.zincrby('sort1', '111', 4)
    print(r.zrange("sort1", 0, -1))
    print(r.zrangebyscore("sort1", 2, 3))
    print(r.zrangebyscore("sort1", 2, -1))
    print('TEST %s END' % (r.type("sort1")))
    r.delete("sort1")

    print(">>>>>>>>>>TEST REDIS HASH TABLE>>>>>>>>>>")
    r.hset("hash1", "key1", 1)
    r.hset("hash1", "key2", 2)
    r.hset("hash1", "key3", 3)
    r.hincrby('hash1', 'key3')
    print(r.hget("hash1", "key2"))
    print(r.hkeys("hash1"))
    print(r.hexists("hash1", "key4"))
    r.hdel("hash1", "key2")
    print(r.hget("hash1", "key2"))
    print(r.hkeys("hash1"))
    print('TEST %s END' % (r.type("hash1")))
    r.delete("hash1")

    print(r.keys())
