# Declaration of variables
# if you want to do statically linked binary, use -> make SHARED=0 CC='gcc -static'
CC = gcc
CC_FLAGS = -w -std=c99 -DSERIAL_SUPPORT
L_FLAGS = -lm

# File names
VERSION = 2.0
PLATFORM=osx
ARCHIVE = gpx-$(PLATFORM)-$(VERSION)
PREFIX = /usr/local
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)

all: gpx

.PHONY: all

# Main target
gpx: $(OBJECTS)
	$(CC) -o gpx $(OBJECTS) $(L_FLAGS)

# To obtain object files
%.o: %.c
	$(CC) -c $(CC_FLAGS) $< -o $@

# To remove generated files
clean:
	rm -f gpx gpx.exe $(OBJECTS)
	rm -f $(ARCHIVE).tar.gz
	rm -f $(ARCHIVE).zip
	rm -f $(ARCHIVE).dmg

# To install program and supporting files
install: gpx
	test -d $(PREFIX) || mkdir $(PREFIX)
	test -d $(PREFIX)/bin || mkdir $(PREFIX)/bin
	install -m 0755 gpx $(PREFIX)/bin
#	test -d $(PREFIX)/share || mkdir $(PREFIX)/share
#	test -d $(PREFIX)/share/gpx || mkdir -p $(PREFIX)/share/gpx
#	for INI in *.ini; do \
#		install -m 0644 $$INI $(PREFIX)/share/gpx; \
#	done

# To make a distribution archive
release: gpx
	rm -rf $(ARCHIVE)	# Get rid of previous junk, if any.
	rm -f $(ARCHIVE).tar.gz
	rm -f $(ARCHIVE).zip
	rm -f $(ARCHIVE).dmg
	mkdir $(ARCHIVE)
	cp -r gpx examples scripts *.ini $(ARCHIVE)
	tar cf - $(ARCHIVE) | gzip -9c > $(ARCHIVE).tar.gz
	zip -r $(ARCHIVE).zip $(ARCHIVE)
	test -f /usr/bin/hdiutil && hdiutil create -format UDZO -srcfolder $(ARCHIVE) $(ARCHIVE).dmg
	rm -rf $(ARCHIVE)


# Run unit test
test: gpx
	./gpx lint.gcode
	python ./s3g-decompiler.py lint.x3g
