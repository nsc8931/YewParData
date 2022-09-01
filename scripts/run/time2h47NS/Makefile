.PHONY: clean all

APPS = NS

# Handle unprocessed data if required
define parse_unprocessed
raw_data/$(1).dat : $(shell ls output/$(1)/*) $$ parseUnprocessed.sh
	@mkdir -p raw_data
	bash $$ parseUnprocessed.sh output/$(1)/ $(1) >raw_data/$(1).dat
endef

$(foreach app,$(APPS),$(eval $(call parse_unprocessed,$(app))))
##

clean:
	rm -rf raw_data

