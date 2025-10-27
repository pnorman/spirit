# Install
> [!IMPORTANT]
> These install instructions are for Street Spirit, not the [Shortbread Tile generation](INSTALL.shortbread.md).

## Requirements

- [osm2pgsql](https://osm2pgsql.org/) 1.9.2+
- [osm2pgsql themepark](https://osm2pgsql.org/themepark/)
- [Python](https://www.python.org/) 3.10+
- [PostgreSQL](https://www.postgresql.org/) 10+
- [PostGIS](https://postgis.net/) 3.3+
- [Tilekiln](https://github.com/pnorman/tilekiln) 0.3.0+

## Installing dependencies

### Tilekiln
Install tilekiln into a Python virtualenv with

```sh
python3 -m venv tilekiln
tilekiln/bin/pip install tilekiln
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

Data can be loaded to create tiles for Street Spirit, Shortbread, or both.

### OpenStreetMap Data

You need OpenStreetMap data loaded into a PostGIS database. These stylesheets expect a database generated with osm2pgsql using the flex backend with the supplied Lua scripts.

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

If you are only creating Shortbread tiles, instead of ``--style shortbread.lua`` use ``--style spirit.lua``

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
tilekiln/bin/tilekiln serve dev --config spirit.yaml --source-dbname spirit
```

To create shortbread tiles, instead use ``--config spirit.yaml``. If only creating shortbread tiles you do not need to serve sprites or view the style.


## Viewing the style

You need to build the sprites and the style then serve them. A simple HTTP server is included for development purposes.

Build the stylesheet with

```sh
bundle exec glug spirit.glug > spirit.json
```

then build the sprites with
```sh
spreet --unique sprites sprites && spreet --unique -r2 sprites sprites@2x
```

With tiles being served as described above, serve the repository with

```sh
./serve.py
```

Open <http://127.0.0.1:8000/spirit.html> in a web browser.

The building and serving commands can be combined into one line that you re-run whenever you make changes

```sh
spreet --unique sprites sprites && spreet --unique -r2 sprites sprites@2x && bundle exec glug spirit.glug > spirit.json && ./serve.py
```
