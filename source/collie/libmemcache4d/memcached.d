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
module collie.libmemcache4d.memcached;

public import collie.libmemcache4d.structd;
public import collie.libmemcache4d.types;
public import collie.libmemcache4d.configure;
public import collie.libmemcache4d.functiond;
public import collie.libmemcache4d.server;
public import collie.libmemcache4d.returnd;

extern (C):
nothrow:

void memcached_servers_reset(memcached_st* ptr);

memcached_st* memcached_create(memcached_st* ptr);

memcached_st* memcached(const char* string, size_t string_length);

void memcached_free(memcached_st* ptr);

memcached_return_t memcached_reset(memcached_st* ptr);

void memcached_reset_last_disconnected_server(memcached_st* ptr);

memcached_st* memcached_clone(memcached_st* clone, const memcached_st* ptr);

void* memcached_get_user_data(const memcached_st* ptr);

void* memcached_set_user_data(memcached_st* ptr, void* data);

memcached_return_t memcached_push(memcached_st* destination, const memcached_st* source);

memcached_instance_st* memcached_server_instance_by_position(const memcached_st* ptr,
    uint server_key);

uint memcached_server_count(const memcached_st*);

ulong memcached_query_id(const memcached_st*);

//verbosity.h
memcached_return_t memcached_verbosity(memcached_st* ptr, uint verbosity);

//strerror.h
char* memcached_strerror(const memcached_st* ptr, memcached_return_t rc);

//version.h
memcached_return_t memcached_version(memcached_st* ptr);

char* memcached_lib_version();
