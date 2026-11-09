#!/usr/bin/env bash
# Собирает сайт JupyterLite в папку dist/ (Python встроен в сайт, интернет ученикам не нужен).
set -euo pipefail
PYODIDE=https://github.com/pyodide/pyodide/releases/download/314.0.6/pyodide-314.0.6.tar.bz2
rm -rf dist _contents .jupyterlite.doit.db wheels
mkdir -p wheels _contents
cp ege9.ipynb 9_*.txt _contents/
pip download comm --no-deps --only-binary=:all: -d wheels -q
jupyter lite build --contents _contents --output-dir dist --pyodide "$PYODIDE" --piplite-wheels wheels/comm-*.whl
# Главная страница сразу открывает ноутбук
# Урезаем Pyodide: оставляем только нужное ядру и numpy/pandas (иначе GitHub Pages не успевает опубликовать ~450 МБ)
python3 - <<'PY'
import re, pathlib
keep = re.compile(r'^(micropip|ipython|asttokens|six|decorator|executing|matplotlib[_-]inline|traitlets|prompt[_-]toolkit|wcwidth|pure[_-]eval|pygments|stack[_-]data|jedi|parso|packaging|comm|numpy|pandas|python[_-]dateutil|pytz|tzdata|libopenblas|openblas|ssl|sqlite3|lzma|pydecimal|setuptools|pip|test)[-_.]', re.I)
d = pathlib.Path('dist/static/pyodide')
removed = 0
for f in d.iterdir():
    if f.suffix in ('.whl', '.zip', '.tar') or f.name.endswith('.tar.gz'):
        if f.name == 'python_stdlib.zip' or keep.match(f.name) and not f.name.startswith('test-'):
            continue
        f.unlink(); removed += 1
print('pruned', removed, 'files')
PY
cat > dist/start.html <<'HTML'
<!doctype html>
<html lang="ru"><head><meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=notebooks/index.html?path=ege9.ipynb">
<title>ЕГЭ по информатике. Задание 9</title></head>
<body><p><a href="notebooks/index.html?path=ege9.ipynb">Открыть ноутбук</a></p></body></html>
HTML
touch dist/.nojekyll
