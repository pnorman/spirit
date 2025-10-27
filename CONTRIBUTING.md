# Street Spirit contribution guidelines

## Cartography

### Purpose

Street Spirit aims to be a general purpose map style for OpenStreetMap data, suitable
- for use as a locator map,
- to show off what can be done with OpenStreetMap data,
- to be up-to-date with the latest OpenStreetMap data, and
- for using to orient a viewer to a location they are at.

There is no ranking of these goals, and they may require compromises between the different goals.

It does not seek to
- be a suitable style for overlaying complex data on,
- drive OpenStreetMap tagging practices, or
- be a replacement for maps with a specialized topic.

### Cartographic guidelines

As this style doesn't aim to have data overlayed on it, it can use all the available cartographic space. It does not need to avoid particular colours or symbols, except for icons that look like typical locators pins, as these might be used by locator maps, and would be confusing regardless.

This enables a wider range of colour and saturation than typical general-purpose web maps, more similar to topographic maps and atlases.

### Technical targets

We target Maplibre GL JS usage as part of a web-page that is either focused on the map, or has the map as part of a larger page. Usage across desktops, tablets, and phones is supported, with support for high-DPI displays. Smart watches and print are not targeted.

## Code style

Street Spirit is written in [glug](https://github.com/systemed/glug), a text-based markup lanuage for MapLibre. Rubocop is used to enforce style requirements. It can be run with `bundle exec rubocop`.

The properties of a layer should be ordered
- `filter`,
- `*_sort_key`, and
- other properties.

### Fallbacks
When writing `match` expressions consider what will happen if new attributes are used. For example, with if writing a match expression for vegetation which could be one of `wood`, `hearth`, `scrub`, or `wetland`, consider what happens if `grass` is added. For debugging purposes a fallback should be `:red` or another bright color to highlight errors.

TODO: This will change to a special debugging color that can be switched between `:red` and a transparent color.

### Naming

Use underscores for names of layers, fields, and other names in the style. Don't use "-" as it requries special quoting sometimes.

Layers for labeling should end with the geometry type, i.e. `_line` or `_point`. The value might not always be a name, so don't use "_names". TODO: Not fully implemented

### Constants
For values coming from OSM tagging, wrap them in single quotations, e.g. `'motorway'` not `:motorway` or `"motorway"`. Constants coming from the MapLibre Style Language or Glug should use Ruby's `:` notation, e.g. `:exponential` instead of `'exponential'`.

## Icons

- All icons must be SVG, saved as standards compliant SVG without any proprietary tags. In Inkscape software, you will need to "Save As..." and choose the format Optimized SVG (preferable) or Plain SVG.
- Use a common canvas size, which is usually 15x15 px.
- Align vectors to the pixel grid.
- Make a clean design, so reduced complexity where possible.

## Colours

Work out colours in the LCH colour space, because RGB and other non-perceptual colourspaces are hard to reason about. TODO: Add colour functionality to Glug to do this easily.

The [chroma.js documentation](https://gka.github.io/chroma.js/) can function as a colour calculator.

![](docs/chromajs.png)

### Hues

Use a consistent hue angle for a class of features. The following hue angles are used in this style

<table>
<thead>
<tr>
<th>Features</th>
<th>Hue</th>
</tr>
</thead>
<tbody>
<tr>
<td>Water</td>
<td style="background:#4cb7e1;color:black">240°</td>
</tr>
<tr>
<td>Transit</td>
<td style="background:#006bce;color:white">280°</td>
</tr>
<tr>
<td>Admin borders</td>
<td style="background:#c25eb8;color:black">330°</td>
</tr>
<tr>
<td>Buildings</td>
<td style="background:#c1b994;color:#3e3c2c">100°</td>
</tr>
<tr>
<td>Food</td>
<td style="background:#ce7e03;color:#663d06">70°</td>
</tr>
</tbody>
</table>

## Required technical knowledge

Contributing to the style requires some technical knowledge in the following areas

- [MapLibre GL style specification](https://maplibre.org/maplibre-gl-js-docs/style-spec/), focusing on layers and expressions, including data-driven expressions;
- YAML, in particular appropriate indentation for arrays. MapLibre GL styles tend to feature deeply nested arrays; and
- SQL for writing read-only PostGIS queries if modifying vector tiles.
