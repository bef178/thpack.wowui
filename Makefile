.PHONY: all
all:
	@bash build/build.sh

.PHONY: package
package:
	@bash build/build.sh package

.PHONY: install
install:
	@bash build/build.sh install

.PHONY: clean
clean:
	@echo "cleaning ..."
	@rm -rf ./target/*
