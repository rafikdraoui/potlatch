default: build

build:
	elm-make --warn src/Main.elm --output=static/js/potlatch.js

upload-data:
	aws s3 sync data s3://potlatch --delete

deploy:
	git checkout gh-pages
	git merge master
	elm-make --warn src/Main.elm --output=static/js/potlatch.js
	git add -f static/js/potlatch.js
	git commit -m "Update: $(shell date)"
	git push origin gh-pages
	git checkout -
