CC=gcc
CFLAGS=-Wall -fPIC
TARGET=libforcedbind.so libreuseport.so
LIBDIR=/usr/lib
LDFLAGS=-ldl

all: $(TARGET)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -m 0755 $(TARGET) $(LIBDIR)

.o.so:
	$(LD) -shared -o $@ $< $(LDFLAGS)

.SUFFIXES: .c .o .so
