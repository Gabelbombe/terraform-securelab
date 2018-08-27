:= /bin/bash
CHDIR_SHELL := $(SHELL)
ACCOUNT_ID  := $(shell aws sts get-caller-identity --output text --query 'Account')

define chdir
	$(eval _D=$(firstword $(1) $(@D)))
	$(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

STATE_DIR 			= ../_state
LOGS_DIR				= ../_logs

AWS_ID?=default



###############################################
# Helper functions
# - follows standard design patterns
###############################################
.check-region:
	@if test "$(REGION)" = "" ; then echo "REGION not set"; exit 1; fi


.source-dir:
	$(call chdir, src)



###############################################
# Generic functions
# - follows standard design patterns
###############################################
graph: .source-dir
	terraform graph |dot -Tpng >| $(LOGS_DIR)/graph.png

clean:
	@rm -rf .terraform
	@rm -f $(LOGS_DIR)/graph.png
	@rm -f $(LOGS_DIR)/*.log
