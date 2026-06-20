# Open Books

<p align="center">
  <strong>用 Typst 写作、排版、发布的中文开放书库。</strong>
</p>

<p align="center">
  这里收纳的是可以独立编译的完整书稿：每一本书都有自己的入口文件、排版模板、插图资产与封面设计。
  仓库的目标不是保存零散文章，而是把长期写作沉淀成可以构建、可以版本化、可以发布的书。
</p>

<p align="center">
  <a href="#书目">书目</a> ·
  <a href="#构建">构建</a> ·
  <a href="#目录结构">目录结构</a> ·
  <a href="#发布">发布</a>
</p>

<br>

<p align="center">
  <a href="chasing-carnot">
    <img src="chasing-carnot/assets/covers/book-cover.svg" alt="《追赶卡诺》封面" width="320">
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="ml-fundamentals">
    <img src="ml-fundamentals/assets/covers/book-cover.svg" alt="《追逐泛化》封面" width="320">
  </a>
</p>

## 书目

| 书名 | 主题 | 入口 |
| --- | --- | --- |
| **《追赶卡诺》**<br>给青少年的物理与工程文明史 | 从伽利略的斜面、托里拆利的真空、瓦特的蒸汽机一路讲到内燃机、电网、核能、光伏与火箭，把工业文明背后的能量转换逻辑重新串成一条可计算的线。 | [`chasing-carnot/book.typ`](chasing-carnot/book.typ) |
| **《追逐泛化》**<br>写给软件工程师的机器学习入门 | 以软件工程师的视角进入机器学习：从样本、特征、损失、优化和评估出发，走向线性模型、树模型、神经网络、RAG 与生产反馈闭环。 | [`ml-fundamentals/book.typ`](ml-fundamentals/book.typ) |

## 为什么是这个仓库

现代写作越来越像软件工程：内容需要可复现的构建流程，图片和模板需要与正文一起版本化，发布也应该尽量自动化。这个仓库采用一书一目录的方式组织书稿，让每本书都能在脱离外部私有系统的情况下独立编译。

每本书至少包含：

- `book.typ`：书稿入口。
- `template.typ`：本书使用的 Typst 排版模板。
- `wrap-it.typ`：辅助排版逻辑。
- `assets/`：封面、章节图、示意图与其他本地资源。

## 构建

先安装 [Typst](https://typst.app/)，然后在仓库根目录执行：

```sh
make pdf BOOK=chasing-carnot
```

生成的 PDF 会写入：

```text
dist/chasing-carnot.pdf
```

构建另一本书：

```sh
make pdf BOOK=ml-fundamentals
```

列出当前可构建的书：

```sh
make list
```

清理构建产物：

```sh
make clean
```

## 目录结构

```text
.
├── Makefile
├── README.md
├── chasing-carnot/
│   ├── book.typ
│   ├── template.typ
│   ├── wrap-it.typ
│   └── assets/
└── ml-fundamentals/
    ├── book.typ
    ├── template.typ
    ├── wrap-it.typ
    └── assets/
```

新增一本书时，请保持同样的目录约定：在新目录中提供 `book.typ`，并把编译所需的封面、插图和模板资源一并放入该目录。

## 发布

发布通过 Git tag 触发。Tag 格式为：

```text
<book-name>-v*
```

例如：

```sh
git tag chasing-carnot-v0.1.0
git push origin chasing-carnot-v0.1.0
```

GitHub Actions 会只构建对应的书，并把 `<book-name>-v<version>.pdf` 发布到该 tag 的 GitHub Release。

## 写作原则

这个仓库里的书都追求同一件事：把复杂主题写得严谨、漂亮、可读，并且可被重新构建。故事负责打开问题，图表负责建立直觉，公式与代码负责把判断钉牢。

内容会继续演进。每一次提交都应尽量让书稿更清晰，让构建更稳定，让读者离那个问题的核心更近一步。
