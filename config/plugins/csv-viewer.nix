{pkgs, ...}:
{
  plugins.csvview = {
    enable = true;
    settings = {
      display_mode = "border";
    };
  };
}
