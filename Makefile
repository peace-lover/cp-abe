top_srcdir = .
prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
mandir = ${prefix}/share/man

CC = gcc
CFLAGS  = -O3 -Wall \
	-I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include \
	 \
	-I/usr/include/pbc -I/usr/local/include/pbc \
	 \
	-DPACKAGE_NAME=\"cpabe\" -DPACKAGE_TARNAME=\"cpabe\" -DPACKAGE_VERSION=\"0.11\" -DPACKAGE_STRING=\"cpabe\ 0.11\" -DPACKAGE_BUGREPORT=\"bethenco@cs.berkeley.edu\" -DPACKAGE_URL=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DSTDC_HEADERS=1 -DHAVE_FCNTL_H=1 -DHAVE_STDDEF_H=1 -DHAVE_STRING_H=1 -DHAVE_STDLIB_H=1 -DHAVE_MALLOC=1 -DLSTAT_FOLLOWS_SLASHED_SYMLINK=1 -DHAVE_VPRINTF=1 -DHAVE_LIBCRYPTO=1 -DHAVE_LIBCRYPTO=1 -DHAVE_STRCHR=1 -DHAVE_STRDUP=1 -DHAVE_MEMSET=1 -DHAVE_GMP=1 -DHAVE_PBC=1 -DHAVE_BSWABE=1
LDFLAGS = -O3 -Wall \
        -lglib-2.0   \
        -Wl,-rpath /usr/local/lib -lgmp \
        -Wl,-rpath /usr/local/lib -lpbc \
        -lbswabe \
        -lcrypto -lcrypto \
        -lgmp

DISTNAME = cpabe-0.11

TARGETS  = cpabe-setup   cpabe-enc   cpabe-keygen   cpabe-dec
DEVTARGS = test-lang TAGS

MANUALS  = $(TARGETS:=.1)
HTMLMANS = $(MANUALS:.1=.html)

all: $(TARGETS) $(DEVTARGS)

# user-level compilation

cpabe-setup: setup.o common.o
	$(CC) -o $@ $^ $(LDFLAGS)

cpabe-enc: enc.o common.o policy_lang.o
	$(CC) -o $@ $^ $(LDFLAGS)

cpabe-keygen: keygen.o common.o policy_lang.o
	$(CC) -o $@ $^ $(LDFLAGS)

cpabe-dec: dec.o common.o
	$(CC) -o $@ $^ $(LDFLAGS)

test-lang: test-lang.o common.o policy_lang.o
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c *.h Makefile
	$(CC) -c -o $@ $< $(CFLAGS)

# installation

dist: *.y policy_lang.c *.c *.h *.more-man \
	AUTHORS COPYING INSTALL NEWS README $(MANUALS) \
	aclocal.m4 acinclude.m4 configure configure.ac install-sh Makefile.in \
	missing mkinstalldirs
	rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	cp $^ $(DISTNAME)
	tar zc $(DISTNAME) > $(DISTNAME).tar.gz
	rm -rf $(DISTNAME)

install: $(TARGETS) $(MANUALS)
	$(top_srcdir)/mkinstalldirs -m 755 $(DESTDIR)$(bindir)
	$(top_srcdir)/mkinstalldirs -m 755 $(DESTDIR)$(mandir)
	$(top_srcdir)/mkinstalldirs -m 755 $(DESTDIR)$(mandir)/man1
	for PROG in $(TARGETS); \
	do \
	  $(top_srcdir)/install-sh -m 755 $$PROG   $(DESTDIR)$(bindir); \
	  $(top_srcdir)/install-sh -m 644 $$PROG.1 $(DESTDIR)$(mandir)/man1; \
	done

uninstall:
	for PROG in $(TARGETS); \
	do \
	  /bin/rm -f $(DESTDIR)$(bindir)/$$PROG; \
	  /bin/rm -f $(DESTDIR)$(mandir)/man1/$$PROG.1; \
	done

# developer-level processing and meta stuff

%.c: %.y *.h Makefile
	if which bison 2> /dev/null; then \
	   bison -o $@ $<; \
	fi

%.1: % %.more-man
	if which help2man 2> /dev/null; then \
	   help2man --section=1 --source="SRI International" --no-info \
	            -I $<.more-man -o $@ ./$<; \
	fi

%.html: %.1
	groff -man -Thtml $< > $@

html: $(HTMLMANS)

TAGS: *.c *.h *.y
	@(etags $^ || true) 2> /dev/null

Makefile: Makefile.in config.status
	./config.status

config.status: configure
	./config.status --recheck

configure: configure.ac aclocal.m4 acinclude.m4
	autoconf

# cleanup

# remove everything an installing user can rebuild
clean:
	rm -f *.o $(TARGETS) $(DEVTARGS) *.tar.gz pub_key master_key priv_key *~

# remove everything a package developer can rebuild
distclean: clean
	rm -rf policy_lang.c autom4te.cache Makefile config.status config.log config.cache \
		configure configure.scan autoscan*.log *.1 *.html *.lineno
