## Django1.7开发一个简单的博客系统

------------------------------------------
## 教程地址：
http://yidao620c.iteye.com/blog/2153573
------------------------------------------
通过上面的教程已经搭建了一个具有基本功能的博客
最近又持续不断的改进，争取能将整个完整功能全部加上。
具体新增功能：
1. 页面美化，加入了自定义样式和最新bootstrap
2. 文章评论功能，并且显示每篇文章的评论数
3. 文章标签，侧边栏会显示标签云，具体还有一个实现标签云的算法
4. 分类目录
5. 显示最新文章，最新评论
6. 文章归档功能，按照月份归档

未来的计划：
1. 实现热门文章功能，根据评论数或者点击率来排名
2. 给文章评分，或顶和踩
3. 集成xadmin的后台管理系统，管理员维护博客。
4. 全文搜索功能
5. 引入富文本编辑器，让格式更漂亮，并支持代码高亮等功能

在持续改进过程中，不断的总结学习django框架，QuerySet的熟练使用，模板，全局处理器，静态资源等。
后面还会引入缓存redis，因为点击率这些非常易变的应该要使用缓存。目前是直接存储数据库，速度有点慢。
总之，在实际开发过程中不断的总结才是最好的学习方法。

## 演示地址
https://yidaoblog.herokuapp.com/

![最新效果图](http://yidaospace.qiniudn.com/capture.jpg "最新效果图")

-----------------------------------------------------
## How to Contribute

You are welcome to contribute to mango-test as follow

* add/edit wiki
* report/fix issue
* code review
* commit new feature
* add testcase

Meanwhile you'd better follow the rules below

* It's *NOT* recommended to submit a pull request directly to `master` branch. `develop` branch is more appropriate
* Follow common Java coding conventions
* Put all Java class files under *com.netease* package
* Add the following [license](#license) in each Java class file

## License

(The Apache License)

Copyright (c) 2013-2014 [WinHong, Inc.](http://www.winhong.com/) and other contributors

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
