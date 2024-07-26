{
  description = "Theme your NixOS configuration consistently.";

  outputs = {self}: let
    raw = import ./themes.nix;

    isValidColor = thing:
      if builtins.isString thing
      then (builtins.match "^[0-9a-fA-F]{6}" thing) != null
      else false;

    hexToRgb = hex: {
      r = builtins.fromJSON ("0x" + builtins.substring 0 2 hex);
      g = builtins.fromJSON ("0x" + builtins.substring 2 2 hex);
      b = builtins.fromJSON ("0x" + builtins.substring 4 2 hex);
    };

    rgbToHex = rgb: let
      toHex = x: builtins.substring 2 2 (builtins.toString (0 x100 + x));
    in
      toHex rgb.r + toHex rgb.g + toHex rgb.b;

    blend = color1: color2: let
      rgb1 = hexToRgb color1;
      rgb2 = hexToRgb color2;
      blendedRgb = {
        r = (rgb1.r + rgb2.r) / 2;
        g = (rgb1.g + rgb2.g) / 2;
        b = (rgb1.b + rgb2.b) / 2;
      };
    in
      rgbToHex blendedRgb;
  in
    {
      inherit raw;

      custom = theme: let
        with0x =
          theme
          // (builtins.mapAttrs (_: value:
            if isValidColor value
            then "0x" + value
            else value)
          theme);
        withHashtag =
          theme
          // (builtins.mapAttrs (_: value:
            if isValidColor value
            then "#" + value
            else value)
          theme);

        themeFull =
          theme
          // {
            inherit with0x withHashtag;
          };
      in
        themeFull
        // {
          adwaitaGtkCss = (import ./templates/adwaitaGtkCss.nix) themeFull;
          btopTheme = (import ./templates/btopTheme.nix) themeFull;
          discordCss = (import ./templates/discordCss.nix) themeFull;
          firefoxTheme = (import ./templates/firefoxTheme.nix) themeFull;
          ghosttyConfig = (import ./templates/ghosttyConfig.nix) themeFull;
          tmTheme = (import ./templates/tmTheme.nix) themeFull;
          dmenuTheme = (import ./templates/dmenuTheme.nix) themeFull;
          blend = blend;
        };
    }
    // builtins.mapAttrs (name: self.custom) raw;
}
