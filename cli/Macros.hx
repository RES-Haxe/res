package cli;

class Macros {
  public static macro function buildDate() {
    return macro $v{Date.now().toString().split(' ')[0]};
  }
}
