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

1. Installation through Swift Package Manager can be done by going to `File > Add Packages`. Then enter the following URL in the searchbar; `github.com/Wouter125/BottomSheet`.

2. Manual installation can be done by cloning this repository and dragging all assets into your Xcode Project.

## How to use

1. Import BottomSheet

2. Create a state property that contains the presentation state of the bottom sheet and one for the current selection;

```
@Published var isPresented = false
@Published var selectedDetent: BottomSheet.PresentationDetent = .medium
```

4. Add the `BottomSheetView` to your SwiftUI view hierachy by using a view modifier;

```
.sheetPlus(
    isPresented: $isPresented,
    header: { },
    main: { 
        EmptyView()
            .presentationDetentsPlus(
                [.height(244), .fraction(0.4), .medium, .large],
                selection: $selectedDetent
            )
    }
)
```

5. Optionally receive the current panel position with a callback, set a custom background or change the animation curves;

```
BottomSheetView(
    position: $position,
    animationCurve: SheetAnimation(
        mass: 1,
        stiffness: 250,
        damping: 25
    ),
    background: (
        Color(UIColor.secondarySystemBackground)
    ),
    header: { },
    content: {
        EmptyView()
            .onSheetDrag(translation: $settings.translation)
    }
}
```

## Interface

| Modifier                 | Type                | Default | Description                                                                       |
|--------------------------|---------------------|---------|-----------------------------------------------------------------------------------|
| animationCurve.mass      | Double              | 1.2     | The mass of the object attached to the spring.                                    |
| animationCurve.stiffness | Double              | 200     | The stiffness of the spring.                                                      |
| animationCurve.damping   | Double              | 25      | The spring damping value.                                                         |

## Example

To give you an idea of how to use this library you can use the example that is attached to this repo. Simply clone it and open the `BottomSheetExample` folder in Xcode.

## Roadmap

1. Add landscape support
2. Add iPad support
