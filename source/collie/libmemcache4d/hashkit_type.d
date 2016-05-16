module collie.libmemcache4d.hashkit_type;

alias hashkit_hash_fn = uint function(const char* key, size_t key_length, void* context);

struct hashkit_st
{
    struct hashkit_function_st
    {
        hashkit_hash_fn callfunction;
        void* context;
    };
    hashkit_function_st base_hash;
    hashkit_function_st distribution_hash;

    align(1) struct struct_flags
    {
        bool is_base_same_distributed;
    };
    struct_flags flags;

    align(1) struct struct_options
    {
        bool is_allocated;
    };
    struct_options options;

    void* _key;
};
