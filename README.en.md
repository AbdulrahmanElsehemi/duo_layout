# duo_layout

**iPhone Duo layouts for Flutter, as Apple's Human Interface Guidelines draw
them.**

With this package, an app on the iPhone Duo behaves the way Apple's own apps do:

- The tab bar stands down the side and minimizes when you scroll.
- Back and the toolbar's buttons stand in the status bar's column.
- Two panes split exactly at the fold.
- Horizontal rows scroll to the edge of the glass.

The same app stays unchanged on an iPhone and an iPad.

[العربي](README.md)

![An iPhone, the iPhone Duo closed, and open on its side](doc/images/overview.png)

## Why

The iPhone Duo folds like a book. It has an outer screen (466 × 678) and an
inner one (669 × 951). On the outer screen always, and on the inner one held
on its side, **the status bar runs down one side in an 84-point column**
instead of along the top.

A phone layout on it:

![A phone layout next to the same app with duo_layout](doc/images/before_after.png)

| A phone layout | With duo_layout |
|---|---|
| An empty column wastes 18% of the width | The column holds the toolbar and the tabs, as in iOS |
| A bottom tab bar eats into a short screen | The tabs float in a capsule down the side |
| The bell and the bag sit beside the camera | The buttons stand under the clock, where Apple puts them |
| A row of cards stops mid-screen | The row scrolls to the edge of the glass |

Other problems you can't see in the picture:

- **The open Duo stays locked upright.** iOS keeps reporting the outer
  screen's size, so "lock phones portrait" locks the open Duo too.
- **With `flutter_screenutil`, everything is 15% too big on the outer
  screen.** It scales by the whole 466-point width, not the 382 beside the
  column.
- **Content lands on the fold**, and a card or a line of text is cut by it.
- **Flutter gets nothing from iOS about the Duo:** no display features, no
  fold, no column. This package infers the column from the safe area, in one
  place.

## Benefits

1. **One line of setup.** After that, every widget adapts by itself.
2. **No `if (isDuo)` in your screens.** `DuoAppBar` is a plain `AppBar` on a
   phone and moves its buttons to the column on the Duo.
3. **One place to fix.** When iOS or Flutter changes how the Duo is detected,
   only this package needs the fix, and every app gets it with
   `flutter pub upgrade`.
4. **Right-to-left done right.** The column stays on the same physical side
   in Arabic, as Apple asks; it's the panes that swap places.
5. **Tested.** 18 widget tests, plus an example app for the simulator.
6. **No dependencies** beyond Flutter. It works with or without
   `flutter_screenutil`.

## What's inside

| Widget | What it does | Where |
|---|---|---|
| `DuoScope` | Reads the column before any `SafeArea` hides it, keeps room at the top, and sets orientations | Once, in `MaterialApp.builder` |
| `SideTabBar` | Tabs in a capsule down the status bar's column, minimizing on scroll | Your tab shell |
| `DuoAppBar` | An `AppBar` whose back button and actions stand in the column | Instead of `AppBar` |
| `SideToolbar`, `SideToolbarButton` | The same for a header you built yourself | Custom headers |
| `TwoPane` | Two panes split at the fold | List and detail, photo and details, cart and total |
| `EdgeBleed` | A horizontal row that scrolls to the edge of the glass | Rows of cards, chips, logos |
| `context.barEdge` | Which side the column is on, or `null` | Your own decisions |
| `WindowClass`, `DuoBreakpoints` | Window size classes, and even column counts for the fold | Grids |
| `DuoDesignSize` | The right `designSize` for `flutter_screenutil`, and orientations | screenutil apps |

## Install

The repository is private, so you need access to it on GitHub.

```yaml
dependencies:
  duo_layout:
    git:
      url: https://github.com/AbdulrahmanElsehemi/duo_layout.git
      ref: v0.1.0
```

Pin `ref` to a tag, so a new commit doesn't change your app until you move
the tag yourself.

## Setup

**1. Put `DuoScope` above the navigator:**

```dart
MaterialApp(
  builder: (context, child) => DuoScope(child: child!),
  home: const Shell(),
)
```

If you already have a builder, make `DuoScope` the outermost widget in it.

`DuoScope` does three things:

- It reads the column from the window's own insets, since a screen's
  `SafeArea` hides them from everything below it.
- It keeps at least 24 points at the top. With the column down the side,
  iOS reports no top inset, and headers meet the glass's rounded corner.
- With `lockPhonesUpright` (on by default), it keeps phones upright and lets
  tablets and the open Duo turn. Turn this off if your app sets orientations
  itself.

**2. Allow landscape in `ios/Runner/Info.plist`.** The Duo is an iPhone, and
iOS intersects this list with what the app asks for. With portrait only, the
open Duo can never turn, whatever the code says.

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

Phones still stay upright, because `DuoScope` locks them from code. This
change needs a full rebuild; hot reload isn't enough.

## Usage

### `SideTabBar`

![Tabs down the side; minimized after a scroll; a pushed page](doc/images/closed.png)

```dart
Scaffold(
  body: SideTabBar(
    tabs: const [
      SideTab(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      SideTab(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
      SideTab(icon: Icon(Icons.person_outline), label: 'Profile'),
    ],
    currentIndex: index,
    onTap: (i) => setState(() => index = i),
    child: IndexedStack(index: index, children: pages),
  ),
  bottomNavigationBar: SideTabBar.show(context) ? null : NavigationBar(/* ... */),
)
```

- **Icons only.** The label isn't drawn, but screen readers read it.
- **Minimizes on scroll.** Scrolling down shrinks the capsule to the current
  tab; scrolling up, tapping it, or changing tab opens it again. Turn this off
  with `minimizeOnScroll: false`.
- **Styling.** Colours come from the `ColorScheme`; set your own with
  `SideTabBarStyle`.

### `DuoAppBar`

```dart
Scaffold(
  appBar: DuoAppBar(
    title: Text(product.name),
    actions: [
      DuoAction(icon: const Icon(Icons.ios_share), tooltip: 'Share', onPressed: share),
      DuoAction(icon: const Icon(Icons.favorite_border), tooltip: 'Save', onPressed: save),
    ],
  ),
)
```

- **Where the status bar is along the top**, it's a plain `AppBar`.
- **Where it's down the side**, Back (or Close, on a full-screen dialog) and
  the actions stand in the column under the clock, and the bar keeps only
  its title.
- **The buttons go with their screen.** They hide while the screen is covered
  or its tab isn't showing, and fade with the route.
- **Keep text buttons out of `actions`.** Apple keeps buttons with words in
  horizontal bars; put them in the page or a bottom bar.

For a header you built yourself, use `SideToolbar` with
`SideToolbarButton`s, and leave the buttons out of the header when
`SideToolbar.show(context)` is true.

### `TwoPane`

![Shop: the list beside the product, in English and Arabic](doc/images/two_panes.png)

```dart
body: TwoPane.fits(context)
    ? TwoPane(start: ProductList(onPick: pick), end: ProductDetails(picked))
    : ProductList(onPick: (p) => push(ProductPage(p))),
```

- **Where it splits.** Down the middle of the window, which is where the
  open Duo folds on its side. On an iPad it's simply half and half.
- **When it fits.** `TwoPane.fits` is true from 840 points wide.
- **Insets.** Each pane keeps clear of its own edge of the glass only.
- **Who gets the column.** Only the pane beside the column gives its buttons
  to it; the other keeps them above its content (Apple's split-view rule).
- **In Arabic**, the panes swap and the column stays put.
- **Give it the whole window.** iOS doesn't say where the fold is, so put
  `TwoPane` straight in the Scaffold's `body`, not inside padding.

### `EdgeBleed`

```dart
ListView(
  padding: EdgeBleed.padding(context, const EdgeInsets.all(16)),
  children: [
    const Text('Picks for you'),
    EdgeBleed(
      child: SizedBox(
        height: 176,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeBleed.padding(context, const EdgeInsets.symmetric(horizontal: 16)),
          children: cards,
        ),
      ),
    ),
  ],
)
```

The page keeps its side insets inside its scroll view instead of in a
`SafeArea`. The first card lines up with the page's text, and the row scrolls
under the column to the edge of the glass. On an upright phone there are no
side insets, so `EdgeBleed` returns the row as it is.

### Even columns

![The Duo open upright, and on its side](doc/images/open.png)

```dart
DuoBreakpoints.columns(width, tile: 150, gap: 12, even: true);
```

Apple asks for an even number of columns, so the fold falls between two of
them rather than through a card. `even: true` drops an odd count by one.

### Arabic

![The same screen in English and Arabic: the column stays on the right](doc/images/arabic.png)

Nothing to do: the column is a physical part of the glass and stays on the
same side, while the content mirrors as usual.

### With `flutter_screenutil`

Replace a fixed `designSize` with `DuoDesignSize.forWindow`. The Arabic README
has a complete `WindowScreenUtil` you can copy.

```dart
DuoDesignSize.forWindow(
  windowSize,
  phoneFrame: const Size(390, 844), // your Figma frame
  insets: windowInsets,
)
```

- **On the outer screen**, it scales by the width beside the column.
- **On a tablet or the open Duo**, it draws the design's points 1:1.

## How it knows

Flutter on iOS gets nothing about the Duo, so `BarEdge.of` reads the safe
area: when one side is inset deeper than the top and the other side is 0,
the status bar runs down that side.

| Device | Insets | `barEdge` |
|---|---|---|
| iPhone, upright | top 47, bottom 34 | `null` |
| iPhone, on its side | left 47, right 47 | `null` |
| iPad | top 24, bottom 20 | `null` |
| Duo, open upright | top, bottom | `null` |
| Duo, closed | right 84, bottom 34 | `right` |
| Duo, open on its side | right 84, bottom 34 | `right` |

## Limits

- **Where the column's first button sits.** `SideToolbar.defaultTop` is 160
  on the outer screen and 104 on the inner one. iOS gives no figure, so these
  are measured on the simulator (iOS 27.1); pass `top:` if a device differs.
- **No half-open (laptop) posture.** Flutter can't read the hinge angle on
  iOS.
- **No "…" overflow menu yet.** Keep three or four buttons in the column.
- **Android foldables** have no side column, so `barEdge` is `null` there.
  `TwoPane` and `WindowClass` work on any wide window.

## Try it

```bash
cd example
flutter run -d "iPhone Duo"
```

Run the tests with `flutter test`. To regenerate the README's pictures, run
this on a Mac (it loads San Francisco from macOS):

```bash
cd example
flutter test test/screenshots_test.dart --update-goldens
```

## Roadmap

- [ ] A "…" overflow menu for the column
- [ ] Hero images that extend under the column
- [ ] Switch to an official API once Flutter offers one
