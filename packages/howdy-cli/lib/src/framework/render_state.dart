typedef RenderOptions = ({
  bool isFocused,
  bool isComplete,
  bool isFormElement,
  bool hasError,
});

enum RenderState {
  // incomplete and out of focus, implies no error, doesn't care about context.
  waiting,

  // implies incomplete and infocus without error?
  editing,

  // implies incomplete and infocus
  hasError,

  // error is auto false, renderContext doesn't matter
  // complete and has focus
  verified,

  //
  complete
  ;

  static RenderState get(RenderOptions options) {
    return switch (options) {
      (
        isFocused: false,
        isComplete: false,
        isFormElement: _,
        hasError: false,
      ) =>
        RenderState.waiting,
      (
        isFocused: true,
        isComplete: false,
        isFormElement: _,
        hasError: false,
      ) =>
        RenderState.editing,
      (
        isFocused: _,
        isComplete: _,
        isFormElement: _,
        hasError: true,
      ) =>
        RenderState.hasError,
      (
        isFocused: true,
        isComplete: true,
        isFormElement: _,
        hasError: _,
      ) =>
        RenderState.verified,
      (
        isFocused: false,
        isComplete: true,
        isFormElement: _,
        hasError: _,
      ) =>
        RenderState.complete,
    };
  }
}

void mapRenderStateToTheme(
  RenderState state,
) {}
