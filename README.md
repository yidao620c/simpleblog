## 基于Django1.9.5开发一个简单的博客系统

### 三个分支：

* master： 主分支
* py27：   基于python2.7.8版本的分支
* py34：   基于python3.4.2版本的分支

------------------------------------------
### 教程目录：

* [使用Django1.9开发博客（1） - 入门篇](https://www.xncoding.com/2015/08/01/simpleblog-01.html)
* [使用Django1.9开发博客（2） - 模型](https://www.xncoding.com/2015/08/03/simpleblog-02.html)
* [使用Django1.9开发博客（3） - 部署](https://www.xncoding.com/2015/08/06/simpleblog-03.html)
* [使用Django1.9开发博客（4） - 三部曲](https://www.xncoding.com/2015/08/09/simpleblog-04.html)
* [使用Django1.9开发博客（5） - 页面美化](https://www.xncoding.com/2015/08/12/simpleblog-05.html)
* [使用Django1.9开发博客（6） - 模板继承](https://www.xncoding.com/2015/08/15/simpleblog-06.html)
* [使用Django1.9开发博客（7） - 实现功能](https://www.xncoding.com/2015/08/16/simpleblog-07.html)
* [使用Django1.9开发博客（8） - 继续完善](https://www.xncoding.com/2015/08/18/simpleblog-08.html)
* [使用Django1.9开发博客（9） - 用户认证](https://www.xncoding.com/2015/08/20/simpleblog-09.html)
* [使用Django1.9开发博客（10） - 全文搜索](https://www.xncoding.com/2015/08/21/simpleblog-10.html)
* [使用Django1.9开发博客（11）- 富文本与代码高亮](https://www.xncoding.com/2015/08/22/simpleblog-11.html)
* [使用Django1.9开发博客（12）- I18n国际化](https://www.xncoding.com/2015/08/24/simpleblog-12.html)
* [使用Django1.9开发博客（13）- Redis缓存](https://www.xncoding.com/2015/08/25/simpleblog-13.html)
* [使用Django1.9开发博客（14）- 集成Xadmin](https://www.xncoding.com/2015/08/26/simpleblog-14.html)

------------------------------------------

通过上面的教程，相信你已经搭建了一个具有基本功能的博客。最近在此基础之上又持续不断的改进，目前发布了1.0版本。
具体新增功能如下：

1. 页面美化，加入了自定义样式和最新bootstrap
2. 文章评论功能，并且显示每篇文章的评论数
3. 文章标签，侧边栏会显示标签云，具体还有一个实现标签云的算法
4. 分类目录，最新文章，评论列表的显示
5. 文章归档功能，按照月份归档
6. 实现热门文章功能，根据点击率来排名
7. 文章的分页显示，每页大小可后台设置
8. 给文章评分，顶和踩
9. 全文搜索功能
10. 引入富文本编辑器，让格式更漂亮，并支持代码高亮等功能
11. 全面集成redis缓存系统，提升系统速度
12. i18n国际化
13. 集成xadmin的后台管理系统，管理员维护博客。

未来版本：

1. 全面美化页面，我得找个好看点的模板
2. 性能继续改进
3. 将Django自带的ORM替换成SQLAlchemy
4. 所有功能基于python3，那么需要替换xadmin管理后台
5. 软件支持和文档的完善等

一个人毕竟精力有限，期待在GitHub上面找到合作者共同完善这个系统。可以fork这个工程然后提交Pull Requests。

------------------------------------------
## 演示地址(用户名/密码：admin/admin)
https://yidao620.pythonanywhere.com/
------------------------------------------

首页效果：
![最新效果图1](http://yidaospace.qiniudn.com/simple001.jpg "最新效果图1")

顶踩功能展示：
![最新效果图2](http://yidaospace.qiniudn.com/simple002.jpg "最新效果图2")

分页效果：
![最新效果图3](http://yidaospace.qiniudn.com/simple003.jpg "最新效果图3")

富文本编辑器：
![最新效果图4](http://yidaospace.qiniudn.com/simple004.jpg "最新效果图4")

-----------------------------------------------------
## How to Contribute

You are welcome to contribute to simpleblog as follow

* add/edit wiki
* report/fix issue
* code review
* commit new feature
* add testcase

Meanwhile you'd better follow the rules below

* It's *NOT* recommended to submit a pull request directly to `master` branch. `develop` branch is more appropriate
* Follow common Python coding conventions
* Add the following [license](#license) in each source file

## License

(The Apache License)

Copyright (c) 2013-2016 [Xiong Neng](https://www.xncoding.com/) and other contributors

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
