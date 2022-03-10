# BottomSheet

An iOS library for SwiftUI to create draggable sheet experiences similar to iOS applications like Maps and Stocks. 

## Feature overview 

The library currently supports;

- [x] Unlimited snap positions
- [x] A realtime position callback
- [x] Manual positioning
- [x] Customizable animation parameters
- [x] A draggable sticky header
- [x] Works with a scrollview and without a scrollview

## How to install

Currently BottomSheet is only available through the [Swift Package Manager](https://swift.org/package-manager/) or manual install. 

1. Installation through Swift Package Manager can be done by going to `File > Swift Packages > Add Package Dependency`. Then enter the following line;

2. Manual installation can be done by cloning this repository and dragging all assets into your Xcode Project.

## How to use

1. Import BottomSheet

2. Create a custom enum with all snap positions. Order does not matter. It should look something like this;

```
enum BottomSheetPosition: CGFloat, CaseIterable {
    case bottom = 182
    case middle = 320
    case top = 700
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
