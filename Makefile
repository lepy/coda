#
# coda Makefile
#
# @author <bprinty@gmail.com>
# ------------------------------------------------------


# config
# ------
REMOTE     = origin
VERSION    = `python -c 'import coda; print coda.__version__'`


# targets
# -------
.PHONY: docs clean tag

help:
	@echo "clean    - remove all build, test, coverage and Python artifacts"
	@echo "lint     - check style with flake8"
	@echo "test     - run tests quickly with the default Python"
	@echo "docs     - generate Sphinx HTML documentation, including API docs"
	@echo "release  - package and upload a release"
	@echo "build    - package module"
	@echo "install  - install the package to the active Python's site-packages"

clean:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	rm -fr .cache/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -fr {} +
	find . -name '__pycache__' -exec rm -fr {} +

lint:
	flake8 coda tests

test: test-py2 test-py3

test-py2:
	@echo "Running python2 tests ... "
	virtualenv .py2
	. .py2/bin/activate && \
	pip install -r requirements.txt	&& \
	pip install pytest pytest-runner && \
	python setup.py test
	rm -rf .py2

test-py3:
	@echo "Running python3 tests ... "
	virtualenv -p python3 .py3
	. .py3/bin/activate && \
	pip install -r requirements.txt && \
	pip install pytest pytest-runner && \
	python setup.py test
	rm -rf .py3

tag:
	VER=$(VERSION) && if [ `git tag | grep "$$VER" | wc -l` -ne 0 ]; then git tag -d $$VER; fi
	VER=$(VERSION) && git tag $$VER -m "coda, release $$VER"

docs:
	cd docs && make html

build: clean
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

release: build tag
	VER=$(VERSION) && git push $(REMOTE) :$$VER || echo 'Remote tag available'
	VER=$(VERSION) && git push $(REMOTE) $$VER
	twine upload --skip-existing dist/*

install: clean
	python setup.py install
