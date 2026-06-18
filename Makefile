# hall-command release

VERSION := $(shell tr -d '[:space:]' < VERSION)

release:
	@if [ -z "$(VERSION)" ]; then \
		echo "错误：VERSION 文件为空" >&2; \
		exit 1; \
	fi
	@if ! git diff --quiet HEAD; then \
		echo "错误：存在未提交的修改，请先提交" >&2; \
		exit 1; \
	fi
	@if git rev-parse "refs/tags/$(VERSION)" >/dev/null 2>&1; then \
		echo "错误：tag $(VERSION) 已存在" >&2; \
		exit 1; \
	fi
	git tag "$(VERSION)"
	git push origin "$(VERSION)"
	@echo "已发布: $(VERSION)"
	@bash scripts/bump-version.sh
