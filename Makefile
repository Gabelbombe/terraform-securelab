SHELL				:= /bin/bash
CHDIR_SHELL := $(SHELL)
ACCOUNT_ID  := $(shell aws sts get-caller-identity --output text --query 'Account')

define chdir
	$(eval _D=$(firstword $(1) $(@D)))
	$(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

STATE_DIR 			= _state
LOGS_DIR				= _logs

AWS_ID?=default



###############################################
# Helper functions
# - follows standard design patterns
###############################################
.check-region:
	@if test "$(REGION)" = "" ; then echo "REGION not set"; exit 1; fi

.source-dir:
	$(call chdir, module)



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
lab-plan: .source-dir .check-region
	echo -e "\n\n\n\nlab-plan: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 		\
		>> $(LOGS_DIR)/lab-init.log
	terraform init 2>&1 |tee $(LOGS_DIR)/lab-init.log
	echo -e "\n\n\n\nlab-plan: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 		\
		>> $(LOGS_DIR)/lab-plan.log
	terraform plan 																									\
		-state=$(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate 			\
		-var region="${REGION}"  																			\
	2>&1 |tee $(LOGS_DIR)/lab-plan.log


lab-apply: .source-dir .check-region
	echo -e "\n\n\n\nlab-apply: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 	\
		>> $(LOGS_DIR)/lab-init.log
	terraform init 2>&1 |tee $(LOGS_DIR)/lab-init.log
	echo -e "\n\n\n\nlab-apply: $(date +"%Y-%m-%d @ %H:%M:%S")\n" 	\
		>> $(LOGS_DIR)/lab-apply.log
	terraform apply -auto-approve																		\
		-state=$(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate 			\
		-var region="${REGION}" 																			\
	2>&1 |tee $(LOGS_DIR)/lab-apply.log


lab-destroy: .source-dir .check-region
	echo -e "\n\n\n\nlab-destroy: $(date +"%Y-%m-%d @ %H:%M:%S")\n" \
		>> $(LOGS_DIR)/lab-destroy.log
	terraform init 2>&1 |tee $(LOGS_DIR)/lab-init.log
	terraform destroy 																							\
		-auto-approve																									\
		-state=$(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate 			\
		-var region="${REGION}" 																			\
	2>&1 |tee $(LOGS_DIR)/lab-destroy.log


lab-purge: lab-destroy clean
	@rm -f  $(STATE_DIR)/$(ACCOUNT_ID)/${REGION}-lab.tfstate
	@rm -fr ssh
