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

int bind(int sockfd, const struct sockaddr *addr,
                socklen_t addrlen)
{
    int (*origbind)(int sockfd, const struct sockaddr *addr,
                    socklen_t addrlen);

    int optval[] = { 1, };

    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEPORT, optval, sizeof(int))) {
        fprintf(stderr, "SO_REUSEPORT: %s\n", strerror(errno));
    };

    origbind = dlsym(RTLD_NEXT, "bind");
    return origbind(sockfd, addr, addrlen);
}

