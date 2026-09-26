# 使用 Django 6.1 开发一个博客系统

使用 Django 6.1 和 uv 构建的博客系列教程。源码在 `source/` 目录，文章在 `articles/` 目录。代码按阶段推进，每篇教程对应一个可运行版本。

## 教程目录

- [使用Django6.1开发博客（1） - 项目初始化](articles/使用Django6.1开发博客（1）%20-%20项目初始化.md)
- [使用Django6.1开发博客（2） - 模型与后台](articles/使用Django6.1开发博客（2）%20-%20模型与后台.md)
- [使用Django6.1开发博客（3） - 页面与详情](articles/使用Django6.1开发博客（3）%20-%20页面与详情.md)
- [使用Django6.1开发博客（4） - Markdown与代码高亮](articles/使用Django6.1开发博客（4）%20-%20Markdown与代码高亮.md)
- [使用Django6.1开发博客（5） - 分类标签与归档](articles/使用Django6.1开发博客（5）%20-%20分类标签与归档.md)
- [使用Django6.1开发博客（6） - 评论与互动](articles/使用Django6.1开发博客（6）%20-%20评论与互动.md)
- [使用Django6.1开发博客（7） - 分页与站点设置](articles/使用Django6.1开发博客（7）%20-%20分页与站点设置.md)
- [使用Django6.1开发博客（8） - 后台统计](articles/使用Django6.1开发博客（8）%20-%20后台统计.md)
- [使用Django6.1开发博客（9） - 全文搜索](articles/使用Django6.1开发博客（9）%20-%20全文搜索.md)
- [使用Django6.1开发博客（10） - 用户认证](articles/使用Django6.1开发博客（10）%20-%20用户认证.md)
- [使用Django6.1开发博客（11） - 图片上传与OSS](articles/使用Django6.1开发博客（11）%20-%20图片上传与OSS.md)
- [使用Django6.1开发博客（12） - Redis缓存](articles/使用Django6.1开发博客（12）%20-%20Redis缓存.md)
- [使用Django6.1开发博客（13） - I18n国际化](articles/使用Django6.1开发博客（13）%20-%20I18n国际化.md)
- [使用Django6.1开发博客（14） - 部署与收尾](articles/使用Django6.1开发博客（14）%20-%20部署与收尾.md)

## 环境准备

| 工具 | 版本 / 说明 |
|---|---|
| Python | 3.14 |
| Django | 6.1 |
| uv | 建议使用最新版 |
| Redis | 阶段 12 起使用，本地默认 `127.0.0.1:6379` |
| 阿里云 OSS | 阶段 11 起使用，需准备 Bucket 和 AccessKey |

克隆仓库后进入源码目录：

```bash
cd source
uv sync
```

复制环境变量模板：

```bash
cp .env.example .env
```

Windows PowerShell 可用 `Copy-Item .env.example .env`。之后执行 Django 命令时，让 uv 读取该文件：

```bash
uv run --env-file .env manage.py <command>
```

生产环境不要使用模板中的开发默认值。至少要覆盖 `DJANGO_DEBUG`、`DJANGO_SECRET_KEY`、`DJANGO_ALLOWED_HOSTS`、`DJANGO_CSRF_TRUSTED_ORIGINS` 和 `DJANGO_SECURE_SSL_REDIRECT`。

通用验证命令：

```bash
uv run --env-file .env manage.py check
uv run --env-file .env manage.py makemigrations --check --dry-run
uv run --env-file .env manage.py test
```

## Django Admin 测试账号

本地演示数据库中的后台测试账号如下：

```text
用户名：admin
密码：blog-admin-2026
```

该账号只用于本机测试，不要用于生产环境。

如果本地数据库中不存在这个账号，或需要重置密码，在 `source/` 目录执行：

```bash
uv run --env-file .env manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); user, created = User.objects.get_or_create(username='admin', defaults={'email': 'admin@example.com', 'is_staff': True, 'is_superuser': True}); user.is_staff = True; user.is_superuser = True; user.set_password('blog-admin-2026'); user.save()"
```

然后打开：

```text
http://127.0.0.1:8000/admin/
```

## 每个阶段的准备与验证

### 阶段 01：项目初始化

**功能**

- 初始化 `source/` 下的 Django 项目。
- 固定 Python 3.14 和 Django 6.1。
- 加入项目级测试骨架。

**准备**

```bash
cd source
uv sync
```

**验证**

```bash
uv run manage.py check
uv run manage.py test tests.test_project
```

预期结果：

```text
System check identified no issues
OK
```

### 阶段 02：模型与后台

**功能**

- 新增 `blog` 应用。
- 定义 `Post`、`Category`、`Tag`。
- 注册 Django Admin。
- 增加 `PublishedManager`、文章状态和发布时间规则。

**准备**

创建数据库表和后台账号：

```bash
uv run --env-file .env manage.py makemigrations blog
uv run --env-file .env manage.py migrate
uv run --env-file .env manage.py createsuperuser
```

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_models
uv run --env-file .env manage.py test blog.tests.test_admin
uv run --env-file .env manage.py runserver
```

打开：

```text
http://127.0.0.1:8000/admin/
```

检查 `分类`、`标签`、`文章` 可以新增、修改、搜索和筛选。

### 阶段 03：页面与详情

**功能**

- 增加文章列表页。
- 增加文章详情页。
- 只展示已发布文章。
- 详情页浏览量递增。

**准备**

在 Admin 中至少发布一篇 `Post`。

**验证**

```bash
uv run --env-file .env manage.py runserver
```

打开：

```text
http://127.0.0.1:8000/
http://127.0.0.1:8000/post/1/
```

检查：

- 列表只出现已发布文章。
- 详情页能显示标题、分类、正文和浏览量。
- 直接访问草稿详情返回 404。

相关测试：

```bash
uv run --env-file .env manage.py test blog.tests.test_views
```

### 阶段 04：Markdown 与代码高亮

**功能**

- 正文按 Markdown 渲染。
- 支持 fenced code、表格、标题。
- 使用 Pygments 高亮代码。

**准备**

在 Admin 中编辑一篇 `Post`，正文包含 Markdown：

````markdown
## 标题

```python
print("hello")
```
````

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_views
uv run --env-file .env manage.py runserver
```

打开该文章详情页，确认：

- Markdown 标题变成 HTML 标题。
- 代码块有 `.codehilite` 容器。
- 代码显示高亮样式。
- 表格有边框并可以横向阅读。

### 阶段 05：分类、标签与归档

**功能**

- 分类页。
- 标签页。
- 标签云。
- 按年月归档。
- 侧边栏展示分类、最新文章、热门文章、归档和标签入口。

**准备**

在 Admin 中准备：

- 至少一个 `Category`。
- 至少一个 `Tag`。
- 至少一篇已发布文章并关联它们。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_views
uv run --env-file .env manage.py runserver
```

分别打开：

```text
http://127.0.0.1:8000/category/python/
http://127.0.0.1:8000/tag/django/
http://127.0.0.1:8000/tags/
http://127.0.0.1:8000/archive/2026/9/
```

年月按你的文章发布时间调整。检查每个页面都能命中同一篇文章，并且右侧侧边栏正常显示。

### 阶段 06：评论与互动

**功能**

- 匿名评论。
- 评论内容默认转义。
- 顶和踩。
- 同一 Session 对同一篇文章只能投票一次。
- 热门文章按浏览量排序。

**准备**

至少有一篇已发布文章。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_interactions
uv run --env-file .env manage.py runserver
```

打开文章详情页：

1. 提交昵称、邮箱和评论。
2. 确认评论显示，普通 HTML 不会被执行。
3. 点击 `顶` 或 `踩`。
4. 再次点击同一按钮，应提示已投过票。
5. 回到列表，检查侧边栏 `热门文章` 和 `最新评论`。

### 阶段 07：分页与站点设置

**功能**

- 列表、分类、标签、归档统一分页。
- 每页数量来自 `SiteSetting.page_size`。
- Django Admin 可以修改该值。

**准备**

在 Admin 中打开 `站点设置`。如果没有记录，先访问前台列表，系统会自动创建默认记录。

把 `每页文章数` 改成一个便于观察的值，例如 `2`。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_pagination
uv run --env-file .env manage.py runserver
```

打开文章列表，检查：

- 第一页只显示 `page_size` 篇。
- 出现上一页 / 下一页。
- 页码格式为 `第 1 / N 页`。
- 修改后台设置后，刷新前台列表生效。

### 阶段 08：后台统计

**功能**

在文章列表页顶部显示：

- 文章总数。
- 已发布数量。
- 草稿数量。
- 浏览总量。
- 平均浏览量。

**准备**

使用超级用户登录 Admin，并确保库中已有文章。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_admin_stats
uv run --env-file .env manage.py runserver
```

打开：

```text
http://127.0.0.1:8000/admin/blog/post/
```

文章表格上方应出现 `博客统计` 卡片，并且数字与数据库中的文章状态一致。

### 阶段 09：全文搜索

**功能**

- 首页导航提供搜索框。
- 搜索标题、摘要、正文。
- 只搜索已发布文章。
- 搜索词跟随分页链接。

**准备**

准备两篇文章：

- 一篇正文包含要搜索的关键词。
- 一篇草稿也包含同样关键词，用于确认草稿不会泄露。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_views
uv run --env-file .env manage.py runserver
```

打开：

```text
http://127.0.0.1:8000/?q=关键词
```

检查：

- 已发布的命中文章出现。
- 草稿不出现。
- 标题显示搜索词。
- 翻页链接继续携带 `q=关键词`。

### 阶段 10：用户认证

**功能**

- 注册。
- 登录。
- 登出。
- 导航根据登录状态变化。
- 注册成功后直接建立会话。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_auth
uv run --env-file .env manage.py runserver
```

打开：

```text
http://127.0.0.1:8000/account/register/
http://127.0.0.1:8000/account/login/
```

检查：

- 注册后自动登录。
- 登录后导航显示用户名。
- 登出后导航重新显示登录和注册。
- 登出请求是 POST，并且带 CSRF token。

### 阶段 11：图片上传与阿里云 OSS

**功能**

- 新增 `Attachment` 模型。
- Admin 可上传图片附件。
- 图片写入阿里云 OSS。
- 数据库只保存对象键和元数据。
- 文章详情页展示附件图片。

**准备**

复制 `.env.example` 后填写 OSS 配置：

```env
OSS_ACCESS_KEY_ID=your-key-id
OSS_ACCESS_KEY_SECRET=your-key-secret
OSS_BUCKET_NAME=your-bucket
OSS_ENDPOINT=oss-cn-shenzhen.aliyuncs.com
OSS_REGION=cn-shenzhen
```

确认 Bucket 允许应用写入，并确认前台能读取图片 URL。

执行迁移：

```bash
uv run --env-file .env manage.py migrate
```

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_attachments
uv run --env-file .env manage.py runserver
```

打开 Admin：

```text
http://127.0.0.1:8000/admin/blog/attachment/
```

上传一张小图并关联文章。然后打开文章详情页，确认图片能通过 OSS URL 正常显示。

### 阶段 12：Redis 缓存

**功能**

- 缓存侧边栏数据。
- 本地默认可用 LocMemCache。
- 配置 `REDIS_URL` 后自动切到 Redis。
- 缓存键为 `blog:sidebar:v1`，过期时间 60 秒。

**准备**

本地或远程启动 Redis。源码环境变量示例：

```env
REDIS_URL=redis://127.0.0.1:6379/0
```

如果 Redis 有密码，URL 可写成：

```env
REDIS_URL=redis://:password@127.0.0.1:6379/0
```

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_cache
uv run --env-file .env manage.py runserver
```

检查方式：

1. 打开任意列表或详情页。
2. 刷新一次，观察侧边栏正常。
3. 有条件时用 `redis-cli` 检查：

```bash
redis-cli keys "*sidebar*"
```

### 阶段 13：I18n 国际化

**功能**

- 支持 `zh-hans` 和 `en`。
- `LocaleMiddleware` 解析当前语言。
- 模板使用 `translate` / `blocktranslate`。
- 提供语言切换表单。
- 英文翻译文件位于 `source/locale/en/LC_MESSAGES/`。

**验证**

```bash
uv run --env-file .env manage.py test blog.tests.test_i18n
uv run --env-file .env manage.py runserver
```

打开任意前台页面，切换语言为 `English`，确认：

- 页面标题和导航变成英文。
- 列表分页文案变成英文。
- 空状态文案变成英文。
- `<html lang>` 变成 `en`。

如果修改了 `django.po`，需要重新编译：

```bash
uv run manage.py compilemessages
```

`compilemessages` 需要系统安装 gettext 工具。仓库中已提交编译后的 `django.mo`，不改翻译时可以直接使用。

### 阶段 14：部署与收尾

**功能**

- 生产配置由环境变量驱动。
- `DEBUG=false` 时启用 HTTPS、HSTS、Secure Cookie。
- 增加 `STATIC_ROOT`。
- 增加 `/healthz/`。
- 增加 Gunicorn 和容器配置。

**准备**

生产环境至少设置：

```env
DJANGO_DEBUG=false
DJANGO_SECRET_KEY=64位以上强随机字符串
DJANGO_ALLOWED_HOSTS=blog.example.com
DJANGO_CSRF_TRUSTED_ORIGINS=https://blog.example.com
DJANGO_SECURE_SSL_REDIRECT=true
REDIS_URL=redis://127.0.0.1:6379/0
```

OSS 五个变量也要按生产 Bucket 填写。

**部署验证**

```bash
uv run --env-file .env manage.py check
uv run --env-file .env manage.py makemigrations --check --dry-run
uv run --env-file .env manage.py migrate
uv run --env-file .env manage.py collectstatic --noinput
uv run --env-file .env manage.py test

DJANGO_DEBUG=false DJANGO_SECRET_KEY=your-production-key DJANGO_ALLOWED_HOSTS=blog.example.com uv run --env-file .env manage.py check --deploy
```

启动应用：

```bash
uv run --env-file .env gunicorn config.wsgi:application   --bind 127.0.0.1:8000   --workers 3
```

检查健康接口：

```text
http://127.0.0.1:8000/healthz/
```

预期返回：

```json
{"status": "ok"}
```

Nginx 负责 TLS、HTTP 跳转 HTTPS、服务 `source/staticfiles/` 下的静态文件，并把动态请求代理到 Gunicorn。

## 常用命令

以下命令默认在 `source/` 目录执行。

安装依赖：

```bash
uv sync
```

启动开发服务器：

```bash
uv run --env-file .env manage.py runserver
```

创建超级用户：

```bash
uv run --env-file .env manage.py createsuperuser
```

执行全部测试：

```bash
uv run --env-file .env manage.py test
```

检查迁移一致性：

```bash
uv run --env-file .env manage.py makemigrations --check --dry-run
```

收集静态文件：

```bash
uv run --env-file .env manage.py collectstatic --noinput
```

## 目录说明

```text
source/
├── blog/                 # 博客应用：模型、视图、Admin、表单、测试
├── config/               # Django 配置、根路由、WSGI/ASGI
├── locale/               # 翻译文件
├── static/               # 项目静态源文件
├── templates/            # 项目模板
├── tests/                # 项目级测试
├── .env.example          # 环境变量模板
├── Dockerfile            # 生产镜像构建文件
└── manage.py             # Django 命令入口

articles/                 # 每个阶段对应的技术文章
cloudcos/                 # 配图上传辅助脚本和历史图片
scripts/                  # 写作、配图和检查辅助脚本
```

## 许可证

Copyright (c) 2018-2026 [Xiong Neng](https://www.xiongneng.me)

基于 MIT 协议发布：<http://www.opensource.org/licenses/MIT>
