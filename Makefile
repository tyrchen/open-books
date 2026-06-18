BOOK ?= chasing-carnot
DIST ?= dist
PDF := $(DIST)/$(BOOK).pdf

.PHONY: pdf clean list

pdf:
	@test -f "$(BOOK)/book.typ" || (echo "missing $(BOOK)/book.typ" >&2; exit 1)
	@mkdir -p "$(DIST)"
	typst compile "$(BOOK)/book.typ" "$(PDF)"

clean:
	rm -rf "$(DIST)"

list:
	@find . -mindepth 2 -maxdepth 2 -name book.typ -print | sed 's#^\./##; s#/book.typ##' | sort
