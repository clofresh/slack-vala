build:
	valac --pkg gtk+-3.0 slack.vala

format:
	uncrustify --no-backup -c .uncrustify.cfg slack.vala

clean:
	rm slack

run:
	./slack
