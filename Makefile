APP := ..
JAIL := "$(APP)/jail"

init: clean
	./check_python.sh
	./init_jail.sh $(JAIL)
	python jail_app.py $(APP) $(JAIL)
  
clean:
	rm -rf $(JAIL)
