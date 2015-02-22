build:
	valac --pkg gtk+-3.0 slack.vala

clean:
	rm slack

run:
	./slack
