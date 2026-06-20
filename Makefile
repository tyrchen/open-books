# SPDX-License-Identifier: CC-BY-NC-ND-4.0

BOOK ?= chasing-carnot
DIST ?= dist
PDF := $(DIST)/$(BOOK).pdf
BUILD_DIR := $(DIST)/.build
WRAPPER := $(BUILD_DIR)/$(BOOK)-with-license.typ

.PHONY: pdf clean list

pdf:
	@test -f "$(BOOK)/book.typ" || (echo "missing $(BOOK)/book.typ" >&2; exit 1)
	@mkdir -p "$(BUILD_DIR)"
	@printf '%s\n' \
		'#include "../../$(BOOK)/book.typ"' \
		'' \
		'#page(header: none)[' \
		'  #set par(first-line-indent: 0pt, justify: false)' \
		'  #v(1fr)' \
		'  #align(center)[' \
		'    #text(size: 16pt, weight: "bold")[版权与许可]' \
		'    #v(0.8cm)' \
		'    #block(width: 80%)[' \
		'      #align(left)[' \
		'        © 2026 陈天。' \
		'' \
		'        本书及本仓库中的代码、图像、排版模板与其他资料采用 #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International]（CC BY-NC-ND 4.0）许可协议发布，除非文件中另有明确说明。' \
		'' \
		'        你可以在非商业目的下复制和分享本作品，但必须保留署名和许可声明，不得发布演绎作品。' \
		'      ]' \
		'    ]' \
		'  ]' \
		'  #v(1fr)' \
		']' \
		> "$(WRAPPER)"
	typst compile --root . "$(WRAPPER)" "$(PDF)"

clean:
	rm -rf "$(DIST)"

list:
	@find . -mindepth 2 -maxdepth 2 -name book.typ -print | sed 's#^\./##; s#/book.typ##' | sort
