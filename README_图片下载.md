# 图片下载脚本使用说明

## 功能说明

这个脚本用于下载 `Question.bundle` 目录中所有JSON文件里的 `tigan_pic` 和 `explanation_pic` 图片。

## 脚本特点

- ✅ 自动遍历 Question.bundle 中的所有 JSON 文件（235个）
- ✅ 提取 tigan_pic 和 explanation_pic 字段
- ✅ 根据 courseId 构建完整的图片URL
- ✅ 按课程分类保存图片（course_3、course_4等）
- ✅ 避免重复下载（自动跳过已存在的图片）
- ✅ 实时显示下载进度
- ✅ 下载失败自动记录
- ✅ 完整的统计报告

## URL构建逻辑

脚本使用与Swift代码相同的URL拼接逻辑：
```
基础URL: https://mp-1af92f1c-94c6-441d-86c3-3a0c66fb0618.cdn.bspapp.com/tiku
完整URL: {baseUrl}/{courseId}/{图片文件名}
```

例如：
- course_id = 3，tigan_pic = "itpm1_202305_1_67.jpg"
- 完整URL: `https://mp-1af92f1c-94c6-441d-86c3-3a0c66fb0618.cdn.bspapp.com/tiku/3/itpm1_202305_1_67.jpg`

## 使用方法

### 1. 安装 Node.js

确保已安装 Node.js（建议 v14 或更高版本）：
```bash
node --version
```

### 2. 运行脚本

在项目目录下执行：
```bash
cd /Users/fandong/XcodeProject/RuanKao
node download_images.js
```

### 3. 查看下载结果

图片会保存在 `downloaded_images` 目录下，按课程分类：
```
downloaded_images/
├── course_3/          # 高项题目图片
│   ├── itpm1_202305_1_67.jpg
│   └── ...
├── course_4/          # 中项题目图片
│   ├── itpm2_202205_2_2.jpg
│   └── ...
└── ...
```

## 输出示例

```
============================================================
开始下载Question.bundle中的图片
============================================================

正在扫描JSON文件...
找到 235 个JSON文件

正在提取图片信息...
已处理 50/235 个文件
已处理 100/235 个文件
已处理 150/235 个文件
已处理 200/235 个文件
共找到 XXX 张图片

开始下载图片...

处理课程: course_3 (XXX 张图片)
------------------------------------------------------------
[1/XXX] tigan_pic: itpm1_202305_1_67.jpg
✓ 下载成功: itpm1_202305_1_67.jpg
[2/XXX] explanation_pic: itpm1_202305_1_66_1.jpg
✓ 下载成功: itpm1_202305_1_66_1.jpg
...

============================================================
下载完成！统计信息:
============================================================
JSON文件总数: 235
图片总数: XXX
成功下载: XXX
跳过(已存在): 0
下载失败: 0

图片保存位置: /Users/fandong/XcodeProject/RuanKao/downloaded_images
============================================================
```

## 注意事项

1. **网络连接**：需要稳定的网络连接才能下载图片
2. **磁盘空间**：确保有足够的磁盘空间存储图片
3. **中断恢复**：如果下载中断，再次运行脚本会自动跳过已下载的图片
4. **下载速度**：脚本已添加100ms延迟，避免请求过快被服务器拒绝

## 故障排除

### 下载失败
如果某些图片下载失败，脚本会在统计信息中显示失败数量。可以：
1. 检查网络连接
2. 再次运行脚本（会跳过已下载的图片）
3. 查看控制台输出的错误信息

### 文件不存在
如果提示找不到 Question.bundle 目录，请检查：
1. 脚本是否在正确的目录下运行
2. Question.bundle 目录路径是否正确

## 脚本文件

- **脚本位置**: `/Users/fandong/XcodeProject/RuanKao/download_images.js`
- **输出目录**: `/Users/fandong/XcodeProject/RuanKao/downloaded_images/`
