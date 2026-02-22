# Howdy CLI

Howdy CLI is a powerful, declarative, and highly themeable terminal UI framework for Dart. It provides a robust set of interactive widgets, seamless terminal I/O management, and a flexible theming API to build beautiful command-line applications.

I was heavily inspired by / ripped off [Huh?](https://github.com/charmbracelet/huh)

<gif>

```dart




```



- **Extendible:** Use built in widgets or write your own.
- **Declarative Components:** Easily build forms and interactive prompts.
- **Theming System:** Centralized styling for colors, borders, icons, and text.
- **Low-Level Terminal Control:** Exposed primitive terminal functions for cursors, escape sequences, and screen buffers.

---

## 2. Included Widgets

Howdy CLI comes with a rich set of built.in widgets for both collecting input and displaying output.

**Interactive Interfaces:**
- `Prompt`: A single-line text input field.
- `Textarea`: A multi-line text input field.
- `Select`: A single-choice list of options.
- `MultiSelect`: A multiple-choice list of options.
- `ConfirmInput`: A boolean yes/no confirmation prompt.

**Display & Structure:**
- `Text`: A simple styled text widget.
- `Sign`: A bounded, styled box with padding and wrapping for displaying information.
- `Table`: A widget to display tabular data with customizable borders and column widths.
- `Spinner` / `SpinnerTask`: A progress indicator or asynchronous task wrapper.

**Compositing Containers:**
- `Group`: Groups multiple widgets logically and visually.
- `Form`: A multi-page container that orchestrates multiple `Group` widgets and manages their state and validation.

---

## 3. Write Your Own Widgets

You can easily build custom widgets by extending the base classes provided by the framework.

- **`Widget<T>`**: The foundation of all widgets. It requires overriding `build(IndentedStringBuffer buf)` for defining the visual state, and `write()` for standalone rendering.
- **`InteractiveWidget<T>`**: Extend this for input widgets. You must override:
  - `T get value`: Returns the current value.
  - `KeyResult handleKey(KeyEvent event)`: Processes terminal keystrokes. Returns `KeyResult.consumed`, `KeyResult.ignored`, or `KeyResult.done`.
- **`DisplayWidget`**: Extend this for output-only components that do not interact with user input.

```dart
class MyCustomWidget extends InteractiveWidget<String> {
  MyCustomWidget({required super.label});

  @override
  String get value => 'My Value';

  @override
  KeyResult handleKey(KeyEvent event) {
    // Check event and return KeyResult
    return KeyResult.done;
  }

  @override
  String build(IndentedStringBuffer buf) {
    buf.write('Hello Custom Widget');
    return buf.toString();
  }
}
```

---

## 4. Themes

Howdy CLI features a centralized hierarchical theming API. This ensures consistent styling across all widgets, managing focus and blur states automatically.

### Included Themes

Out of the box, the following themes are provided:
- `Theme.charm()`: The default, vibrant theme.
- `Theme.standard()`: A minimal theme using standard base terminal colors.
- `Theme.dracula()`: Based on the popular Dracula color scheme.
- `Theme.base16()`: A 16-color ANSI palette theme.
- `Theme.catppuccin()`: Based on the Catppuccin Mocha color scheme.

### Using Theme API to Write Your Own

You can create a custom theme by instantiating the `Theme` class and providing specific `FieldStyles`, `GroupStyles`, and `FormStyles`.

```dart
final myTheme = Theme(
  focused: FieldStyles(
    text: TextStyles(
      prompt: TextStyle(foreground: Color.blue, bold: true),
    ),
    // ...other styles
  ),
  blurred: FieldStyles(/*...*/),
);
```

### 4.1 Colors, border styles, padding, text styles, icons

Themes are composed using structural styling primitives:
- **Colors**: ANSI and RGB colors via the `Color` class (e.g., `Color.redLight`, `Color.magenta`).
- **Text Styles**: Apply foreground/background colors, boldness, dimming, and italics to text using `TextStyle`. Can be quickly applied using the `.style(...)` string extension.
- **Border Styles**: Configure characters used for widget bounding boxes with `BorderType` (e.g., standard, rounded).
- **Padding/Margin**: Control spatial rules with `EdgeInsets` (e.g., `EdgeInsets.all(1)`).
- **Icons**: Easily retrieve cross-platform terminal icons (like `Icon.dot`, `Icon.pointer`, `Icon.check`) via the `Icon` class.

---

## 5. Terminal Functionality Exposed

The framework exposes raw terminal manipulation via the `Terminal` singleton and helper methods for advanced command-line UI creation.

- **Raw Mode (`enableRawMode`, `runRawMode`)**: Bypasses terminal line buffering to read individual keystrokes (useful for custom interactive widgets).
- **Key Event Parsing (`readKeySync`)**: Automatically translates complex ANSI escape sequences into `KeyEvent` objects like `SpecialKey(Key.arrowUp)`.
- **Screen Buffer Management (`updateScreen`, `clearScreen`)**: Effortlessly redraws the screen without flickering, automatically counting physical lines for efficient screen erasure.
- **Cursor Control**: Directly control the cursor shape (`CursorShape.blinkingBar`, `CursorShape.steadyBlock`) and position (`cursorUp`, `cursorDown`, `cursorHide`, `cursorShow`).
- **Erasing**: Exposed constants and methods for clearing the screen (`eraseLine`, `eraseScreenDown`, etc.).
- **Signal Handling**: Robust teardown logic ensures that when the script receives a `SIGINT` (Ctrl+C), raw mode is disabled and the cursor is cleanly restored.
