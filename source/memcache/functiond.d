/*  vim:expandtab:shiftwidth=2:tabstop=2:smarttab:
 * 
 *  Libmemcached library
 *
 *  Copyright (C) 2011 Data Differential, http://datadifferential.com/ 
 *  All rights reserved.
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

module memcache.functiond;

public import memcache;

import core.stdc.time;

extern (C):
nothrow:
//alloc.h
/**
  Memory allocation functions.
*/
//allocators.h
memcached_return_t memcached_set_memory_allocators(memcached_st* ptr,
    memcached_malloc_fn mem_malloc, memcached_free_fn mem_free,
    memcached_realloc_fn mem_realloc, memcached_calloc_fn mem_calloc, void* context);

void memcached_get_memory_allocators(const memcached_st* ptr,
    memcached_malloc_fn* mem_malloc, memcached_free_fn* mem_free,
    memcached_realloc_fn* mem_realloc, memcached_calloc_fn* mem_calloc);

void* memcached_get_memory_allocators_context(const memcached_st* ptr);

//analyze.h
memcached_analysis_st* memcached_analyze(memcached_st* memc,
    memcached_stat_st* memc_stat, memcached_return_t* error);

void memcached_analyze_free(memcached_analysis_st*);

//auto.h
memcached_return_t memcached_increment(memcached_st* ptr, const char* key,
    size_t key_length, uint offset, ulong* value);
memcached_return_t memcached_decrement(memcached_st* ptr, const char* key,
    size_t key_length, uint offset, ulong* value);

memcached_return_t memcached_increment_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, ulong offset, ulong* value);

memcached_return_t memcached_decrement_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, ulong offset, ulong* value);

memcached_return_t memcached_increment_with_initial(memcached_st* ptr,
    const char* key, size_t key_length, ulong offset, ulong initial,
    time_t expiration, ulong* value);

memcached_return_t memcached_decrement_with_initial(memcached_st* ptr,
    const char* key, size_t key_length, ulong offset, ulong initial,
    time_t expiration, ulong* value);

memcached_return_t memcached_increment_with_initial_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, ulong offset, ulong initial, time_t expiration, ulong* value);

memcached_return_t memcached_decrement_with_initial_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, ulong offset, ulong initial, time_t expiration, ulong* value);

//behavior.h
memcached_return_t memcached_behavior_set(memcached_st* ptr,
    const memcached_behavior_t flag, ulong data);

ulong memcached_behavior_get(memcached_st* ptr, const memcached_behavior_t flag);

memcached_return_t memcached_behavior_set_distribution(memcached_st* ptr,
    memcached_server_distribution_t type);

memcached_server_distribution_t memcached_behavior_get_distribution(memcached_st* ptr);

memcached_return_t memcached_behavior_set_key_hash(memcached_st* ptr, memcached_hash_t type);

memcached_hash_t memcached_behavior_get_key_hash(memcached_st* ptr);

memcached_return_t memcached_behavior_set_distribution_hash(memcached_st* ptr, memcached_hash_t type);

memcached_hash_t memcached_behavior_get_distribution_hash(memcached_st* ptr);

char* libmemcached_string_behavior(const memcached_behavior_t flag);

char* libmemcached_string_distribution(const memcached_server_distribution_t flag);

memcached_return_t memcached_bucket_set(memcached_st* self,
    const uint* host_map, const uint* forward_map, const uint buckets, const uint replicas);

//callback.h
memcached_return_t memcached_callback_set(memcached_st* ptr,
    const memcached_callback_t flag, const void* data);

void* memcached_callback_get(memcached_st* ptr, const memcached_callback_t flag,
    memcached_return_t* error);

//delete.h
memcached_return_t memcached_delete(memcached_st* ptr, const char* key,
    size_t key_length, time_t expiration);

memcached_return_t memcached_delete_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, time_t expiration);
//dump.h
memcached_return_t memcached_dump(memcached_st* ptr,
    memcached_dump_fn* cfunction, void* context, uint number_of_callbacks);

//error.h

char* memcached_error(const memcached_st*);

char* memcached_last_error_message(const memcached_st*);

void memcached_error_print(const memcached_st*);

memcached_return_t memcached_last_error(const memcached_st*);

int memcached_last_error_errno(const memcached_st*);

char* memcached_server_error(const memcached_instance_st* ptr);

memcached_return_t memcached_server_error_return(const memcached_instance_st* ptr);

//encoding_key.h
memcached_return_t memcached_set_encoding_key(memcached_st*, const char* str, size_t length);

//exist.h
memcached_return_t memcached_exist(memcached_st* memc, const char* key, size_t key_length);

memcached_return_t memcached_exist_by_key(memcached_st* memc,
    const char* group_key, size_t group_key_length, const char* key, size_t key_length);

//fetch.h
memcached_return_t memcached_fetch_execute(memcached_st* ptr,
    memcached_execute_fn* callback, void* context, uint number_of_callbacks);

//fluash.h
memcached_return_t memcached_flush(memcached_st* ptr, time_t expiration);

//flush_buffers.h
memcached_return_t memcached_flush_buffers(memcached_st* mem);

//get.h
char* memcached_get(memcached_st* ptr, const char* key, size_t key_length,
    size_t* value_length, uint* flags, memcached_return_t* error);

memcached_return_t memcached_mget(memcached_st* ptr, const char** keys,
    const size_t* key_length, size_t number_of_keys);

char* memcached_get_by_key(memcached_st* ptr, const char* group_key,
    size_t group_key_length, const char* key, size_t key_length,
    size_t* value_length, uint* flags, memcached_return_t* error);

memcached_return_t memcached_mget_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char** keys,
    const size_t* key_length, const size_t number_of_keys);

char* memcached_fetch(memcached_st* ptr, char* key, size_t* key_length,
    size_t* value_length, uint* flags, memcached_return_t* error);

memcached_result_st* memcached_fetch_result(memcached_st* ptr,
    memcached_result_st* result, memcached_return_t* error);

memcached_return_t memcached_mget_execute(memcached_st* ptr, const char** keys,
    const size_t* key_length, const size_t number_of_keys,
    memcached_execute_fn* callback, void* context, const uint number_of_callbacks);

memcached_return_t memcached_mget_execute_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char** keys,
    const size_t* key_length, size_t number_of_keys,
    memcached_execute_fn* callback, void* context, const uint number_of_callbacks);

//hash.d
uint memcached_generate_hash_value(const char* key, size_t key_length,
    memcached_hash_t hash_algorithm);

hashkit_st* memcached_get_hashkit(const memcached_st* ptr);

memcached_return_t memcached_set_hashkit(memcached_st* ptr, hashkit_st* hashk);

uint memcached_generate_hash(const memcached_st* ptr, const char* key, size_t key_length);

void memcached_autoeject(memcached_st* ptr);

char* libmemcached_string_hash(memcached_hash_t type);

//options.h
memcached_return_t libmemcached_check_configuration(const char* option_string,
    size_t length, char* error_buffer, size_t error_buffer_size);

//parse.h
memcached_server_list_st memcached_servers_parse(const char* server_strings);

//quit.h
void memcached_quit(memcached_st* ptr);

//result.d
void memcached_result_free(memcached_result_st* result);

void memcached_result_reset(memcached_result_st* ptr);

memcached_result_st* memcached_result_create(const memcached_st* ptr, memcached_result_st* result);

char* memcached_result_key_value(const memcached_result_st* self);

size_t memcached_result_key_length(const memcached_result_st* self);

char* memcached_result_value(const memcached_result_st* self);

char* memcached_result_take_value(memcached_result_st* self);

size_t memcached_result_length(const memcached_result_st* self);

uint memcached_result_flags(const memcached_result_st* self);

ulong memcached_result_cas(const memcached_result_st* self);

memcached_return_t memcached_result_set_value(memcached_result_st* ptr,
    const char* value, size_t length);

void memcached_result_set_flags(memcached_result_st* self, uint flags);

void memcached_result_set_expiration(memcached_result_st* self, time_t expiration);

//touch.h
memcached_return_t memcached_touch(memcached_st* ptr, const char* key,
    size_t key_length, time_t expiration);

memcached_return_t memcached_touch_by_key(memcached_st* ptr,
    const char* group_key, size_t group_key_length, const char* key,
    size_t key_length, time_t expiration);

version (sasl)
{
    void memcached_set_sasl_callbacks(memcached_st* ptr, const sasl_callback_t* callbacks);

    memcached_return_t memcached_set_sasl_auth_data(memcached_st* ptr,
        const char* username, const char* password);

    memcached_return_t memcached_destroy_sasl_auth_data(memcached_st* ptr);

    sasl_callback_t* memcached_get_sasl_callbacks(memcached_st* ptr);

}
