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
	@rm -f $(LOGS_DIR)/*-lab.log



###############################################
# Deployment functions
# - follows standard design patterns
###############################################
plan-lab: .source-dir .check-region
	echo -e "\n\n\n\nplan-lab: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 		\
		>> $(LOGS_DIR)/init-lab.log
	terraform init 2>&1 |tee $(LOGS_DIR)/init-lab.log
	echo -e "\n\n\n\nplan-lab: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 		\
		>> $(LOGS_DIR)/plan-lab.log
	terraform plan 																									\
		-state=$(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate 			\
		-var region="${REGION}"  																			\
	2>&1 |tee $(LOGS_DIR)/plan-lab.log


apply-lab: .source-dir .check-region
	echo -e "\n\n\n\napply-lab: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 	\
		>> $(LOGS_DIR)/init-lab.log
	terraform init 2>&1 |tee $(LOGS_DIR)/init-lab.log
	echo -e "\n\n\n\napply-lab: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 	\
		>> $(LOGS_DIR)/apply-lab.log
	terraform apply -auto-approve																		\
		-state=$(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate 			\
		-var region="${REGION}" 																			\
	2>&1 |tee $(LOGS_DIR)/apply-lab.log


destroy-lab: .source-dir .check-region
	echo -e "\n\n\n\ndestroy-lab: $(date +"%Y-%m-%d @ %H:%M:%S")\n" \
		>> $(LOGS_DIR)/destroy-lab.log
	terraform destroy 																							\
		-auto-approve																									\
		-state=$(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate 			\
		-var region="${REGION}" 																			\
	2>&1 |tee $(LOGS_DIR)/destroy-lab.log


purge-lab: destroy-lab clean
	@rm -f  $(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate
	@rm -fr ssh
