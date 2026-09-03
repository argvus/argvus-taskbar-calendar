PREFIX ?= /usr
BRANCH := $(shell git branch --show-current 2>/dev/null || echo "unknown")
REMOTES := $(shell git remote 2>/dev/null || echo "")

.PHONY: build build-bin check install uninstall reinstall service-enable service-disable service-restart clean push push-lease

build:
	@tools/build-local-package.sh

build-bin:
	cargo build --release --locked

check:
	cargo clippy
	cargo test

install: build-bin
	sudo tools/install.sh
	systemctl --user daemon-reload
	systemctl --user restart argvus-calendar

uninstall:
	sudo tools/uninstall.sh

reinstall: uninstall install

service-enable:
	systemctl --user enable --now argvus-calendar

service-disable:
	systemctl --user disable --now argvus-calendar

service-restart:
	systemctl --user restart argvus-calendar

clean:
	cargo clean

# ----- GIT PUSH (development commands) -----
push:
	@echo "Push normal → branch: $(BRANCH)"
	@for remote in $(REMOTES); do \
					echo "  pushing to $$remote..."; \
					git push $$remote $(BRANCH); \
	done

push-lease:
	@echo "Push --force-with-lease → branch: $(BRANCH)"
	@for remote in $(REMOTES); do \
					echo "  pushing to $$remote..."; \
					git push --force-with-lease $$remote $(BRANCH); \
	done
