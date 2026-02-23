/// The four boolean axes that are combined to produce a [RenderState].
///
/// Passed as a named-record to [RenderState.get] so the pattern-match
/// remains readable without positional confusion.
typedef RenderOptions = ({
  bool isFocused,
  bool isComplete,
  bool isFormElement,
  bool hasError,
});

/// Describes the visual / behavioural state a widget is in when [build] runs.
///
/// Each value encodes four orthogonal axes — focus, completion, form-context,
/// and error — as constructor arguments so the enum itself is the single
/// source of truth.  Derive the correct value from live widget properties by
/// calling [RenderState.get].
///
/// Widget `build` methods switch on this value to decide which chrome to
/// render (usage hints, error banners, etc.) and where ownership of that
/// chrome lies (the widget itself when standalone, the parent [Form] when
/// inside one).
enum RenderState {
  /// Standalone widget, not yet interacted with.
  ///
  /// The widget is unfocused, incomplete, and has no error.  The user has
  /// not started editing yet (e.g. it is queued below the active field).
  waiting(false, false, false, false),

  /// Form-hosted widget that is waiting for focus.
  ///
  /// Same as [waiting] but the widget lives inside a [Form], so the form
  /// owns the surrounding chrome.
  waitingInForm(false, false, true, false),

  /// Standalone widget actively receiving input.
  ///
  /// The widget is focused, incomplete, and error-free.  The widget itself
  /// renders usage hints below the input area.
  editing(true, false, false, false),

  /// Form-hosted widget actively receiving input.
  ///
  /// Same as [editing] but the widget lives inside a [Form]; the form
  /// renders surrounding chrome instead of the widget.
  editingInForm(true, false, true, false),

  /// Standalone widget with a validation error.
  ///
  /// Focus and completion are irrelevant — the error flag takes priority.
  /// The widget renders the error message below the input area.
  error(true, false, false, true),

  /// Form-hosted widget with a validation error.
  ///
  /// Same as [error] but the widget lives inside a [Form]; the form
  /// renders the error banner instead of the widget.
  errorInForm(true, false, true, true),

  /// Standalone widget whose value has been confirmed by the user.
  ///
  /// The widget is focused (just submitted) and complete, with no error.
  /// It renders a success line and retains its chrome until the next widget
  /// takes over.
  verified(true, true, false, false),

  /// Form-hosted widget whose value has been confirmed.
  ///
  /// Same as [verified] but inside a [Form]; the form controls the
  /// success / completion chrome.
  verifiedInForm(true, true, true, false),

  /// Widget that is complete but no longer focused.
  ///
  /// Applies inside a [Form] once the user moves past this field.  The
  /// form retains ownership of chrome; the widget renders a compact
  /// completed summary only.
  completeInForm(false, true, true, false)
  ;

  // ── Fields ──────────────────────────────────────────────────────────────

  /// Whether the widget currently has keyboard focus.
  final bool isFocused;

  /// Whether the widget's value has been submitted and validated.
  final bool isComplete;

  /// Whether the widget is hosted inside a [Form] (vs. used standalone).
  ///
  /// When `true`, the parent form owns surrounding chrome such as usage
  /// hints and error banners; the widget should not render them itself.
  final bool isFormElement;

  /// Whether the widget is currently displaying a validation error.
  final bool hasError;

  const RenderState(
    this.isFocused,
    this.isComplete,
    this.isFormElement,
    this.hasError,
  );

  // ── Factory ─────────────────────────────────────────────────────────────

  /// Derives the correct [RenderState] from live widget properties.
  ///
  /// Call this inside a widget's `renderState` getter, passing the widget's
  /// current [isFocused], [isComplete], [isFormElement], and [hasError]
  /// values as the named-record [options].  The pattern-match exhaustively
  /// covers every reachable combination.
  static RenderState get(RenderOptions options) {
    return switch (options) {
      (
        isFocused: false,
        isComplete: false,
        isFormElement: false,
        hasError: false,
      ) =>
        RenderState.waiting,
      (
        isFocused: false,
        isComplete: false,
        isFormElement: true,
        hasError: false,
      ) =>
        RenderState.waitingInForm,
      (
        isFocused: true,
        isComplete: false,
        isFormElement: false,
        hasError: false,
      ) =>
        RenderState.editing,
      (
        isFocused: true,
        isComplete: false,
        isFormElement: true,
        hasError: false,
      ) =>
        RenderState.editingInForm,
      (
        isFocused: _,
        isComplete: _,
        isFormElement: false,
        hasError: true,
      ) =>
        RenderState.error,
      (
        isFocused: _,
        isComplete: _,
        isFormElement: true,
        hasError: true,
      ) =>
        RenderState.errorInForm,
      (
        isFocused: true,
        isComplete: true,
        isFormElement: false,
        hasError: _,
      ) =>
        RenderState.verified,
      (
        isFocused: true,
        isComplete: true,
        isFormElement: true,
        hasError: _,
      ) =>
        RenderState.verifiedInForm,
      (
        isFocused: false,
        isComplete: true,
        isFormElement: _,
        hasError: _,
      ) =>
        RenderState.completeInForm,
    };
  }
}
