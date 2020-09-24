.PHONY: test clean

test:
	@echo "Test run for the module"
	cd test && terraform init && terraform plan

clean: 
	@echo "Clenaing up environment"
	cd test && rm -rf .terraform