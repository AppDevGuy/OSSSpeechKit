documentation:
	@echo " Info..."
	@jazzy \
		--clean \
		--author AppDevGuy \
		--author_url https://github.com/AppDevGuy \
		--github_url https://github.com/AppDevGuy/OSSSpeechKit \
		--swift-build-tool xcodebuild \
		--build-tool-arguments "-project,Example/OSSSpeechKit.xcodeproj,-scheme,OSSSpeechKit-Example,-sdk,iphonesimulator,CODE_SIGNING_ALLOWED=NO" \
		--module OSSSpeechKit \
		--module-version 1.0.0 \
		--readme README.md \
		--min-acl public \
		--no-hide-documentation-coverage \
		--output ./docs \

	@rm -rf ./build