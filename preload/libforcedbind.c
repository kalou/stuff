#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#define __USE_GNU // This is needed for the RTLD_NEXT definition
#include <dlfcn.h>

/* Change this to route the packet via a different interface. */

int socket(int domain, int type, int protocol)
{
	int (*origsock)(int domain, int type, int protocol);
	struct sockaddr_in si;
	const char * error;
	int sock;

	origsock = dlsym(RTLD_NEXT, "socket");
	if ((error = dlerror()) != NULL) {
		fprintf(stderr, "%s\n", error);
	}

	sock = origsock(domain, type, protocol);

	if ((sock != -1) && (type == SOCK_STREAM)) {
		const char *i;
		i = getenv("FORCEDBIND_IP");
		if (i) {
			si.sin_family = AF_INET;
			si.sin_addr.s_addr = inet_addr(i);
			si.sin_port = 0;
			if (bind(sock, (struct sockaddr *) &si, sizeof(si))) {
				fprintf(stderr, "Cannot bind to %s: %s\n", i,
					strerror(errno));
			}
		} else {
			fprintf(stderr, "No FORCEDBIND_IP env. var\n");
		}
	}

	return sock;
}
