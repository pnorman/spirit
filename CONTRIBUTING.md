# Street Spirit contribution guidelines

## Cartography

### Purpose

Street Spirit aims to be a general purpose map style for OpenStreetMap data, suitable for
- use as a locator map,
- to show off what can be done with OpenStreetMap data,
- to be up-to-date with the latest OpenStreetMap data, and
- using to orient a viewer to a location they are at.

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
