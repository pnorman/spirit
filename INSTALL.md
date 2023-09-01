# Install

## Requirements

- Python 3.9+
- PostgreSQL 10+
- PostGIS 3.3+
- Tilekiln 0.1.0 or later
- [charites](https://github.com/unvt/charites)
- [@basemaps/sprites](https://www.npmjs.com/package/@basemaps/sprites)

## Loading Data

### OpenStreetMap Data

You need OpenStreetMap data loaded into a PostGIS database. These stylesheets expect a database generated with osm2pgsql using the flex backend with the supplied Lua scripts.

Start by creating a database

```
sudo -u postgres createuser -s $USER
createdb flex
```

Enable PostGIS and hstore extensions with

```
psql -d flex -c 'CREATE EXTENSION postgis; CREATE EXTENSION hstore;'
```

then grab some OSM data. It's probably easiest to grab an PBF of OSM data from [Geofabrik](https://download.geofabrik.de/). Once you've done that, import with osm2pgsql:

```
osm2pgsql --output flex --style spirit.lua -d flex ~/path/to/data.osm.pbf
```

### Custom indexes
Custom indexes are required for rendering performance and are essential on full planet databases.

```
psql -d flex -f indexes.sql
```

### Scripted download
Some features are rendered using preprocessed shapefiles.

To download them and import them into the database you can run the following script

```
scripts/get-external-data.py
```


The script downloads shapefiles, loads them into the database and sets up the tables for rendering. Additional script option documentation can be seen with `scripts/get-external-data.py --help`.

## Installing dependencies

Install tilekiln into a Python virtualenv with

```sh
python3 -m venv venv
venv/bin/pip install tilekiln
```

Install charites with

```sh
npm install @unvt/charites @basemaps/sprites
```


## Serving tiles

Once tilekiln is installed, run it in development mode with

```sh
~/osm/tilekiln/venv/bin/tilekiln dev config.yaml -d flex
```

## Serving sprites

In another terminal window, run

```sh
node_modules/.bin/basemaps-sprites sprites && python3 serve.py
```

## Viewing the style

With tiles being served in one terminal session, run a local style server with

```sh
node_modules/.bin/charites serve spirit.yaml
```
