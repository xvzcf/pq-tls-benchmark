ROOT=$(shell dirname $(shell pwd))
OPENSSL_DIR=$(ROOT)/tmp/openssl

OPENSSL_INCLUDE=$(OPENSSL_DIR)/include
OPENSSL=$(OPENSSL_DIR)/apps/openssl

OQS_INCLUDE=$(OPENSSL_DIR)/oqs/include
OQS_LIB=$(OPENSSL_DIR)/oqs/lib

s_timer.o: s_timer.c
	$(CC) -g -Wall -Wextra -Werror -Wpedantic -I$(OPENSSL_INCLUDE) -I$(OQS_INCLUDE) $< -L$(OPENSSL_DIR) -L$(OQS_LIB) -lssl -lcrypto -ldl -lpthread -loqs -o $@
