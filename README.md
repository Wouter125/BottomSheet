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
- [x] Custom snap threshold
- [x] Dynamically exclude snap positions
- [x] Dynamically disable and enable dragging  

## How to install

Currently BottomSheet is only available through the [Swift Package Manager](https://swift.org/package-manager/) or manual install. 

1. Installation through Swift Package Manager can be done by going to `File > Add Packages`. Then enter the following URL in the searchbar; `github.com/Wouter125/BottomSheet`.

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

5. Optionally tweak the animation curve / snap threshold with a view modifier or receive the current panel position with a callback;

```
BottomSheetView(
    position: $position,
    header: { }
    content: { }
}
.animationCurve(mass: 1, stiffness: 250)
.snapThreshold(1.8)
.onBottomSheetDrag { translation in
    print("Translation", translation)
}
```

## Interface

| Modifier                 | Type                | Default | Description                                                                       |
|--------------------------|---------------------|---------|-----------------------------------------------------------------------------------|
| snapThreshold            | Double              | 1.8     | The threshold to let the drag gesture ignore the distance. Value between 0 and 3. |
| animationCurve.mass      | Double              | 1.2     | The mass of the object attached to the spring.                                    |
| animationCurve.stiffness | Double              | 200     | The stiffness of the spring.                                                      |
| animationCurve.damping   | Double              | 25      | The spring damping value.                                                         |
| isDraggable              | Boolean             | true    | Whether you can drag the BottomSheet or not.                                      |
| excludeSnapPositions     | Array<PositionEnum> | []      | An array that contains the enum positions that you want to exclude when snapping  |

## Example

To give you an idea of how to use this library you can use the example that is attached to this repo. Simply clone it and open the `BottomSheetExample` folder in Xcode.

## Roadmap

1. Add landscape support
2. Add iPad support
