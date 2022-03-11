.PHONY: release

RELEASE_ZIP_NAME := synch-friends-and-ignores-bc.zip

release:
ifndef VERSION
	$(error VERSION is not set)
endif
	@git diff --quiet; \
		[ $$? -eq 0 ] || { echo "There are uncommitted changes."; exit 1; }
	@rsync -a . $(basename $(RELEASE_ZIP_NAME)) --exclude $(basename $(RELEASE_ZIP_NAME)) --exclude .git --exclude .gitignore --exclude Makefile --exclude README.md --exclude assets
	@zip -r $(RELEASE_ZIP_NAME) Ravilan -q
	@git tag $(VERSION)
	@gh release create $(VERSION) $(RELEASE_ZIP_NAME) --notes ""
	@rm -rf $(RELEASE_ZIP_NAME) Ravilan