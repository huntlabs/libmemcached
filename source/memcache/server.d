/*  vim:expandtab:shiftwidth=2:tabstop=2:smarttab:
 * 
 *  Libmemcached library
 *
 *  Copyright (C) 2011 Data Differential, http://datadifferential.com/
 *  Copyright (C) 2006-2009 Brian Aker All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *      * Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *
 *      * Redistributions in binary form must reproduce the above
 *  copyright notice, this list of conditions and the following disclaimer
 *  in the documentation and/or other materials provided with the
 *  distribution.
 *
 *      * The names of its contributors may not be used to endorse or
 *  promote products derived from this software without specific prior
 *  written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
module memcache.server;

public import memcache;

import core.stdc.time;

extern (C):
nothrow:
//server_list.h

memcached_return_t memcached_server_cursor(const memcached_st* ptr,
    const memcached_server_fn* callback, void* context, uint number_of_callbacks);

memcached_instance_st* memcached_server_by_key(memcached_st* ptr,
    const char* key, size_t key_length, memcached_return_t* error);

void memcached_server_error_reset(memcached_server_st* ptr);

void memcached_server_free(memcached_server_st* ptr);

memcached_instance_st* memcached_server_get_last_disconnect(const memcached_st* ptr);

memcached_return_t memcached_server_add_udp(memcached_st* ptr, const char* hostname,
    in_port_t port);

memcached_return_t memcached_server_add_unix_socket(memcached_st* ptr, const char* filename);

memcached_return_t memcached_server_add(memcached_st* ptr, const char* hostname, in_port_t port);

memcached_return_t memcached_server_add_udp_with_weight(memcached_st* ptr,
    const char* hostname, in_port_t port, uint weight);

memcached_return_t memcached_server_add_unix_socket_with_weight(memcached_st* ptr,
    const char* filename, uint weight);

memcached_return_t memcached_server_add_with_weight(memcached_st* ptr,
    const char* hostname, in_port_t port, uint weight);

/**
  Operations on Single Servers.
*/

uint memcached_server_response_count(const memcached_instance_st* self);

char* memcached_server_name(const memcached_instance_st* self);

in_port_t memcached_server_port(const memcached_instance_st* self);

in_port_t memcached_server_srcport(const memcached_instance_st* self);

void memcached_instance_next_retry(const memcached_instance_st* self, const time_t absolute_time);

char* memcached_server_type(const memcached_instance_st* ptr);

ubyte memcached_server_major_version(const memcached_instance_st* ptr);

ubyte memcached_server_minor_version(const memcached_instance_st* ptr);

ubyte memcached_server_micro_version(const memcached_instance_st* ptr);

//server_list.h

void memcached_server_list_free(memcached_server_list_st ptr);

memcached_return_t memcached_server_push(memcached_st* ptr, const memcached_server_list_st list);

memcached_server_list_st memcached_server_list_append(memcached_server_list_st ptr,
    const char* hostname, in_port_t port, memcached_return_t* error);

memcached_server_list_st memcached_server_list_append_with_weight(
    memcached_server_list_st ptr, const char* hostname, in_port_t port,
    uint weight, memcached_return_t* error);

uint memcached_server_list_count(const memcached_server_list_st ptr);

//stat.h
void memcached_stat_free(const memcached_st*, memcached_stat_st*);

memcached_stat_st* memcached_stat(memcached_st* ptr, char* args, memcached_return_t* error);

memcached_return_t memcached_stat_servername(memcached_stat_st* memc_stat,
    char* args, const char* hostname, in_port_t port);

char* memcached_stat_get_value(const memcached_st* ptr,
    memcached_stat_st* memc_stat, const char* key, memcached_return_t* error);

char** memcached_stat_get_keys(memcached_st* ptr, memcached_stat_st* memc_stat,
    memcached_return_t* error);

memcached_return_t memcached_stat_execute(memcached_st* memc, const char* args,
    memcached_stat_fn func, void* context);

//storage.h
memcached_return_t memcached_set(memcached_st* ptr, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_add(memcached_st* ptr, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_replace(memcached_st* ptr, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_append(memcached_st* ptr, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_prepend(memcached_st* ptr, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_cas(memcached_st* ptr, const char* key,
    size_t key_length, const char* value, size_t value_length,
    time_t expiration, uint flags, ulong cas);

memcached_return_t memcached_set_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_add_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_replace_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_prepend_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_append_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, const char* value, size_t value_length, time_t expiration, uint flags);

memcached_return_t memcached_cas_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, const char* value, size_t value_length,
    time_t expiration, uint flags, ulong cas);
