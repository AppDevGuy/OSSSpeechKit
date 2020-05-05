documentation:
	@echo " Info..."
	@jazzy \
		--clean \
		--author AppDevGuy \
		--author_url https://github.com/AppDevGuy \
		--github_url https://github.com/AppDevGuy/OSSSpeechKit \
		--podspec OSSSpeechKit.podspec \
		--min-acl internal \
		--no-hide-documentation-coverage \
		--output ./docs \

	@rm -rf ./build