# Install

*These instructions are for installing the **shortbread** code, not Street Spirit itself.*

## Requirements

- [osm2pgsql](https://osm2pgsql.org/) 1.9.2+
- [osm2pgsql themepark](https://osm2pgsql.org/themepark/)
- [Python](https://www.python.org/) 3.10+
- [PostgreSQL](https://www.postgresql.org/) 13+
- [PostGIS](https://postgis.net/) 3.3+
- [Tilekiln](https://github.com/pnorman/tilekiln) 0.8.0+

## Installing dependencies

Install tilekiln into a Python virtualenv with

```sh
python3 -m venv venv
venv/bin/pip install tilekiln
```

### Themepark

Install themepark to somewhere on your system, e.g. `$HOME/osm2pgsql-themepark`

```sh
git clone https://github.com/osm2pgsql-dev/osm2pgsql-themepark.git $HOME/osm2pgsql-themepark
```

Set your LUA_PATH to include themepark, e.g.

```sh
export LUA_PATH="$HOME/osm2pgsql-themepark/lua/?.lua;;"
```

## Loading Data

### OpenStreetMap Data

You need OpenStreetMap data loaded into a PostGIS database. The tile configurations expect a database generated with osm2pgsql using the flex backend with the supplied Lua scripts.

Start by creating a database and enabling PostGIS

```
sudo -u postgres createuser -s $USER
createdb spirit
psql -d spirit -c 'CREATE EXTENSION postgis;'
```

Grab some OpenStreetMap data. It's probably easiest to grab a PBF of OSM data from [Geofabrik](https://download.geofabrik.de/). Once you've done that, import with osm2pgsql:

```
osm2pgsql --output flex --style shortbread.lua -d spirit ~/path/to/data.osm.pbf
```

### Scripted download
Some features are rendered using preprocessed shapefiles.

To download them and import them into the database you can run the following script

```
scripts/get-external-data.py
```

The script downloads shapefiles, loads them into the database and sets up the tables for rendering. Additional script option documentation can be seen with `scripts/get-external-data.py --help`.

## Serving tiles

Once tilekiln is installed, run it in development mode with

```sh
venv/bin/tilekiln serve dev --config shortbread.yaml --source-dbname spirit
```

You can now use the TileJSON at <http://127.0.0.1:8000/shortbread_v1/tilejson.json> with any program that expects a TileJSON.
