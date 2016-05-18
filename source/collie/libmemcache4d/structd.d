module collie.libmemcache4d.structd;

import collie.libmemcache4d.types;
import collie.libmemcache4d.configure;
import core.stdc.time;
import core.sys.posix.pthread;
public import collie.libmemcache4d.hashkit_type;

extern (C):

alias int in_port_t;

struct memcached_array_st;
struct memcached_error_t;

// All of the flavors of memcache_server_st
struct memcached_instance_st;

struct memcached_virtual_bucket_t;

// The following two structures are internal, and never exposed to users.
struct memcached_string_t;
struct memcached_continuum_item_st;

version (sasl)
{
}
else
{
    alias void sasl_callback_t;
}

struct memcached_sasl_st
{
    sasl_callback_t* callbacks;
    /*
	** Did we allocate data inside the callbacks, or did the user
	** supply that.
	*/
    bool is_allocated;
};

//memcached.h
struct memcached_st
{
    /**
    @note these are static and should not change without a call to behavior.
	*/
    align(1) struct struct_state
    {
        bool is_purging;
        bool is_processing_input;
        bool is_time_for_rebuild;
        bool is_parsing;
    };

    struct_state state;

    align(1) struct struct_flags
    {
        // Everything below here is pretty static.
        bool auto_eject_hosts;
        bool binary_protocol;
        bool buffer_requests;
        bool hash_with_namespace;
        bool no_block; // Don't block
        bool reply;
        bool randomize_replica_read;
        bool support_cas;
        bool tcp_nodelay;
        bool use_sort_hosts;
        bool use_udp;
        bool verify_key;
        bool tcp_keepalive;
        bool is_aes;
        bool is_fetching_version;
        bool not_used;
    };

    struct_flags flags;

    memcached_server_distribution_t distribution;
    hashkit_st hashkit;
    struct struct_server_info
    {
        uint Version;
    };
    struct_server_info server_info;
    uint number_of_hosts;
    memcached_instance_st* servers;
    memcached_instance_st* last_disconnected_server;
    int snd_timeout;
    int rcv_timeout;
    uint server_failure_limit;
    uint server_timeout_limit;
    uint io_msg_watermark;
    uint io_bytes_watermark;
    uint io_key_prefetch;
    uint tcp_keepidle;
    int poll_timeout;
    int connect_timeout; // How long we will wait on connect() before we will timeout
    int retry_timeout;
    int dead_timeout;
    int send_size;
    int recv_size;
    void* user_data;
    ulong query_id;
    uint number_of_replicas;
    memcached_result_st result;

    struct struct_ketama
    {
        bool weighted_;
        uint continuum_count; // Ketama
        uint continuum_points_counter; // Ketama
        time_t next_distribution_rebuild; // Ketama
        memcached_continuum_item_st* continuum; // Ketama
    };
    struct_ketama ketama;

    memcached_virtual_bucket_t* virtual_bucket;

    memcached_allocator_t allocators;

    memcached_clone_fn on_clone;
    memcached_cleanup_fn on_cleanup;
    memcached_trigger_key_fn get_key_failure;
    memcached_trigger_delete_key_fn delete_trigger;
    memcached_callback_st* callbacks;
    memcached_sasl_st sasl;
    memcached_error_t* error_messages;
    memcached_array_st* _namespace;
    struct struct_configure
    {
        uint initial_pool_size;
        uint max_pool_size;
        int Version; // This is used by pool and others to determine if the memcached_st is out of date.
        memcached_array_st* filename;
    };
    struct_configure configure;
    struct struct_options
    {
        bool is_allocated;
    };
    struct_options options;
};

//string.h
struct memcached_string_st
{
    char* end;
    char* string;
    size_t current_size;
    memcached_st* root;
    struct options_type
    {
        align(1) bool is_allocated;
        align(1) bool is_initialized;
    };
    options_type options;
};

//stat.h
struct memcached_stat_st
{
    ulong connection_structures;
    ulong curr_connections;
    ulong curr_items;
    /*pid_t*/
    int pid;
    ulong pointer_size;
    ulong rusage_system_microseconds;
    ulong rusage_system_seconds;
    ulong rusage_user_microseconds;
    ulong rusage_user_seconds;
    ulong threads;
    ulong time;
    ulong total_connections;
    ulong total_items;
    ulong uptime;
    ulong bytes;
    ulong bytes_read;
    ulong bytes_written;
    ulong cmd_get;
    ulong cmd_set;
    ulong evictions;
    ulong get_hits;
    ulong get_misses;
    ulong limit_maxbytes;
    char[MEMCACHED_VERSION_STRING_LENGTH] Version;
    void* __future; // @todo create a new structure to place here for future usage
    memcached_st* root;
};
//result.h
struct memcached_result_st
{
    uint item_flags;
    time_t item_expiration;
    size_t key_length;
    ulong item_cas;
    memcached_st* root;
    memcached_string_st value;
    ulong numeric_value;
    ulong count;
    char[MEMCACHED_MAX_KEY] item_key;
    align(1) struct struct_options
    {
        bool is_allocated;
        bool is_initialized;
    };
    struct_options options;
    /* Add result callback function */
};

struct memcached_server_st
{
    align(1) struct struct_options
    {
        bool is_allocated;
        bool is_initialized;
        bool is_shutting_down;
        bool is_dead;
    };
    struct_options options;
    uint number_of_hosts;
    uint cursor_active;
    in_port_t port;
    uint io_bytes_sent; /* # bytes sent since last read */
    uint request_id;
    uint server_failure_counter;
    ulong server_failure_counter_query_id;
    uint server_timeout_counter;
    ulong server_timeout_counter_query_id;
    uint weight;
    uint Version;
    memcached_server_state_t state;
    struct struct_io_wait_count
    {
        uint read;
        uint write;
        uint timeouts;
        size_t _bytes_read;
    };
    struct_io_wait_count io_wait_count;
    ubyte major_version; // Default definition of UINT8_MAX means that it has not been set.
    ubyte micro_version; // ditto, and note that this is the third, not second Version bit
    ubyte minor_version; // ditto
    memcached_connection_t type;
    time_t next_retry;
    memcached_st* root;
    ulong limit_maxbytes;
    memcached_error_t* error_messages;
    char[MEMCACHED_NI_MAXHOST] hostname;
};
//callback.h
struct memcached_callback_st
{
    memcached_execute_fn* callback;
    void* context;
    uint number_of_callback;
};
//analysis.d
struct memcached_analysis_st
{
    memcached_st* root;
    uint average_item_size;
    uint longest_uptime;
    uint least_free_server;
    uint most_consumed_server;
    uint oldest_server;
    double pool_hit_ratio;
    ulong most_used_bytes;
    ulong least_remaining_bytes;
};
//allocator.d
struct memcached_allocator_t
{
    memcached_calloc_fn calloc;
    memcached_free_fn free;
    memcached_malloc_fn malloc;
    memcached_realloc_fn realloc;
    void* context;
};

alias memcached_server_list_st = memcached_server_st*;
//deprecated_types
/**
@note The following definitions are just here for backwards compatibility.
*/

alias memcached_return_t memcached_return;
alias memcached_server_distribution_t memcached_server_distribution;
alias memcached_behavior_t memcached_behavior;
alias memcached_callback_t memcached_callback;
alias memcached_hash_t memcached_hash;
alias memcached_connection_t memcached_connection;
alias memcached_clone_fn memcached_clone_func;
alias memcached_cleanup_fn memcached_cleanup_func;
alias memcached_execute_fn memcached_execute_function;
alias memcached_server_fn memcached_server_function;
alias memcached_trigger_key_fn memcached_trigger_key;
alias memcached_trigger_delete_key_fn memcached_trigger_delete_key;
alias memcached_dump_fn memcached_dump_func;
alias memcached_instance_st* memcached_server_instance_st;

//alloc.d
alias memcached_free_fn = void function(const memcached_st* ptr, void* mem, void* context);
alias memcached_malloc_fn = void* function(const memcached_st* ptr, const size_t size,
    void* context);
alias memcached_realloc_fn = void* function(const memcached_st* ptr, void* mem,
    const size_t size, void* context);
alias memcached_calloc_fn = void* function(const memcached_st* ptr, size_t nelem,
    const size_t elsize, void* context);

//callbacks.h
alias memcached_execute_fn = memcached_return_t function(const memcached_st* ptr,
    memcached_result_st* result, void* context);
alias memcached_server_fn = memcached_return_t function(const memcached_st* ptr,
    const memcached_instance_st* server, void* context);
alias memcached_stat_fn = memcached_return_t function(
    const memcached_instance_st* server, const char* key, size_t key_length,
    const char* value, size_t value_length, void* context);

//triggers.h
alias memcached_clone_fn = memcached_return_t function(memcached_st* destination,
    const memcached_st* source);
alias memcached_cleanup_fn = memcached_return_t function(const memcached_st* ptr);

/**
Trigger functions.
*/
alias memcached_trigger_key_fn = memcached_return_t function(
    const memcached_st* ptr, const char* key, size_t key_length, memcached_result_st* result);
alias memcached_trigger_delete_key_fn = memcached_return_t function(
    const memcached_st* ptr, const char* key, size_t key_length);

alias memcached_dump_fn = memcached_return_t function(const memcached_st* ptr,
    const char* key, size_t key_length, void* context);
