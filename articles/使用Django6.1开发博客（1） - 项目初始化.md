---

title: 使用Django6.1开发博客（1） - 项目初始化

slug: django61-blog-01-init

date: 2026-09-25 17:30:00 +0800

toc: true

categories: [ python ]

tags: [ Django, Django6.1, Python, uv ]

draft: false

---

背景是这样子的，大概十年前我写了一个使用Django开发博客系列教程，那时候的Django版本还是1.9。十年弹指一挥就过去了，人生又有多少个十年呢？

这次我将使用最新版本 Django 6.1 从零开始重新来开发这个博客，通过循序渐进的方式一步步的构建这个博客系统，一个功能一个功能的往上加。从构建整个博客的过程中来学习Django6.1的使用方式，以及最新的Python WEB开发技术。


第一篇只做一件事，把项目骨架立起来，让后面每一篇都有一个能跑、能测、能继续往前加功能的位置。

![](https://static.xiongneng.me/django-project-architecture-20260925165729.png)

Django 6.1 于 2026 年 8 月 5 日发布，官方 release notes 写明它支持 Python 3.12、3.13 和 3.14。这个系列使用 Python 3.14，依赖管理用 uv。开发数据库先用 SQLite，等到了真正需要换 PostgreSQL 或 MySQL 的阶段再讨论，第一阶段不提前引入额外服务。

## 先把工具链定下来

很多人建 Django 项目还停留在两条命令的老习惯里。先用 `python -m venv .venv` 建虚拟环境，再 `pip install django`，最后把 `pip freeze` 的结果塞进 `requirements.txt`。这样做当然能跑，问题出在时间上。三个月后另一个同事拿到仓库，看到的只有一堆包名和版本号，Python 解释器应该用哪个、依赖锁在哪里生成、哪些是直接依赖、哪些是传递依赖，都要靠猜。

uv 把这几件事收拢到 `pyproject.toml` 和 `uv.lock` 里。`pyproject.toml` 记录项目直接依赖，`uv.lock` 记录完整解析结果，虚拟环境由 uv 创建和维护。Windows 上我用的 Python 是 3.14.3，uv 版本是 0.11.7。命令执行结果如下。

```bash
uv --version
python --version
```

```text
uv 0.11.7 (9d177269e 2026-04-15 x86_64-pc-windows-msvc)
Python 3.14.3
```

源码统一放在仓库的 `source` 目录里，和 `articles` 平级。先建这个目录，进去以后执行 `uv init --bare`。`--bare` 的意思是只生成项目描述文件，不让 uv 顺手创建示例代码和 README。这里我保留了仓库里已有的说明文件，所以生成的 `pyproject.toml` 只需要补上依赖。

```bash
mkdir source
cd source
uv init --bare
```

生成的 `pyproject.toml` 很短。

```toml
[project]
name = "nengx-simple-blog"
version = "0.1.0"
requires-python = ">=3.14"
dependencies = [
    "Django==6.1",
]
```

这里把 Django 固定到 `6.1`。教程系列最重要的要求是读者按命令执行时结果稳定。如果只写 `Django>=6.1`，下一个小版本发布后，模板或后台的某个细节变化就可能让第二篇和第一篇的截图对不上。

接着安装依赖。

```bash
uv add 'Django==6.1'
```

uv 会创建 `.venv`，解析依赖，写入 `uv.lock`。本阶段实际安装的包如下。

```text
 + asgiref==3.12.1
 + django==6.1
 + sqlparse==0.6.0
 + tzdata==2026.4
```

`asgiref` 支持 Django 的异步能力，`sqlparse` 被 Django 用于 SQL 相关处理，`tzdata` 给 Windows 和缺少系统时区数据的环境提供时区信息。这几个都是 Django 的直接或间接依赖，不需要手动逐个安装。

安装完成后查看 `uv.lock`，会看到完整版本、来源和哈希信息。它比 `requirements.txt` 更适合作为锁文件，因为 uv 会保证后续 `uv sync` 得到同一套解析结果。以后检查依赖变化时，不要只看 `pyproject.toml` 的几行 diff，还要看 `uv.lock` 的 diff。一个看起来很小的依赖声明变化，可能带来一串传递依赖升级。

## 生成物不该进入 Git

依赖装好以后，`source` 目录里多了 `.venv` 和 `.uv-cache`。它们对本机开发有用，对版本控制没有意义。`.venv` 里的文件带绝对路径，换一台机器就不能直接使用。`.uv-cache` 是 uv 的缓存，能加速安装，却会让仓库膨胀。后面运行开发服务器时还会出现 `db.sqlite3` 和 `__pycache__`，同样属于可再生成的内容。

所以在第一次功能提交前，先把 `.gitignore` 定下来。

```gitignore
.uv-cache/
.uv-python/
.venv/
venv/
db.sqlite3
__pycache__/
*.py[cod]
.env
.env.*
```

这份忽略规则只覆盖当前阶段已经遇到的东西。`db.sqlite3` 现在还没有生成，先写进去是为了避免第一次执行迁移后误提交本地数据。等到后面接入 PostgreSQL 或阿里云 OSS，再补充对应的密钥文件和日志规则。

有人喜欢一开始就写一份很长的 `.gitignore`，把几十种编辑器和操作系统的临时文件都排掉。我不这么做。忽略规则应该跟着项目实际使用的工具走。多了以后没人敢删，少了马上会看到具体问题，补一条也有明确理由。

这个阶段的仓库还需要保留任务说明、参考文章和辅助脚本，所以 Git 基线里包含这些资料。项目代码从第二个提交开始单独推进，每个阶段都有清晰 diff。

## 创建项目时别把目录套歪

依赖装好后创建 Django 项目。

```bash
uv run django-admin startproject config .
```

这条命令里有三个细节值得停下来看。

第一，`uv run` 会确认虚拟环境里的依赖已经和 `uv.lock` 一致，然后在项目环境里执行命令。不要绕开它直接调用系统 Python，否则很容易又回到「我这里能跑」的状态。

第二，我把项目包命名为 `config`，没有沿用默认的 `mysite`。这个项目就是一个博客，但配置和业务代码应该分开。以后 `config` 放设置、根路由、ASGI 和 WSGI，博客自己的模型、视图、模板放进 `blog` 应用。现在只有一个空配置项目，这个边界先划出来，后面会轻松很多。

第三，命令末尾的 `.` 很关键。没有它，`startproject` 会在当前目录再套一层 `config/config/manage.py`。加上 `.`，`manage.py` 直接落在 `source` 目录根部，目录更清爽。

创建完成后，`source` 目录是这样。

```text
.
├── config/
│   ├── __init__.py
│   ├── asgi.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── manage.py
├── pyproject.toml
└── uv.lock
```

`manage.py` 不是应用代码，它是项目命令入口。`config/settings.py` 保存配置，`config/urls.py` 是根路由，`asgi.py` 和 `wsgi.py` 分别对应异步和同步部署入口。第一阶段不需要改这两个入口文件，保留默认就够了。

`config` 这个名字只是我给教程选定的约定，Django 对它没有特殊要求。真正起作用的是 `manage.py` 里的 `DJANGO_SETTINGS_MODULE`，它指向 `config.settings`。也就是说，Python 导入路径必须和目录名一致，名字本身可以换。改成 `core`、`project` 或 `blog_config` 都可以，但一旦定了就应该在整个仓库里保持一致。

`asgi.py` 和 `wsgi.py` 也可以从另一个角度看。它们是部署服务器和 Django 应用之间的协议入口。开发阶段用 `runserver` 时感觉不到它们，因为 `runserver` 帮我们做了这层工作。等进入部署篇，再把它们交给 Uvicorn、Gunicorn、Daphne 或 Nginx 后面的应用服务器处理。现在保留默认，能减少很多无关变量。

根目录还有一个 `README.md`。我把它当作新读者进入仓库的第一扇门，只写三件事。当前项目做什么，这个阶段怎么装依赖，怎么验证。项目初期不需要一份几十屏的文档，能让人少问一句「接下来敲什么」就够。

```text
## 阶段 01，项目初始化

本阶段已经完成 Python 3.14、Django 6.1 和 uv 的项目骨架搭建，并通过 `manage.py check` 与基础测试。

uv sync
uv run manage.py check
uv run manage.py test
```

README 里没有写虚拟环境激活命令，因为 `uv sync` 和 `uv run` 已经覆盖了日常路径。读者不需要知道 `.venv` 在哪里，也不需要在每个命令前手动激活环境。只有当某个工具必须读取虚拟环境变量时，才需要绕过 `uv run` 去研究激活方式。

## 配置只改必须改的

`startproject` 生成的配置已经能跑，我不建议第一篇就把它改成复杂的多环境配置。先做两件事，把语言和时区调到这个项目的实际值。

```python
LANGUAGE_CODE = 'zh-hans'
TIME_ZONE = 'Asia/Shanghai'
USE_I18N = True
USE_TZ = True
```

`LANGUAGE_CODE` 影响后台和表单错误信息的默认语言，`TIME_ZONE` 表示展示时间使用的时区，`USE_TZ = True` 让数据库里的时间使用 UTC 保存。博客会按月份归档，也有评论时间，这里从第一阶段就统一时区，后面不会突然遇到一批差八小时的数据。

数据库配置暂时保留默认值。

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

SQLite 是文件数据库，不需要先启动服务，很适合教程的第一阶段。Django 的模型层、迁移、事务约束、查询 API 都能正常练习。等后面需要 PostgreSQL 的 JSON 查询、并发写入或生产部署特性时，再换数据库，并且把那次变化单独写成一篇。

Django 6.1 的 `startproject` 还生成了 `MAILERS` 配置。这是 6.1 引入的新能力，用来配置多个邮件后端。第一阶段没有邮件需求，我不动它，也不为以后的邮件通知提前写配置。这个系列尽量让每一行代码都能和当前功能对应上。

## 第一次把项目跑起来

配置检查通过后，先执行迁移。这个阶段还没有博客文章模型，但 Django 自带的 admin、auth、contenttypes 和 sessions 已经带了一套内置迁移。执行下面这条命令，把这些基础表建到 SQLite 里。

```bash
uv run manage.py migrate
```

输出会比文章里看到的更长，下面只保留开头和几个关键行。

```text
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, sessions
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying sessions.0001_initial... OK
```

这些表现在看起来和博客没有直接关系。以后创建超级用户要用 `auth`，后台记录操作日志要用 `admin`，登录状态要靠 `sessions`。先把基础表建好，第二篇创建文章模型时，迁移文件就只包含业务变化，输出会更清楚。

如果你在自己机器上看到的迁移列表比这里长，也不必紧张。Django 小版本之间可能调整内置迁移，重点是最后没有报错，所有行都以 `OK` 结束。

接着启动开发服务器。

```bash
uv run manage.py runserver 127.0.0.1:8000
```

终端会显示 Django 版本、配置文件和监听地址。此时浏览器打开 `http://127.0.0.1:8000/`，看到的是 Django 的欢迎页。

![](https://static.xiongneng.me/django-welcome-page-20260925165729.png)

页面提示安装成功，也说还没有配置任何 URL。这正是当前状态。`config/urls.py` 还没有挂博客路由，所以 Django 只能在 `DEBUG=True` 时展示这个欢迎页。它证明 WSGI 应用已经能启动，配置能被加载，请求也能进入 Django。

开发服务器只用于本机开发，不能直接放到公网。看完页面后在终端按 `Ctrl+C` 停止。下一节继续用测试把项目骨架固定住，不依赖某个人记得打开浏览器。

## 用测试锁住项目骨架

项目刚创建时只有一个 `check` 命令能证明配置没有语法问题。这还不够。我想让仓库在一开始就回答三个问题。

1. Django 是不是 6.1？
2. 项目入口和配置文件是否存在？
3. `manage.py check` 能不能正常执行？

于是建一个 `tests` 目录，再加一个空的 `tests/__init__.py`，让 Python 把它识别成包。

```python
from importlib.metadata import version
from pathlib import Path

from django.core.management import call_command
from django.test import SimpleTestCase


class ProjectInitializationTests(SimpleTestCase):
    def test_django_version_is_61(self):
        self.assertEqual(version("django"), "6.1")

    def test_python_and_base_settings(self):
        self.assertEqual(Path("pyproject.toml").exists(), True)
        self.assertEqual(Path("manage.py").exists(), True)
        self.assertIn(
            "config",
            __import__("config.settings", fromlist=["ROOT_URLCONF"]).ROOT_URLCONF,
        )

    def test_manage_check_runs_without_warnings(self):
        self.assertIsNone(call_command("check"))
```

第一条测试读取已安装包的 metadata，确认 Django 正是 `6.1`。第二条检查 `pyproject.toml`、`manage.py` 和 `ROOT_URLCONF`。第三条直接调用 `call_command("check")`，让系统检查进入测试流程。

这几条测试看起来简单，但它们守住的是项目骨架。以后如果有人误删 `pyproject.toml`，误改根路由配置，或者升级 Django 后没有同步教程，`uv run manage.py test` 会先失败。简单测试挡住低级事故，比在文档里写一句「请小心」有用得多。

这里用的是 `SimpleTestCase`，因为它不访问数据库。`call_command` 是 Django 提供的程序化调用管理命令的接口，比在测试里再启动一个 Python 子进程轻很多。部署检查、迁移检查这类命令以后会在 CI 或发布脚本里执行，不需要塞进每一个单元测试。

我选择顶层 `tests/` 目录，没有沿用 `startapp` 生成的 `tests.py`。项目刚初始化时还没有业务应用，这三条测试属于整个仓库的骨架约束。等第二篇创建 `blog` 应用后，和文章模型强相关的测试会放到 `blog/tests/` 下，项目级测试继续留在 `tests/test_project.py`。测试文件跟着被测对象走，读失败报告时更容易定位。

很多人觉得这种骨架测试没有技术含量。可项目最难维护的阶段往往出现在三个月后。依赖升级、目录移动、配置重命名、误删入口文件，这些变化都很少在代码 review 里被发现。有这三条测试在，`git bisect` 至少能准确回答一个二选一的问题。这个仓库从第一步开始坏没坏。

这里的测试没有覆盖浏览器页面。欢迎页由 Django 框架提供，不属于这个仓库的业务逻辑。如果为它写测试，只能测到 Django 自己的行为，收益很低。等第二篇有了博客自己的视图和模板，再写 `TestCase` 和测试客户端，让请求真正穿过 URL、视图和模板渲染。

现在依次运行验证命令。

```bash
uv lock --check
uv run manage.py check
uv run manage.py makemigrations --check --dry-run
uv run manage.py test -v 2
```

本阶段实际输出如下。

```text
Resolved 5 packages in 1ms
System check identified no issues (0 silenced).
No changes detected
test_django_version_is_61 (tests.test_project.ProjectInitializationTests.test_django_version_is_61) ... ok
test_python_and_base_settings (tests.test_project.ProjectInitializationTests.test_python_and_base_settings) ... ok
test_manage_check_runs_without_warnings (tests.test_project.ProjectInitializationTests.test_manage_check_runs_without_warnings) ... ok

----------------------------------------------------------------------
Ran 3 tests in 0.006s

OK
```

`uv lock --check` 确认锁文件和 `pyproject.toml` 一致。`manage.py check` 检查配置、模型和应用注册这类基础问题。`makemigrations --check --dry-run` 用来发现「模型已经改了但没有生成迁移」的情况。第一阶段还没有业务模型，它输出 `No changes detected` 是正常的。以后每加一个模型，这条命令会变得很有价值。

## 为什么不急着写第一页

很多入门教程会在创建项目后马上改 `urls.py`，加一个 `HttpResponse`，让浏览器看到 Hello World。这一步当然能带来一点成就感，但第一篇如果只做这个，后面的模型、模板、视图会一下子挤进第二篇。

我把项目初始化单独拆开，是因为它决定了后面所有的动作方式。读者先知道依赖从哪里来、命令从哪里执行、测试怎么跑，后面每加一个功能都能重复同一套流程。第二篇开始建博客模型时，重点就可以放在字段设计、迁移和 Admin 上，不需要再解释虚拟环境和锁文件。

现在仓库还没有业务功能，但已经具备三个条件。

1. 用 Python 3.14 和 Django 6.1 建立了明确的运行时。
2. 用 uv 锁住了依赖。
3. 用三条测试把项目骨架固定住。

这已经是一个可以提交的阶段。Git 提交信息如下。

```text
feat(blog): 01 项目初始化

- 初始化 Django 6.1 项目
- 配置 uv 和基础测试
- 添加阶段教程
```

提交前我习惯先看一眼状态，再让 Git 检查一次空白错误。

```bash
git status --short
git diff --check
git add .
git diff --staged --check
git commit -m 'feat(blog): 01 项目初始化'
```

`git status --short` 用来确认哪些文件会进入提交。这一步能拦住两类问题。一类是本地数据库、虚拟环境或缓存被意外加进来，另一类是真正的新文件没有被跟踪。`git diff --check` 会报告行尾空白和冲突标记，这类小噪声不适合留在教程仓库里。

文章和代码放在同一个提交里，是这个系列的规则。读者看到某一篇时，应该能通过对应提交回到当时的源码状态。没有源码的文章容易漂移，没有说明的代码也不利于回看。

克隆这个仓库后，只需要三条命令就能验证当前阶段。

```bash
cd source
uv sync
uv run manage.py check
uv run manage.py test
```

仓库现在有边界、有版本、有测试，也给后面的功能留出了生长位置。

最后补一句版本策略。Django 6.1 的官方 release notes 给出了主流支持和扩展支持时间。教程锁定小版本能保证命令稳定，实际产品则应该跟踪安全更新，在测试通过后升级到同一个主系列的最新补丁版。这两件事并不冲突。教程追求可复现，产品追求长期可维护。

官方页面写明 Django 6.1 于 2026 年 8 月 5 日发布，主流支持预计到 2027 年 4 月，扩展支持预计到 2027 年 12 月。对这个教程来说，6.1 是当前主线版本；对一个上线中的博客来说，这些时间点是升级计划的输入。等到 Django 发布下一个版本，先看 release notes，再读不兼容变化，最后跑这个仓库的测试。测试先绿，再考虑合并。
