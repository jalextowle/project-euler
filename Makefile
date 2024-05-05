ZIG := zig
SRC_DIR := src
TEST_FILES := $(shell find $(SRC_DIR) -name '*.zig')

GREEN := \033[32m
RED := \033[31m
RESET := \033[0m

.PHONY: test clean

test:
	@echo "Running tests..."
	@echo "----------------"
	@$(MAKE) $(TEST_FILES:.zig=.test) -j $(shell sysctl -n hw.ncpu 2>/dev/null || echo 1) --silent
	@echo "----------------"
	@echo "All tests completed."

%.test: %.zig
	@$(ZIG) test $< 2>&1 | sed '/Test/s/^/    /; /passed\.$$/d; s/^/  /' | while IFS= read -r line; do \
		case "$$line" in \
			*OK*) echo "$(GREEN)$$line$(RESET)" ;; \
			*FAIL*) echo "$(RED)$$line$(RESET)" ;; \
			*) echo "$$line" ;; \
		esac; \
	done

clean:
	rm -rf zig-cache
