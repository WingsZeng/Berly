// This theme is inspired by Berlin and modifyed from [Dewdrop](https://touying-typ.github.io/docs/themes/dewdrop)

#import "@preview/touying:0.6.1": *

#let _typst-builtin-repeat = repeat

#let berly-header(self) = {
  if self.store.navigation == "sidebar" {
    place(
      right + top,
      {
        v(4em)
        show: block.with(width: self.store.sidebar.width, inset: (x: 1em))
        set align(left)
        set par(justify: false)
        set text(size: .9em)
        components.custom-progressive-outline(
          self: self,
          level: auto,
          alpha: self.store.alpha,
          text-fill: (self.colors.primary, self.colors.neutral-darkest),
          text-size: (1em, .9em),
          vspace: (-.2em,),
          indent: (0em, self.store.sidebar.at("indent", default: .5em)),
          fill: (self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),),
          filled: (self.store.sidebar.at("filled", default: false),),
          paged: (self.store.sidebar.at("paged", default: false),),
          short-heading: self.store.sidebar.at("short-heading", default: true),
        )
      },
    )
  } else if self.store.navigation == "mini-slides" {
    set std.align(top)
    context {
      set par(first-line-indent: 0em)
      let nav = components.mini-slides(
          self: self,
          fill: self.colors.neutral-lightest,
          alpha: self.store.alpha,
          display-section: self.store.mini-slides.at("display-section", default: false),
          display-subsection: self.store.mini-slides.at("display-subsection", default: true),
          linebreaks: self.store.mini-slides.at("linebreaks", default: true),
          short-heading: self.store.mini-slides.at("short-heading", default: true),
      )
      let nav-height = measure(nav).height + if self.store.mini-slides.at("linebreaks", default: true) { 1em } else { .5em }
      let current-heading = utils.current-heading(level: 2)
      let current-sub-heading = utils.current-heading(level: 3)
      let title = if current-heading != none {
        text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em, current-heading.body)
      }
      let sub-title = if current-sub-heading != none {
        text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em, current-sub-heading.body)
      }
      if title != none {
        grid(
          align: horizon,
          stroke: none,
          // columns: (auto, auto),
          rows: (nav-height, 2em),
          fill: (x, y) => if y == 0 { self.colors.tertiary } else { self.colors.primary },
          row-gutter: 0em,
          nav,
          block(inset: (x: 2em), [#title #h(1fr) #sub-title])
        )
      }
      else {
        components.cell(height: nav-height, fill: self.colors.tertiary, nav)
      }
    }
  }
}

#let berly-footer(self) = {
  set std.align(center + bottom)
  set text(size: .4em)
  {
    let cell(..args, it) = components.cell(
      ..args,
      inset: 1mm,
      std.align(horizon, text(fill: white, it)),
    )
    show: block.with(width: 100%, height: auto)
    grid(
      columns: self.store.footer-columns,
      rows: 1.5em,
      cell(fill: self.colors.secondary, utils.call-or-display(self, self.store.footer-a)),
      cell(fill: self.colors.tertiary, utils.call-or-display(self, self.store.footer-b)),
      cell(fill: self.colors.secondary, utils.call-or-display(self, self.store.footer-c)),
    )
  }
}

// #let berly-footer(self) = {
//   set align(bottom)
//   set text(size: 0.8em)
//   show: pad.with(.5em)
//   components.left-and-right(
//     text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer)),
//     text(fill: self.colors.neutral-darkest.lighten(20%), utils.call-or-display(self, self.store.footer-right)),
//   )
// }

/// Default slide function for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function, array): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  context { 
    let header = berly-header(self) 
    let self = utils.merge-dicts(
      self,
      config-page(
        header: berly-header,
        footer: berly-footer,
        margin: (top: measure(header).height + 1em)
      ),
    // config-common(subslide-preamble: self.store.subslide-preamble),
    )
    touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
  }
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: berly-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
/// 
/// - extra (string, none): The extra information you want to display on the title slide.
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  context { 
    let header = berly-header(self)
    let self = utils.merge-dicts(
      self,
      config,
      config-page(
        header: berly-header,
        footer: berly-footer,
        margin: (top: measure(header).height)
      )
    )
    self.store.title = none
    let info = self.info + args.named()
    info.authors = {
      let authors = if "authors" in info {
        info.authors
      } else {
        info.author
      }
      if type(authors) == array {
        authors
      } else {
        (authors,)
      }
    }
    let body = {
      show: std.align.with(center + horizon)
      block(
        fill: self.colors.primary,
        inset: 1.5em,
        width: 90%,
        breakable: false,
        {
          text(size: 1.2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
          if info.subtitle != none {
            parbreak()
            text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
          }
        },
      )
      // authors
      grid(
        columns: (1fr,) * calc.min(info.authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..info.authors.map(author => text(fill: black, author)),
      )
      v(0.5em)
      // institution
      if info.institution != none {
        parbreak()
        text(size: 0.7em, info.institution)
      }
      // date
      if info.date != none {
        parbreak()
        text(size: 1.0em, utils.display-info-date(self))
      }
    }
    touying-slide(self: self, body)
  }
})


/// Outline slide for the presentation.
/// 
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
/// 
/// - title (string): The title of the slide. Default is `utils.i18n-outline-title`.
#let outline-slide(config: (:), title: utils.i18n-outline-title, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      footer: berly-footer,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.primary,
        weight: "bold",
        utils.call-or-display(self, title),
      ),
      text(
        fill: self.colors.neutral-darkest,
        outline(title: none, indent: 1em, depth: self.slide-level, ..args),
      ),
    ),
  )
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
/// 
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): The title of the slide. Default is `utils.i18n-outline-title`.
///
/// - body (array): The contents of the slide.
#let new-section-slide(config: (:), title: utils.i18n-outline-title, ..args, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      footer: berly-footer,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.primary,
        weight: "bold",
        utils.call-or-display(self, title),
      ),
      text(
        fill: self.colors.neutral-darkest,
        components.progressive-outline(
          alpha: self.store.alpha,
          title: none,
          indent: 1em,
          depth: self.slide-level,
          ..args,
        ),
      ),
    ),
  )
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
/// 
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 2em),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, config: config, align(horizon + center, body))
})


/// Touying berly theme.
///
/// Example:
///
/// ```typst
/// #show: berly-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   neutral-darkest: rgb("#000000"),
///   neutral-dark: rgb("#202020"),
///   neutral-light: rgb("#f3f3f3"),
///   neutral-lightest: rgb("#ffffff"),
///   primary: rgb("#0c4842"),
/// )
/// ```
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - navigation (string): The navigation of the slides. You can choose from `"sidebar"`, `"mini-slides"`, and `none`. Default is `"sidebar"`.
///
/// - sidebar (dictionary): The configuration of the sidebar. You can set the width, filled, numbered, indent, and short-heading of the sidebar. Default is `(width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true)`.
///   - width (string): The width of the sidebar.
///   - filled (boolean): Whether the outline in the sidebar is filled.
///   - numbered (boolean): Whether the outline in the sidebar is numbered.
///   - indent (length): The indent of the outline in the sidebar.
///   - short-heading (boolean): Whether the outline in the sidebar is short.
///
/// - mini-slides (dictionary): The configuration of the mini-slides. You can set the height, x, display-section, display-subsection, and short-heading of the mini-slides. Default is `(height: 4em, x: 2em, display-section: false, display-subsection: true, linebreaks: true, short-heading: true)`.
///   - height (length): The height of the mini-slides.
///   - x (length): The x position of the mini-slides.
///   - display-section (boolean): Whether the slides of sections are displayed in the mini-slides.
///   - display-subsection (boolean): Whether the slides of subsections are displayed in the mini-slides.
///   - linebreaks (boolean): Whether line breaks are in between links for sections and subsections in the mini-slides.
///   - short-heading (boolean): Whether the mini-slides are short. Default is `true`.
///
/// - footer (content, function): The footer of the slides. Default is `none`.
///
/// - footer-right (content, function): The right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - primary (color): The primary color of the slides. Default is `rgb("#0c4842")`.
///
/// - alpha (fraction, float): The alpha of transparency. Default is `60%`.
///
/// - outline-title (content, function): The title of the outline. Default is `utils.i18n-outline-title`.
///
/// - subslide-preamble (content, function): The preamble of the subslide. Default is `self => block(text(1.2em, weight: "bold", fill: self.colors.primary, utils.display-current-heading(depth: self.slide-level)))`.
#let berly-theme(
  aspect-ratio: "16-9",
  navigation: "mini-slides",
  sidebar: (
    width: 10em,
    filled: false,
    numbered: false,
    indent: .5em,
    short-heading: true,
  ),
  mini-slides: (
    height: 4em,
    x: 2em,
    display-section: false,
    display-subsection: true,
    linebreaks: true,
    short-heading: true,
  ),
  footer-columns: (1fr, 1fr, 1fr),
  footer-a: self => self.info.author,
  footer-b: self => self.info.institution,
  footer-c: self => utils.display-info-date(self),
  primary: rgb("#3333b3"),
  alpha: 60%,
  subslide-preamble: self => block(
    text(1.2em, weight: "bold", fill: self.colors.primary, utils.display-current-heading(depth: self.slide-level, style: auto)),
  ),
  ..args,
  body,
) = {
  sidebar = utils.merge-dicts(
    (width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true),
    sidebar,
  )
  mini-slides = utils.merge-dicts(
    (height: 4em, x: 2em, display-section: false, display-subsection: true, linebreaks: true, short-heading: true),
    mini-slides,
  )
  set text(size: 20pt)
  set par(justify: true)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: if navigation == "sidebar" {
        (top: 2em, bottom: 1em, x: sidebar.width)
      } else if navigation == "mini-slides" {
        (top: mini-slides.height, bottom: 1em, x: mini-slides.x)
      } else {
        (top: 2em, bottom: 2em, x: mini-slides.x)
      },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      slide-level: 3,
    ),
    config-methods(
      init: (self: none, body) => {
        show heading.where(level: 3): set text(fill: self.colors.primary)
        show heading.where(level: 4): set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#3333b3"),
      secondary: rgb("#262686"),
      tertiary: rgb("#191959"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      navigation: navigation,
      sidebar: sidebar,
      mini-slides: mini-slides,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      alpha: alpha,
      subslide-preamble: subslide-preamble,
    ),
    ..args,
  )

  body
}
