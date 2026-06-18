# Open Books

Standalone Typst source bundles for published books.

Each book lives in its own directory and must contain a `book.typ` entrypoint plus all local assets needed to compile without `bukit`.

## Build

```sh
make pdf BOOK=chasing-carnot
```

The PDF is written to:

```text
dist/chasing-carnot.pdf
```

List available books:

```sh
make list
```

## Release

Push a tag in this form:

```text
<book-name>-v*
```

Example:

```sh
git tag chasing-carnot-v0.1.0
git push origin chasing-carnot-v0.1.0
```

GitHub Actions builds only that book and publishes `dist/<book-name>.pdf` to the tag's GitHub Release.
