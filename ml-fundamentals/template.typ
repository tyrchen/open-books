// ===== Language-aware book template =====
// Language and title are passed as parameters to `book-template.with(lang: ..., title: ...)`
// from the Rust preamble. All lang-dependent values are resolved inside functions.

// Design language: kami-aligned (see docs/research/study-kami-design.md).
// Warm parchment-leaning neutrals, ink-blue as the only accent, serif for hierarchy.

// ===== Color tokens (kami-aligned) =====
// Warm grays only (R >= G >= B). Brand is the single chromatic colour.
#let bk-brand        = rgb("#1B365D")  // ink blue, the only accent
#let bk-brand-light  = rgb("#2D5A8A")  // links / dark-surface accent
#let bk-near-black   = rgb("#141413")  // primary text
#let bk-dark-warm    = rgb("#3d3d3a")  // secondary text, table headers
#let bk-olive        = rgb("#504e49")  // captions, quotes
#let bk-stone        = rgb("#6b6a64")  // tertiary, page-header text
#let bk-border       = rgb("#e8e6dc")  // primary border
#let bk-border-soft  = rgb("#e5e3d8")  // secondary border / dot leaders
#let bk-ivory        = rgb("#faf9f5")  // lifted card / code block bg
#let bk-deep-dark    = rgb("#141413")  // dark-cover background (warm, not pure black)

// ===== Font configuration =====
// Charter (kami's canonical EN face) is wider than Palatino and inflated this
// 700-page book by ~13% in page count, so EN body+heading roll back to the
// original Palatino + Avenir Next pairing. Mono keeps JetBrains Mono primary
// (kami canonical, free, already installed via brew) since code blocks are a
// small share of pages and don't affect body wrap.

// English: Palatino body for dense reading economy; Charter heading + running
// header for kami-flavoured display tone. Two-serif mix (deliberate trade-off
// against kami invariant 4) — Charter only appears at heading sizes where its
// wider letterforms read as authoritative, while Palatino keeps body wraps
// tight. Palatino fallback keeps non-macOS builds working.
#let body-font-en = "Palatino"
#let heading-font-en = ("Charter", "Palatino", "Georgia")

// Chinese: local book builds prefer static CJK serif faces, with Songti SC /
// STSong as macOS-bundled tails. The variable TTC family Noto Serif CJK SC
// VF is intentionally omitted here because embedded Typst font discovery can
// fail to match it even when the Typst CLI lists it.
// Charter covers Latin glyphs inside CJK strings via Typst's covers spec.
#let body-font-zh = (
    (name: "Charter", covers: "latin-in-cjk"),
    "Noto Serif CJK SC",
    "Songti SC",
    "STSong",
)
#let heading-font-zh = body-font-zh

// Mono: JetBrains Mono primary, then static Fira Code (brew cask), then
// macOS-bundled Menlo. CJK and symbol tails keep code comments / SVG labels
// glyph-safe without relying on Typst's global fallback selection.
#let code-font = (
    "JetBrains Mono",
    "Fira Code",
    "Menlo",
    "Noto Serif CJK SC",
    "Songti SC",
    "STSong",
    "Apple Symbols",
    "Arial Unicode MS",
)

#let math-font-en = "STIX Two Math"

// ===== Title page =====
// A clean typographic title page (inspired by classic technical books).
// Placed after the full-bleed cover image, before the TOC.
#let title-page(title, subtitle: none, author: none, lang: "zh") = {
    let hf = if lang == "en" { heading-font-en } else { heading-font-zh }
    page(header: none)[
        #set par(first-line-indent: 0pt)
        #v(1fr)
        #align(left)[
            #text(font: hf, size: 32pt, weight: "bold", fill: bk-near-black, tracking: 0.02em)[#title]
            #v(0.3cm)
            #line(length: 60%, stroke: 1.5pt + bk-brand)
            #if subtitle != none {
                v(0.6cm)
                text(font: hf, size: 14pt, weight: "regular", fill: bk-olive, tracking: 0.05em)[#subtitle]
            }
        ]
        #v(2fr)
        #align(left)[
            #if author != none {
                text(font: hf, size: 16pt, weight: "medium", fill: bk-dark-warm)[#author]
            }
        ]
        #v(0.5cm)
    ]
}

// ===== Custom TOC =====
// Styled outline inspired by classic technical books (e.g. Rapid Development).
// Level 1 = Part (bold, caps feel), Level 2 = Chapter (bold + page number),
// Level 3 = Section (inline with • separators, no page numbers).
#let book-outline(title: "目录", lang: "zh") = {
    let hf = if lang == "en" { heading-font-en } else { heading-font-zh }
    let toc-indent = 2em
    page(header: none)[
        #set par(first-line-indent: 0pt, justify: false)
        #set text(font: hf, fill: luma(0))
        // Signal to outer template: skip link styling (color/underline) in TOC.
        #state("toc-mode").update(true)
        #v(1cm)
        #text(size: 20pt, weight: "bold")[#title]
        #v(0.8cm)

        // The outline is wrapped in a pad so level 3 sections naturally sit
        // slightly right of level 2 chapters. Levels 1 and 2 compensate with
        // negative margin to reach their intended positions.
        #let h3-indent = toc-indent + 0.5em

        // Level 1: Part titles — bold, full-width (compensate outer pad)
        #show outline.entry.where(level: 1): it => {
            let el = it.element
            pad(left: -h3-indent)[
                #v(0.6em)
                #text(size: 9.5pt, weight: "bold", tracking: 0.03em)[
                    #link(el.location())[#el.body]
                    #h(1fr)
                    #link(el.location())[#counter(page).at(el.location()).first()]
                ]
                #v(0.2em)
            ]
        }

        // Level 2: Chapter titles — bold with dot leaders.
        // Preface articles (before any level-1 part heading) render at full width.
        #show outline.entry.where(level: 2): it => {
            let el = it.element
            let parts-before = query(heading.where(level: 1).before(el.location()))
            if parts-before.len() == 0 {
                // Preface-level entry — full-width (compensate outer pad)
                pad(left: -h3-indent)[
                    #v(0.15em)
                    #text(size: 9pt, weight: "bold")[
                        #link(el.location())[#el.body]
                        #box(width: 1fr, repeat[#text(fill: bk-border)[ .]])
                        #link(el.location())[#counter(page).at(el.location()).first()]
                    ]
                    #v(0.15em)
                ]
            } else {
                // Regular chapter article — at toc-indent (compensate partial)
                pad(left: toc-indent - h3-indent)[
                    #v(0.1em)
                    #text(size: 9pt, weight: "bold")[
                        #link(el.location())[#el.body]
                        #box(width: 1fr, repeat[#text(fill: bk-border)[ .]])
                        #link(el.location())[#counter(page).at(el.location()).first()]
                    ]
                    #v(0.1em)
                ]
            }
        }

        // Level 3: Sections — inline with • separators, tight spacing.
        // No extra indent needed — the outer pad provides it.
        // Suppress for preface articles (no part heading before them).
        #show outline.entry.where(level: 3): it => {
            let el = it.element
            let parts-before = query(heading.where(level: 1).before(el.location()))
            if parts-before.len() > 0 {
                set block(spacing: 0pt)
                text(size: 7pt, fill: bk-stone)[• #el.body #h(0.3em)]
            }
        }

        #pad(left: h3-indent)[
            #outline(title: none, indent: 0pt, depth: 3)
        ]
        #state("toc-mode").update(false)
    ]
}

// ===== Chapter cover =====
// Uses heading-font-zh for part covers (they always use the full font stack
// since chapter titles may contain CJK characters even in English books).
#let part-cover(number, title, cover-image: none) = {
    // Both variants inherit default page margins (KDP-compliant gutter),
    // suppress header, and clip content to stay within safe zone.
    if cover-image != none {
        // Image fills the page; warm deep-dark backdrop matches kami's --deep-dark
        // (#141413, slight olive undertone) rather than cool slate.
        page(fill: bk-deep-dark, header: none, margin: 0pt)[
            #place(hide(heading(level: 1, outlined: true, bookmarked: true)[#number #title]))
            #image(cover-image, width: 100%, height: 100%, fit: "cover")
        ]
    } else {
        page(header: none)[
            #place(hide(heading(level: 1, outlined: true, bookmarked: true)[#number #title]))
            // Clip all decorative elements within the content area.
            #block(clip: true, width: 100%, height: 100%)[
                // Diagonal hatch in border-soft warm gray; restraint over presence.
                #{
                    for i in range(0, 50) {
                        place(top + left, dx: -6cm + i * 18pt,
                            rotate(18deg, line(length: 45cm, stroke: 0.2pt + bk-border-soft))
                        )
                    }
                }
                // Brand left bar — kami's signature section/chapter mark.
                #place(top + left, dx: 0pt, dy: 0pt,
                    rect(width: 3pt, height: 100%, fill: bk-brand)
                )
                #place(left + horizon, dx: 1cm, dy: -1cm)[
                    #text(
                        font: heading-font-zh,
                        size: 11pt,
                        fill: bk-stone,
                        tracking: 0.15em,
                        weight: "regular",
                    )[#number]
                    #v(1.2cm)
                    #{
                        set text(hyphenate: false)
                        let parts = title.split(" — ")
                        let main-title = parts.at(0)
                        text(
                            font: heading-font-zh,
                            size: 30pt,
                            fill: bk-near-black,
                            weight: "bold",
                            tracking: 0.02em,
                        )[#main-title]
                        if parts.len() > 1 {
                            v(0.8cm)
                            text(
                                font: heading-font-zh,
                                size: 14pt,
                                fill: bk-olive,
                                weight: "regular",
                                tracking: 0.06em,
                            )[#parts.at(1)]
                        }
                    }
                    #v(1.5cm)
                    // Closing rule in brand colour, not pure black — quieter authority.
                    #rect(width: 4cm, height: 2pt, fill: bk-brand)
                ]
            ]
        ]
    }
}

// ===== Meta block =====
#let meta-style = "C"

// Stars use ink-blue accent over warm border; matches kami "single chromatic colour" rule.
#let rating-stars(n, filled-color: bk-brand, empty-color: bk-border) = {
    let filled = calc.min(n, 5)
    let empty = 5 - filled
    if filled > 0 { text(fill: filled-color, (("★",) * filled).join()) }
    if empty > 0 { text(fill: empty-color, (("☆",) * empty).join()) }
}

#let _meta-label(body) = text(size: 7.5pt, fill: bk-stone, tracking: 0.06em, body)

// All meta-block variants accept pre-resolved label strings.
// The Rust preamble passes lang-appropriate labels via the `meta-block` wrapper.

#let _meta-sources-patterns(sources, patterns, lbl-sources, lbl-patterns) = {
    if sources.len() > 0 {
        text(size: 8pt, fill: bk-olive)[#text(fill: bk-stone)[#lbl-sources] #h(0.5em) #sources.join(" · ")]
    }
    if patterns.len() > 0 {
        if sources.len() > 0 { v(2pt) }
        text(size: 8pt, fill: bk-olive)[#text(fill: bk-stone)[#lbl-patterns] #h(0.5em) #patterns.join(" · ")]
    }
}

// --- A: Editorial glance-grid (kami-aligned) ---
// Replaces the prior dark-slate header. Three labelled cells with a 2pt brand
// left bar each, near-black star values, optional ivory footer for sources.
#let _meta-block-a(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p) = {
    block(width: 100%, radius: 4pt, clip: true, stroke: 0.5pt + bk-border)[
        #block(inset: (x: 16pt, y: 12pt), width: 100%)[
            #set par(justify: false, first-line-indent: 0pt)
            #set text(font: heading-font-zh, size: 9pt, fill: bk-near-black)
            #grid(columns: (1fr, 1fr, 1fr), column-gutter: 14pt, row-gutter: 2pt,
                ..(
                    (lbl-d, difficulty),
                    (lbl-dp, depth),
                    (lbl-f, frequency),
                ).map(((lbl, val)) => block(
                    inset: (left: 8pt),
                    stroke: (left: 2pt + bk-brand),
                    [#text(size: 7.5pt, fill: bk-brand, tracking: 0.08em, weight: "medium")[#upper(lbl)] #linebreak() #v(1pt) #rating-stars(val)],
                )),
            )
        ]
        #if sources.len() > 0 or patterns.len() > 0 {
            block(fill: bk-ivory, inset: (x: 16pt, y: 8pt), width: 100%, stroke: (top: 0.4pt + bk-border-soft))[
                #set par(justify: false, first-line-indent: 0pt)
                #_meta-sources-patterns(sources, patterns, lbl-s, lbl-p)
            ]
        }
    ]
}

// --- B: Three-column centered card ---
#let _meta-block-b(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p) = {
    block(
        inset: (x: 20pt, y: 14pt),
        width: 100%,
        radius: 6pt,
        stroke: 0.6pt + bk-border,
    )[
        #set par(justify: false, first-line-indent: 0pt)
        #set text(font: heading-font-zh, size: 9pt, fill: bk-near-black)
        #align(center,
            grid(columns: (1fr, 1fr, 1fr), row-gutter: 2pt,
                [#_meta-label[#lbl-d] #linebreak() #rating-stars(difficulty)],
                [#_meta-label[#lbl-dp] #linebreak() #rating-stars(depth)],
                [#_meta-label[#lbl-f] #linebreak() #rating-stars(frequency)],
            ),
        )
        #if sources.len() > 0 or patterns.len() > 0 {
            v(8pt)
            line(length: 100%, stroke: 0.4pt + bk-border-soft)
            v(6pt)
            align(center,
                text(size: 8pt, fill: bk-olive)[
                    #if sources.len() > 0 [#text(fill: bk-stone)[#lbl-s] #h(0.4em) #sources.join(" · ")]
                    #if sources.len() > 0 and patterns.len() > 0 [#h(1.5em)]
                    #if patterns.len() > 0 [#text(fill: bk-stone)[#lbl-p] #h(0.4em) #patterns.join(" · ")]
                ],
            )
        }
    ]
}

// --- C: Minimalist (centered + double rules) ---
#let _meta-block-c(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p, join-sep, colon) = {
    block(width: 100%, inset: (y: 8pt))[
        #set par(justify: false, first-line-indent: 0pt)
        #set text(font: heading-font-zh, size: 9pt, fill: bk-near-black)
        #line(length: 100%, stroke: 0.5pt + bk-border)
        #v(8pt)
        #align(center)[
            #_meta-label[#lbl-d] #h(0.3em) #rating-stars(difficulty)
            #h(2em)
            #_meta-label[#lbl-dp] #h(0.3em) #rating-stars(depth)
            #h(2em)
            #_meta-label[#lbl-f] #h(0.3em) #rating-stars(frequency)
        ]
        #if sources.len() > 0 or patterns.len() > 0 {
            v(6pt)
            align(center,
                text(size: 8pt, fill: bk-olive)[
                    #if sources.len() > 0 [#lbl-s#colon#sources.join(join-sep)]
                    #if sources.len() > 0 and patterns.len() > 0 [#h(2em)]
                    #if patterns.len() > 0 [#lbl-p#colon#patterns.join(join-sep)]
                ],
            )
        }
        #v(8pt)
        #line(length: 100%, stroke: 0.5pt + bk-border)
    ]
}

// --- D: Magazine sidebar ---
// Brand-coloured 4pt left bar over an ivory wash; matches kami's editorial sidebar pattern.
#let _meta-block-d(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p) = {
    block(
        inset: (left: 16pt, right: 14pt, y: 12pt),
        width: 100%,
        stroke: (left: 4pt + bk-brand),
        fill: bk-ivory,
    )[
        #set par(justify: false, first-line-indent: 0pt)
        #set text(font: heading-font-zh, size: 9pt, fill: bk-near-black)
        #grid(columns: (1fr, 1fr, 1fr), row-gutter: 2pt,
            [#_meta-label[#lbl-d] #linebreak() #rating-stars(difficulty)],
            [#_meta-label[#lbl-dp] #linebreak() #rating-stars(depth)],
            [#_meta-label[#lbl-f] #linebreak() #rating-stars(frequency)],
        )
        #if sources.len() > 0 or patterns.len() > 0 {
            v(6pt)
            line(length: 100%, stroke: 0.4pt + bk-border-soft)
            v(4pt)
            _meta-sources-patterns(sources, patterns, lbl-s, lbl-p)
        }
    ]
}

// --- Unified entry (lang-aware) ---
#let meta-block(difficulty: 0, depth: 0, frequency: 0, sources: (), patterns: (), lang: "zh") = {
    let lbl-d = if lang == "en" { "Difficulty" } else { "难度" }
    let lbl-dp = if lang == "en" { "Depth" } else { "深度" }
    let lbl-f = if lang == "en" { "Frequency" } else { "频率" }
    let lbl-s = if lang == "en" { "Sources" } else { "来源" }
    let lbl-p = if lang == "en" { "Patterns" } else { "模式" }
    let join-sep = if lang == "en" { " · " } else { "、" }
    let colon = if lang == "en" { ": " } else { "：" }
    if meta-style == "A" { _meta-block-a(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p) }
    else if meta-style == "B" { _meta-block-b(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p) }
    else if meta-style == "C" { _meta-block-c(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p, join-sep, colon) }
    else { _meta-block-d(difficulty, depth, frequency, sources, patterns, lbl-d, lbl-dp, lbl-f, lbl-s, lbl-p) }
}

// ===== Paper presets =====
// Each preset defines (width, height, margin-top, margin-bottom, margin-inside, margin-outside).
#let _paper-presets = (
    "a4": (w: 210mm, h: 297mm, mt: 2.5cm, mb: 2.5cm, mi: 3cm, mo: 2.5cm),
    "6x9": (w: 6in, h: 9in, mt: 0.75in, mb: 0.75in, mi: 0.875in, mo: 0.625in),
    "7x10": (w: 7in, h: 10in, mt: 0.8in, mb: 0.8in, mi: 0.9in, mo: 0.7in),
    "7.5x9.25": (w: 7.5in, h: 9.25in, mt: 0.75in, mb: 0.75in, mi: 0.875in, mo: 0.625in),
    "5.5x8.5": (w: 5.5in, h: 8.5in, mt: 0.625in, mb: 0.75in, mi: 0.75in, mo: 0.5in),
    "8.5x11": (w: 8.5in, h: 11in, mt: 0.75in, mb: 0.75in, mi: 0.875in, mo: 0.625in),
)

// ===== Template function =====
// Accepts lang, title, and paper as parameters from the Rust preamble.
#let book-template(lang: "zh", title: "", paper: "a4", font-size: none, code-font-size: none, body) = {
    let is-en = lang == "en"
    let body-font = if is-en { body-font-en } else { body-font-zh }
    let heading-font = if is-en { heading-font-en } else { heading-font-zh }

    let pg = _paper-presets.at(paper, default: _paper-presets.at("a4"))

    // ===== Page setup =====
    set page(
        width: pg.w,
        height: pg.h,
        margin: (top: pg.mt, bottom: pg.mb, inside: pg.mi, outside: pg.mo),
        header: context {
            if counter(page).get().first() > 2 {
                let chapters = query(heading.where(level: 1).before(here()))
                let chapter-title = if chapters.len() > 0 {
                    chapters.last().body
                } else {
                    [#title]
                }
                text(size: 9pt, fill: bk-stone, font: heading-font)[
                    #chapter-title
                    #h(1fr)
                    #counter(page).display()
                ]
            }
        },
    )

    // Math needs an OpenType math font regardless of the prose language.
    show math.equation: set text(font: math-font-en)

    // ===== Body text =====
    if is-en {
        // English: standard serif, no CJK spacing
        set text(font: body-font, size: if font-size != none { font-size } else { 10pt }, lang: "en")
        // Block paragraph style: no first-line indent, full-line gap between
        // paragraphs. Modern web/editorial convention; preferred over the
        // print-book indent style for this title.
        set par(leading: 0.65em, first-line-indent: 0pt, justify: true, spacing: 1.1em)

        // Chapter / heading recipe: 2.5pt brand left bar paired with the title
        // text, mirroring kami's section-title signature move.
        show heading: set par(first-line-indent: 0pt)
        show heading: set text(font: heading-font, fill: bk-near-black)
        show heading.where(level: 1): it => {}
        show heading.where(level: 2): it => {
            pagebreak(weak: true)
            place(hide(it))
        }
        show heading.where(level: 3): it => {
            v(0.7cm)
            grid(columns: (3pt, 1fr), column-gutter: 8pt,
                rect(width: 3pt, height: 16pt, fill: bk-brand, radius: 1pt),
                text(size: 16pt, weight: "bold", fill: bk-near-black)[#it.body],
            )
            v(0.3cm)
        }
        show heading.where(level: 4): it => {
            v(0.5cm)
            text(size: 13pt, weight: "bold", fill: bk-dark-warm)[#it.body]
            v(0.2cm)
        }

        // Code block: ivory fill + warm border + 6pt radius (kami code-card recipe).
        show raw.where(block: true): it => {
            set text(font: code-font, size: if code-font-size != none { code-font-size } else { 9pt }, fill: bk-near-black)
            set par(first-line-indent: 0pt, leading: 0.65em, justify: false)
            block(fill: bk-ivory, stroke: 0.5pt + bk-border-soft, inset: (x: 12pt, y: 10pt), radius: 6pt, width: 100%, it)
        }
        show raw.where(block: false): it => { text(font: code-font, size: 8.5pt, fill: bk-dark-warm, it) }

        show table: it => block(breakable: false, it)

        set enum(indent: 1.5em)
        set list(indent: 1.5em)

        show figure: it => {
            set text(size: 9pt, fill: bk-olive)
            set par(first-line-indent: 0pt)
            it
            v(0.5cm)
        }
        show link: it => context {
            if state("toc-mode", false).get() { it }
            else { underline(text(fill: bk-brand, it)) }
        }
        show super: set text(size: 0.85em)
        show footnote.entry: it => {
            set text(size: 9pt, fill: bk-olive)
            set par(first-line-indent: 0pt)
            it
        }
        // Block quote: 2.5pt brand left border + olive text on ivory wash.
        show quote.where(block: true): it => {
            set par(first-line-indent: 0pt)
            block(
                inset: (left: 16pt, right: 12pt, y: 10pt),
                width: 100%,
                stroke: (left: 2.5pt + bk-brand),
                fill: bk-ivory,
                text(fill: bk-olive, it.body),
            )
        }

        body
    } else {
        // Chinese: CJK font stack, 2em indent, cjk-latin-spacing
        set text(font: body-font, size: if font-size != none { font-size } else { 10.5pt }, fill: bk-near-black, lang: "zh", region: "cn", cjk-latin-spacing: auto)
        set par(leading: 1em, first-line-indent: (amount: 2em, all: true), justify: true, spacing: 1.2em)

        show heading: set par(first-line-indent: 0pt)
        show heading: set text(font: heading-font, fill: bk-near-black)
        show heading.where(level: 1): it => {}
        show heading.where(level: 2): it => {
            pagebreak(weak: true)
            place(hide(it))
        }
        show heading.where(level: 3): it => {
            v(0.7cm)
            grid(columns: (3pt, 1fr), column-gutter: 8pt,
                rect(width: 3pt, height: 16pt, fill: bk-brand, radius: 1pt),
                text(size: 16pt, weight: "bold", fill: bk-near-black)[#it.body],
            )
            v(0.3cm)
        }
        show heading.where(level: 4): it => {
            v(0.5cm)
            text(size: 13pt, weight: "bold", fill: bk-dark-warm)[#it.body]
            v(0.2cm)
        }

        show raw.where(block: true): it => {
            set text(font: code-font, size: if code-font-size != none { code-font-size } else { 9pt }, fill: bk-near-black)
            set par(first-line-indent: 0pt, leading: 0.65em, justify: false)
            block(fill: bk-ivory, stroke: 0.5pt + bk-border-soft, inset: (x: 12pt, y: 10pt), radius: 6pt, width: 100%, it)
        }
        show raw.where(block: false): it => { text(font: code-font, size: 8.5pt, fill: bk-dark-warm, it) }

        show table: it => block(breakable: false, it)

        set enum(indent: 2em)
        set list(indent: 2em)

        show figure: it => {
            set text(size: 9pt, fill: bk-olive)
            set par(first-line-indent: 0pt)
            it
            v(0.5cm)
        }
        show link: it => context {
            if state("toc-mode", false).get() { it }
            else { underline(text(fill: bk-brand, it)) }
        }
        show super: set text(size: 0.85em)
        show footnote.entry: it => {
            set text(size: 9pt, fill: bk-olive)
            set par(first-line-indent: 0pt)
            it
        }
        show quote.where(block: true): it => {
            set par(first-line-indent: 0pt)
            block(
                inset: (left: 16pt, right: 12pt, y: 10pt),
                width: 100%,
                stroke: (left: 2.5pt + bk-brand),
                fill: bk-ivory,
                text(fill: bk-olive, it.body),
            )
        }

        body
    }
}
