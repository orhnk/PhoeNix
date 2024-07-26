{
  description = "Theme your NixOS configuration consistently.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    raw = import ./themes.nix;

    isValidColor = thing:
      if builtins.isString thing
      then (builtins.match "^[0-9a-fA-F]{6}$" thing) != null
      else false;

    hexToRgb = hex: {
      r = builtins.parseInt (builtins.substring 0 2 hex) 16;
      g = builtins.parseInt (builtins.substring 2 2 hex) 16;
      b = builtins.parseInt (builtins.substring 4 2 hex) 16;
    };

    rgbToHex = rgb: let
      toHex = x: let
        hexStr = builtins.toString (builtins.bitAnd x nixpkgs.lib.fromHex "0xff");
      in
        if builtins.stringLength hexStr == 1
        then "0" + hexStr
        else hexStr;
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

      functions = {
        inherit blend;
      };

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
        };
    }
    // builtins.mapAttrs (name: self.custom) raw;
}
