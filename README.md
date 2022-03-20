# BottomSheet

An iOS library for SwiftUI to create draggable sheet experiences similar to iOS applications like Maps and Stocks. 

## Feature overview 

The library currently supports;

- [x] Unlimited snap positions
- [x] Realtime position callback
- [x] Absolute and relative positioning
- [x] Customizable animation parameters
- [x] An optional sticky header
- [x] Views with and without a scrollview

## How to install

Currently BottomSheet is only available through the [Swift Package Manager](https://swift.org/package-manager/) or manual install. 

1. Installation through Swift Package Manager can be done by going to `File > Add Packages`. Then enter the following URL in the searchbar; `https://github.com/Wouter125/BottomSheet`.

2. Manual installation can be done by cloning this repository and dragging all assets into your Xcode Project.

## How to use

1. Import BottomSheet

2. Create a custom enum with all snap positions. It can be relative or absolute. Order does not matter. Absolute positioning should look something like this;

```
enum BottomSheetPosition: CGFloat, CaseIterable {
    case bottom = 182
    case middle = 320
    case top = 700
}
```

Relative positioning should always be between 0 and 1 and can look like this;

```
enum BottomSheetRelativePosition: CGFloat, CaseIterable {
    case bottom = 0.216
    case middle = 0.355
    case top = 0.829
}
```

3. Create a state property that contains the bottom sheet start position;

```
@State var position: BottomSheetPosition = .middle
```

4. Add the `BottomSheetView` to your SwiftUI view hierachy;

```
BottomSheetView(
    position: $position,
    header: { }
    content: { }
}
```

5. Optionally tweak the animation curve with a view modifier, or receive the current panel position with a callback;

```
BottomSheetView(
    position: $position,
    header: { }
    content: { }
}
.animationCurve(mass: 1, stiffness: 250)
.onBottomSheetDrag { translation in
    print("Translation", translation)
}
```

## Example

To give you an idea of how to use this library you can use the example that is attached to this repo. Simply clone it and run the `BottomSheetExample` target.
