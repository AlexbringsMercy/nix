# Wallpapers and adaptive colors

The image library is personal machine-local data. Git manages the picker and
theme pipeline, but it does not contain wallpaper binaries. The curated folder
is `/home/alex/Pictures/Wallpapers/aurora-collection`; the originals in
`/home/alex/Downloads` remain untouched.

## First test batch

| Palette | Managed filename | Expected primary | SHA-256 |
|---|---|---|---|
| Red | `red-mountain-moon-lake.webp` | `#ffb2b8` | `d68e50ad132429f240736f60d9184d49380c7132fcf4112828dc4fd57c6a57be` |
| Orange | `orange-pixel-dojo.png` | `#ffb5a0` | `6603fbb338727ba5248dfe885c25b22824274c7bc22a1dfaae2c7bcbfe13868e` |
| Gold | `gold-misty-graveyard.jpeg` | `#e9bf8e` | `9385ffb07af807497a9d10aadce9fe8ea8175d54c933c64a171f32fe31d2e86f` |
| Olive | `olive-erdtree-castle.jpeg` | `#ccc993` | `8c9b6c46a65bdda490e4ffabbcb159a84ea16409932fbadcb4d95ce7f62ef232` |
| Green | `green-aurora-lake.jpg` | `#cfffb5` | `ddc59fd0ac8066b7c0ae92347536cabd8fceefcc4593d8e6c5d67dc7cfd8125a` |
| Seafoam | `seafoam-moonlit-mountain.webp` | `#84d7b5` | `b74f80b63ff721ef46fe54b7e0351180a01552a46c315544ddbc7de17b66bf88` |
| Cyan | `cyan-raya-lucaria.jpeg` | `#98cfe2` | `bb281ec8a506fbab9d16c02aaa5ef019eaa7f0ab5c0c21dadbea6533e9038f98` |
| Blue | `blue-aurora-light.jpg` | `#9fcaff` | `d79735520b480717301c561ea7673ad870d4051c618847486939e478c6eb81dc` |
| Violet | `violet-nokstella-stars.jpeg` | `#c3c1f8` | `7e3127dc054e9bd84ac37906ede36094f30a58cec0f4238d61dda48cc4770821` |
| Purple | `purple-misty-highlands.jpeg` | `#d3c0dd` | `eeea7ca423091bf16d3bf8c180a065e3592722bea4f0a6f86e44853235b1ed15` |
| Neutral dark | `neutral-somerville-horizon.jpg` | `#c2c7cb` | `36c4ac3f9e43388cf6e6be4afce375af15e6bfad63642b8160248e487161fbff` |
| Neutral light | `light-colossus-hawk.jpg` | `#e0e6d6` | `84b3284ce9ef83cbd1b26888057b858b646d4e76a4f38571112c6ab3a54dc932` |

These are measured Matugen dark-scheme primaries, not labels inferred from the
filenames. Every entry is a verified copy of an existing file in `~/Downloads`;
the hashes above identify the machine-local copies without tracking the images.

### Original copy mapping

| Managed filename | Original filename in `~/Downloads` |
|---|---|
| `red-mountain-moon-lake.webp` | `mountain-landscapes-lake-bloodred-wallpaper.webp` |
| `orange-pixel-dojo.png` | `pixel-dojo-red-wallpaper.png` |
| `gold-misty-graveyard.jpeg` | `elden-ring-misty-graveyard-burn-orange-wallpaper.jpeg` |
| `olive-erdtree-castle.jpeg` | `elden-ring-shadow-of-erdtree-yellow-wallpaper.jpeg` |
| `green-aurora-lake.jpg` | `aurora-wallpaper-option.jpg` |
| `seafoam-moonlit-mountain.webp` | `mountain-landscapes-lake-green-wallpaper.webp` |
| `cyan-raya-lucaria.jpeg` | `raya-lucaria-wispy-blue+red-particles-elden-ring-wallpaper.jpeg` |
| `blue-aurora-light.jpg` | `aurora-wallpaper-option3.jpg` |
| `violet-nokstella-stars.jpeg` | `nokstella-elden-ring-purple-starry.jpeg` |
| `purple-misty-highlands.jpeg` | `elden-ring-landscape-red-particles-wallpaper.jpeg` |
| `neutral-somerville-horizon.jpg` | `somerville-wallpaper-landscape+houses-wallpaper.jpg` |
| `light-colossus-hawk.jpg` | `shadow-of-the-collosus-wallpaper-hawk.jpg` |

The initial default is `violet-nokstella-stars.jpeg`.

## Selection pipeline

Choosing an image in Waypaper calls `apply-wallpaper`. The command locks the
theme state, renders a dark `scheme-content` palette with Matugen, validates all
generated fragments, and atomically installs themes for QuickShell, Waybar,
Kitty, Rofi, Hyprland, Hyprlock, GTK, and the Dunst fallback. It then stores the
selection and changes the background through awww.

Stable near-black surface roles preserve the frosted-glass foundation. Matugen's
dominant source color drives semantic primary, secondary, and tertiary accents,
so different images produce visibly different themes without sacrificing dark
contrast.

QuickShell watches its JSON palette. Waybar and Hyprland reload after a normal
wallpaper change, and the small SwayOSD/Dunst services restart only if already
active. Rofi, Hyprlock, GTK clients, and new Kitty windows read the new fragments
when they next open. The screenshot selector also reads the current primary and
tertiary accents. Existing Kitty windows are intentionally not signaled.
