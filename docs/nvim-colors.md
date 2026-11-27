# Neovim startup colors

The Lua configuration uses `vim.fn.rand()` for both the theme and the optional
boo variant. This retains the original Vimscript `rand()` behavior without
reseeding the Lua PRNG used by plugins. An explicitly set `g:colors_name` still
takes precedence, and light/VS Code mode retains its existing selection rules.

On 2026-11-25, Neovim 0.12.5 with LuaJIT 2.1.1788856981 returned the identical
first two `math.random()` values in separate clean processes. The Lua port used
that generator without calling `math.randomseed()`, so an unchanged startup
sequence repeatedly selected the same theme. The issue was not a later
colorscheme assignment in the machine-local vimrc.

After switching to the native seeded generator, 16 independent minimal Neovim
processes running the actual selection helpers and theme list selected multiple
themes. A separate check confirmed that the existing explicit-theme guard
still prevents replacement. These probes did not load the full plugin setup.

## Telescope previews

Telescope buffer previews use a fixed Dark+-style palette: `#1e1e1e`
background, `#d4d4d4` text, and explicit comment/string/keyword/type colors.
Both RGB and terminal color values are provided. The private
`TelescopeReadablePreview` highlight namespace is assigned only to windows
whose `winhighlight` marks them as `TelescopePreviewNormal`; editor, prompt and
results windows retain the selected global theme.

The `TelescopePreviewerLoaded` hook handles new and cached preview buffers.
The `ColorScheme` hook reapplies fixed highlights, including registered
language-specific Tree-sitter captures, without changing global definitions.
This uses Neovim window highlight namespaces and adds no theme dependency.

Verified with Telescope `5255aa2` on 2026-11-25: a real file picker received
the private preview palette, an intentionally low-contrast `@string.lua`
capture was overridden only in the preview, global/editor highlights remained
unchanged, and the preview palette survived a global colorscheme switch.
