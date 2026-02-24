
# Widget usage

## Display Widgets

Display widgets render output and do not collect user input.

---

### Text

Renders a single line of text to the terminal. Provides static convenience
methods for common semantic styles.

```dart
// Plain body text
Text.body('Hello, world!');

// Semantic variants (icon + color)
Text.success('Deployment complete');
Text.warning('This will overwrite existing files');
Text.error('Something went wrong');

// Custom style
Text('My label', style: TextStyle(bold: true)).write();
```

```template
Hello, world!
✔ Deployment complete
⚠ This will overwrite existing files
✘ Something went wrong
```

---

### Sign

Wraps `List<StyledText>` content in a configurable border with padding,
margin, and automatic word-wrap.

```dart
Sign(
  content: [
    StyledText('Title', style: TextStyle(bold: true)),
    StyledText('Some longer text that will wrap automatically.'),
  ],
  padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
).write();
```

```template Border.all (default: SignStyle.rounded)
╭──────────────────────╮
│                      │
│ Title                │
│ Some longer text     │
│ that will wrap       │
│ automatically.       │
│                      │
╰──────────────────────╯
```

```template Border.left (SignStyle.left)
│ Title
│
│ Some longer text
│ that will wrap
│ automatically.
```

**Parameters:**
- `content` — `List<StyledText>` to display (each entry is word-wrapped)
- `style` — `SignStyle` border character set (default: `SignStyle.rounded`)
- `padding` — inner padding between border and content (default: `horizontal: 1`)
- `margin` — outer margin; left/right reduces width, top/bottom adds blank lines
- `width` — explicit inner content width; derived from terminal width if `null`
- `borderStyle` — optional `TextStyle` applied to border characters

---

### Table

Renders tabular data with configurable borders, column alignment, and
per-cell styling.

```dart
Table(
  headers: ['Name', 'Status'],
  rows: [
    ['auth-service', StyledText('running', style: TextStyle(foreground: Color.green))],
    ['db-worker',   StyledText('stopped', style: TextStyle(foreground: Color.red))],
  ],
  style: TableStyle.rounded,
).write();

// Convenience static method
Table.send(headers: ['Setting', 'Value'], rows: [...]);
```

```template
╭──────────────┬─────────╮
│ Name         │ Status  │
├──────────────┼─────────┤
│ auth-service │ running │
│ db-worker    │ stopped │
╰──────────────┴─────────╯
```

**Parameters:**
- `headers` — column header labels
- `rows` — list of rows; each cell can be a `String` or `StyledText`
- `style` — `TableStyle` border set (default: `TableStyle.rounded`)
- `headerStyle` — `TextStyle` for header cells (default: bold)
- `columnAlignments` — per-column `ColumnAlignment` (left/right/center); missing columns default to left

---

### Spinner

A pure spinner animation primitive. Renders an animated frame on the current
line. Call `stop()` to end the animation and show a result icon.

```dart
final spinner = Spinner();
spinner.write();           // starts animation
await doSomeWork();
spinner.stop();            // shows ✔
spinner.stop(success: false); // shows ✘
```

```template (animating)
⠸
```

```template (stopped, success)
✔
```

---

### SpinnerTask

Composes `Spinner` with a label and an async task. Displays the spinner
while the task runs, then shows ✔ or ✘.

```dart
final result = await SpinnerTask<String>(
  label: 'Installing dependencies',
  task: () async {
    await Future.delayed(Duration(seconds: 2));
    return 'done';
  },
).write();

// Convenience static method
await SpinnerTask.send(
  label: 'Building project',
  task: () async => build(),
);
```

```template (running)
⠸ Installing dependencies
```

```template (done)
✔ Installing dependencies
```

---

## Interactive Widgets

Interactive widgets collect user input and return a typed value via `write()`.
All interactive widgets share these common parameters:

- `label` — the prompt title (required)
- `help` — optional description shown below the label
- `defaultValue` — pre-filled value shown before the user types
- `validator` — `Validator<T>` function; return an error string or `null`
- `theme` — optional `Theme` override

---

### Prompt

A single-line text input prompt.

```dart
final name = Prompt(
  label: 'Project name',
  help: 'Used as the package name',
  defaultValue: 'my_app',
  validator: (v) => v.isEmpty ? 'Name cannot be empty' : null,
).write();

// Convenience static method
final name = Prompt.send('Project name', defaultValue: 'my_app');
```

```template (awaiting input)
Project name
Used as the package name
  ❯ my_app
```

```template (done)
Project name
  ✔ my_app
```

**Keys:** type to input, Backspace to delete, Enter to submit.

---

### ConfirmInput

A yes/no confirmation prompt. The user presses `y`/`n` or Enter to accept
the default.

```dart
final ok = ConfirmInput(
  label: 'Delete everything?',
  defaultValue: false,
).write();

// Convenience static method
final ok = ConfirmInput.send('Delete everything?', defaultValue: false);
```

```template (awaiting, default=false)
Delete everything?
  ❯ (y/N)
```

```template (done, answered yes)
Delete everything?
  ✔ Yes
```

**Keys:** `y`/`Y` for yes, `n`/`N` for no, Enter to accept default.

---

### Select

A single-choice select list. Arrow keys navigate, Enter confirms.

```dart
final lang = Select<String>(
  label: 'Pick a language',
  options: [
    Option(label: 'Dart', value: 'dart'),
    Option(label: 'Go',   value: 'go'),
    Option(label: 'Rust', value: 'rust'),
  ],
).write();

// Convenience static method
final lang = Select.send<String>(
  label: 'Pick a language',
  options: [...],
);
```

```template (awaiting)
Pick a language
  ❯ Dart
    Go
    Rust
```

```template (done)
Pick a language
  ✔ Dart
    Go
    Rust
```

**Keys:** ↑/↓ to navigate, Enter to confirm.

---

### Multiselect

A multi-choice select list. Arrow keys navigate, Space toggles, Enter confirms.

```dart
final features = Multiselect<String>(
  label: 'Pick features',
  options: [
    Option(label: 'Linting',  value: 'lint'),
    Option(label: 'Testing',  value: 'test'),
    Option(label: 'CI/CD',    value: 'ci'),
  ],
).write();

// Convenience static method
final features = Multiselect.send<String>(
  label: 'Pick features',
  options: [...],
);
```

```template (awaiting)
Pick features
  ❯ ◉ Linting
    ◯ Testing
    ◯ CI/CD
```

```template (done)
Pick features
    ✔ Linting
    ◯ Testing
    ◯ CI/CD
```

**Keys:** ↑/↓ to navigate, Space to toggle, Enter to confirm.

---

## Container Widgets

Container widgets compose multiple interactive widgets together.

---

### Group

Renders multiple widgets together on one "page", routing key events to the
focused widget. Tab/Enter advances focus; Shift+Tab goes back.

```dart
final results = Group([
  Prompt(label: 'Name'),
  Select(label: 'Language', options: [...]),
  ConfirmInput(label: 'Use git?'),
]).write();

// results[0] = 'MyApp'   (String)
// results[1] = 'dart'    (T)
// results[2] = true      (bool)

// Convenience static method
final results = Group.send([...]);
```

```template
Name
  ❯ my_app

Language
  ❯ Dart
    Go

Use git?
  ❯ (Y/n)
```

**Keys:** Tab or Enter to advance to next field, Shift+Tab to go back.

---

### Form

A multi-page form container. Each page can be a `Group` or a single
`InteractiveWidget`. Advances automatically when a page completes.
Displays an optional title with page indicator, a guide line, and an
error line at the bottom.

```dart
final results = Form([
  Group([
    Prompt(label: 'Name'),
    Select(label: 'Language', options: [...]),
  ]),
  Multiselect(label: 'Features', options: [...]),
  ConfirmInput(label: 'Use git?'),
], title: 'New Project').write();

// Convenience static method
final results = Form.send(children: [...], title: 'New Project');
```

```template (page 1 of 3)
  New Project (page 1/3)

  Name
    ❯ my_app

  Language
    ❯ Dart
      Go

  up/down to select, enter to submit
  ✘ error message (if any)
```