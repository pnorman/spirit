# Street Spirit style

## Install

### Requirements

- Python 3.9+
- PostgreSQL 10+
- PostGIS 3.3+
- Tilekiln 0.1.0 or later
- [charites](https://github.com/unvt/charites)
- [@basemaps/sprites](https://www.npmjs.com/package/@basemaps/sprites)

### Loading Data

Load some OpenStreetMap data into a PostGIS database with the [flex OpenStreetMap Carto instructions](https://github.com/gravitystorm/openstreetmap-carto/blob/7c75f348c4ffc706f3d0fcd67572ab8ba5ade864/INSTALL.md#openstreetmap-data), including running `scripts/get-external-data.py` and custom indexes.

### Installing dependencies

Install tilekiln into a Python virtualenv with

```sh
python3 -m venv venv
venv/bin/pip install tilekiln
```

Install charites with

```sh
npm install @unvt/charites @basemaps/sprites
```


### Serving tiles

Once tilekiln is installed, run it in development mode with

```sh
~/osm/tilekiln/venv/bin/tilekiln dev config.yaml -d flex
```

### Serving sprites

In another terminal window, run

```sh
node_modules/.bin/basemaps-sprites sprites && python3 serve.py
```

### Viewing the style

With tiles being served in one terminal session, run a local style server with

```sh
node_modules/.bin/charites serve spirit.yaml
```

## License

Copyright Paul Norman 2022-2023

This map style and associated documentation files (the "Style") is
released under the CC0 Public Domain Dedication, version 1.0, as
published by Creative Commons. To the extent possible under law, the
author(s) have dedicated all copyright and related and neighboring
rights to the Style to the public domain worldwide. The Style is
distributed WITHOUT ANY WARRANTY.

You should have received a copy of the CC0 legalcode along with this
work. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
