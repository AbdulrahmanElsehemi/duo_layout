## 0.2.0

* An iOS plugin that asks iOS 27.1 about the iPhone Duo: the side of the
  status bar's column (`verticalBarEdge`), the hinge (`UIHingeInteraction`),
  and the fold and camera regions (`reservedRegions`). Read it with
  `DuoDevice.of(context)`: `hinge`, `fold`, `occlusions`, `posture`
  (closed, tabletop, book, flat).
* `context.barEdge` takes the column's side from iOS when it says, and
  still guesses from the safe area before iOS 27.1, off iOS and in tests.
* `DuoDevice.regionsOf(context)` reads the same without the hinge, so a
  layout doesn't rebuild many times a second while the Duo folds.
* `TwoPane` splits at the fold iOS reports.
* `SideToolbar` starts its column under the clock and camera iOS reports
  (`SideToolbar.topOf`); `defaultTop` is now the fallback.
* Needs Flutter 3.44 or later.
* The README is in English only, with a full guide.

## 0.1.0

* First release, taken out of a shop app running on the iPhone Duo:
  `DuoScope`, `BarEdge` / `BarEdgeScope`, `SideTabBar`, `SideToolbar` /
  `SideToolbarButton`, `DuoAppBar`, `TwoPane`, `EdgeBleed`, `WindowClass` /
  `DuoBreakpoints`, `DuoDesignSize`.
* An example app, and the README's pictures drawn from it.
