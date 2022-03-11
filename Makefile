.PHONY: release

ADDON_NAME := SyncFriendsAndIgnores
RELEASE_ZIP_NAME := $(ADDON_NAME)-bc.zip

release:
ifndef VERSION
	$(error VERSION is not set)
endif
	@git diff --quiet; \
		[ $$? -eq 0 ] || { echo "There are uncommitted changes."; exit 1; }
	@rsync -a . $(ADDON_NAME) --exclude $(ADDON_NAME) --exclude .git --exclude .gitignore --exclude Makefile --exclude README.md --exclude assets --exclude .editorconfig
	@zip -r $(RELEASE_ZIP_NAME) $(ADDON_NAME) -q
	@git tag $(VERSION)
	@gh release create $(VERSION) $(RELEASE_ZIP_NAME) --notes ""
	@rm -rf $(RELEASE_ZIP_NAME) $(ADDON_NAME)
