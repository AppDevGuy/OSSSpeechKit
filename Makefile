documentation:
	@jazzy \
		--min-acl internal \
		--no-hide-documentation-coverage \
		--theme fullwidth \
		--output ./docs \
		--documentation=./*.md
	@rm -rf ./build