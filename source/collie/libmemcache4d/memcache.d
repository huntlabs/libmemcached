module collie.libmemcache4d.memcache;
public import collie.libmemcache4d.memcached;
import std.string;
import std.array;
import std.c.string;
import std.c.time;
import std.conv;

string fromCString(const char* cstring)
{
    return cast(string)(fromStringz(cstring));
}

nothrow:
class Memcache
{
public:

    this()
    {
        memc_ = memcached(null, 0);
    }

    this(string config)
    {
        memc_ = memcached(config.ptr, config.length);
    }

    this(string hostname, in_port_t port)
    {
        memc_ = memcached(null, 0);
        if (memc_)
        {
            hostname ~= "\0";
            memcached_server_add(memc_, hostname.ptr, port);
        }
    }

    this(memcached_st* clone)
    {
        memc_ = memcached_clone(null, clone);
    }

    ~this()
    {
        memcached_free(memc_);
    }

    /**
	* Get the internal memcached_st *
	*/
    /*
	const memcached_st * getImpl() 
	{
		return memc_;
	}
*/
    /**
	* Return an error string for the given return structure.
	*
	* @param[in] rc a memcached_return_t structure
	* @return error string corresponding to given return code in the library.
	*/
    const string getError(memcached_return_t rc)
    {
        /* first parameter to strerror is unused */

        return fromCString(memcached_strerror(null, rc));
    }

    bool error(out string error_message) const
    {
        if (memcached_failed(memcached_last_error(memc_)))
        {
            error_message = fromCString(memcached_last_error_message(memc_));
            return true;
        }

        return false;
    }

    bool error() const
    {
        if (memcached_failed(memcached_last_error(memc_)))
        {
            return true;
        }

        return false;
    }

    bool error(out memcached_return_t arg) const
    {
        arg = memcached_last_error(memc_);
        return memcached_failed(arg);
    }

    bool setBehavior(memcached_behavior_t flag, ulong data)
    {
        return (memcached_success(memcached_behavior_set(memc_, flag, data)));
    }

    ulong getBehavior(memcached_behavior_t flag)
    {
        return memcached_behavior_get(memc_, flag);
    }

    /**
	* Configure the memcache object
	*
	* @param[in] in_config configuration
	* @return true on success; false otherwise
	*/
    bool configure(string configuration)
    {
        memcached_st* new_memc = memcached(configuration.ptr, configuration.length);

        if (new_memc)
        {
            memcached_free(memc_);
            memc_ = new_memc;

            return true;
        }

        return false;
    }

    /**
	* Add a server to the list of memcached servers to use.
	*
	* @param[in] server_name name of the server to add
	* @param[in] port port number of server to add
	* @return true on success; false otherwise
	*/
    bool addServer(string server_name, in_port_t port)
    {
        server_name ~= "\0";
        return memcached_success(memcached_server_add(memc_, server_name.ptr, port));
    }

    /**
	* Remove a server from the list of memcached servers to use.
	*
	* @param[in] server_name name of the server to remove
	* @param[in] port port number of server to remove
	* @return true on success; false otherwise

	bool removeServer(const std::string &server_name, in_port_t port)
	{
    std::string tmp_str;
    std::ostringstream strstm;
		tmp_str.append(",");
		tmp_str.append(server_name);
		tmp_str.append(":");
		strstm << port;
		tmp_str.append(strstm.str());

		//memcached_return_t rc= memcached_server_remove(server);

		return false;
	}
	*/
    /**
	* Fetches an individual value from the server. mget() must always
	* be called before using this method.
	*
	* @param[in] key key of object to fetch
	* @param[out] ret_val store returned object in this vector
	* @return a memcached return structure
	*/
    memcached_return_t fetch(string key, out byte[] ret_val, out uint flags, out ulong cas_value)
    {
        memcached_return_t rc;

        memcached_result_st* result;
        result = memcached_fetch_result(memc_, null, &rc);
        if (result)
        {
            // Key
            const char* ckey = memcached_result_key_value(result);
            size_t len = memcached_result_key_length(result);
            if (len > 0)
            {
                key = ckey[0 .. len].dup;
            }
            else
            {
                key = "";
            }
            // Actual value, null terminated
            const char* rev = memcached_result_value(result);
            len = memcached_result_length(result);
            ret_val = cast(byte[]) rev[0 .. len].dup;
            // Misc
            flags = memcached_result_flags(result);
            cas_value = memcached_result_cas(result);
        }
        memcached_result_free(result);

        return rc;
    }

    memcached_return_t fetch(string key, out byte[] ret_val,)
    {
        uint flags = 0;
        ulong cas_value = 0;

        return fetch(key, ret_val, flags, cas_value);
    }

    /**
	* Fetches an individual value from the server.
	*
	* @param[in] key key of object whose value to get
	* @param[out] ret_val object that is retrieved is stored in
	*                     this vector
	* @return true on success; false otherwise
	*/
    T get(T = string)(string key)
    {
        import std.c.stdlib;

        uint flags = 0;
        memcached_return_t rc;
        size_t value_length = 0;

        char* value = memcached_get(memc_, cast(const char*) key.ptr,
            key.length, &value_length, &flags, &rc);
        char[] ret_val;
        if (value != null)
        {
            ret_val = value[0 .. value_length].dup;
        }

        return to!T(ret_val);
    }

    /**
	* Fetches an individual from a server which is specified by
	* the master_key parameter that is used for determining which
	* server an object was stored in if key partitioning was
	* used for storage.
	*
	* @param[in] master_key key that specifies server object is stored on
	* @param[in] key key of object whose value to get
	* @param[out] ret_val object that is retrieved is stored in
	*                     this vector
	* @return true on success; false otherwise
	*/
    T getByKey(T = string)(string master_key, string key)
    {
        import std.c.stdlib;

        uint flags = 0;
        memcached_return_t rc;
        size_t value_length = 0;

        char* value = memcached_get_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, &value_length, &flags, &rc);
        char[] ret_val;
        if (value)
        {

            ret_val = value[0 .. value_length].dup;
            free(value);
        }
        return to!T(ret_val);
    }

    /**
	* Selects multiple keys at once. This method always
	* works asynchronously.
	*
	* @param[in] keys vector of keys to select
	* @return true if all keys are found
	
	bool mget(const std::vector<std::string> & keys)
	{
    std::vector<const char *> real_keys;
    std::vector<size_t> key_len;
		/*
		* Construct an array which will contain the length
		* of each of the strings in the input vector. Also, to
		* interface with the memcached C API, we need to convert
		* the vector of std::string's to a vector of char *.
		*/
    /*
		real_keys.reserve(keys.length);
		key_len.reserve(keys.length);

    std::vector<std::string>::const_iterator it= keys.begin();

		while (it != keys.end())
		{
			real_keys.push_back(const_cast<char *>((*it).ptr));
			key_len.push_back((*it).length);
			++it;
		}

		/*
		* If the std::vector of keys is empty then we cannot
		* call memcached_mget as we will get undefined behavior.
		*/
    /*
		if (not real_keys.empty())
		{
			return memcached_success(memcached_mget(memc_, &real_keys[0], &key_len[0], real_keys.length));
		}

		return false;
	}
*/
    /**
	* Writes an object to the server. If the object already exists, it will
	* overwrite the existing object. This method always returns true
	* when using non-blocking mode unless a network error occurs.
	*
	* @param[in] key key of object to write to server
	* @param[in] value value of object to write to server
	* @param[in] expiration time to keep the object stored in the server for
	* @param[in] flags flags to store with the object
	* @return true on succcess; false otherwise
	*/
    bool set(T = string)(string key, T value, int expiration = 0, uint flags = 0)
    {
        auto mvalue = to!string(value);
        memcached_return_t rc = memcached_set(memc_,
            cast(const char*) cast(const char*) key.ptr, key.length,
            cast(const char*) mvalue.ptr, mvalue.length, cast(time_t) expiration, flags);
        return memcached_success(rc);
    }
    /*
	bool set(ref string key,
			 const char* value, const size_t value_length,
			  int expiration,
			 uint flags)
	{
		memcached_return_t rc= memcached_set(memc_,
											 cast(const char *)key.ptr, key.length,
											 value, value_length,
											 expiration, flags);
		return memcached_success(rc);
	}
*/
    /**
	* Writes an object to a server specified by the master_key parameter.
	* If the object already exists, it will overwrite the existing object.
	*
	* @param[in] master_key key that specifies server to write to
	* @param[in] key key of object to write to server
	* @param[in] value value of object to write to server
	* @param[in] expiration time to keep the object stored in the server for
	* @param[in] flags flags to store with the object
	* @return true on succcess; false otherwise
	*/
    bool setByKey(T = string)(string master_key, string key, T value,
        int expiration = 0, uint flags = 0)
    {
        string mvalue = to!string(value);
        return memcached_success(memcached_set_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(const char*) mvalue.ptr,
            mvalue.length, cast(time_t) expiration, flags));
    }

    /**
	* Writes a list of objects to the server. Objects are specified by
	* 2 vectors - 1 vector of keys and 1 vector of values.
	*
	* @param[in] keys vector of keys of objects to write to server
	* @param[in] values vector of values of objects to write to server
	* @param[in] expiration time to keep the objects stored in server for
	* @param[in] flags flags to store with the objects
	* @return true on success; false otherwise
	*/
    /*
	bool setAll(string[] keys,
				byte[][] values,
				int expiration,
				uint flags)
	{
		bool retval= true;
		for (int i = 0; i < keys.length; ++i) {
			retval= set(keys[i], values[i], expiration, flags);
		}
    std::vector<std::string>::const_iterator key_it= keys.begin();
    std::vector< std::vector<char> *>::const_iterator val_it= values.begin();
		while (key_it != keys.end())
		{
			retval= set((*key_it), *(*val_it), expiration, flags);
			if (retval == false)
			{
				return retval;
			}
			++key_it;
			++val_it;
		}
		return retval;
	}
*/
    /**
	* Writes a list of objects to the server. Objects are specified by
	* a map of keys to values.
	*
	* @param[in] key_value_map map of keys and values to store in server
	* @param[in] expiration time to keep the objects stored in server for
	* @param[in] flags flags to store with the objects
	* @return true on success; false otherwise
	*/
    /*
	bool setAll(const std::map<const std::string, std::vector<char> >& key_value_map,
				int expiration,
				uint flags)
	{
		bool retval= true;
    std::map<const std::string, std::vector<char> >::const_iterator it= key_value_map.begin();

		while (it != key_value_map.end())
		{
			retval= set(it->first, it->second, expiration, flags);
			if (retval == false)
			{
				// We should tell the user what the key that failed was
				return false;
			}
			++it;
		}

		return true;
	}
*/
    /**
	* Increment the value of the object associated with the specified
	* key by the offset given. The resulting value is saved in the value
	* parameter.
	*
	* @param[in] key key of object in server whose value to increment
	* @param[in] offset amount to increment object's value by
	* @param[out] value store the result of the increment here
	* @return true on success; false otherwise
	*/
    bool increment(string key, uint offset, ulong* value)
    {
        return memcached_success(memcached_increment(memc_,
            cast(const char*) key.ptr, key.length, offset, value));
    }

    /**
	* Decrement the value of the object associated with the specified
	* key by the offset given. The resulting value is saved in the value
	* parameter.
	*
	* @param[in] key key of object in server whose value to decrement
	* @param[in] offset amount to increment object's value by
	* @param[out] value store the result of the decrement here
	* @return true on success; false otherwise
	*/
    bool decrement(string key, uint offset, ulong* value)
    {
        return memcached_success(memcached_decrement(memc_,
            cast(const char*) key.ptr, key.length, offset, value));
    }

    /**
	* Add an object with the specified key and value to the server. This
	* function returns false if the object already exists on the server.
	*
	* @param[in] key key of object to add
	* @param[in] value of object to add
	* @return true on success; false otherwise
	*/
    bool add(T = string)(string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_add(memc_, cast(const char*) key.ptr,
            key.length, cast(const char*) value.ptr, value.length, cast(time_t) 0,
            cast(uint) 0));
    }

    /**
	* Add an object with the specified key and value to the server. This
	* function returns false if the object already exists on the server. The
	* server to add the object to is specified by the master_key parameter.
	*
	* @param[in[ master_key key of server to add object to
	* @param[in] key key of object to add
	* @param[in] value of object to add
	* @return true on success; false otherwise
	*/
    bool addByKey(T = string)(string master_key, string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_add_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Replaces an object on the server. This method only succeeds
	* if the object is already present on the server.
	*
	* @param[in] key key of object to replace
	* @param[in[ value value to replace object with
	* @return true on success; false otherwise
	*/
    bool replace(T = string)(string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_replace(memc_,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Replaces an object on the server. This method only succeeds
	* if the object is already present on the server. The server
	* to replace the object on is specified by the master_key param.
	*
	* @param[in] master_key key of server to replace object on
	* @param[in] key key of object to replace
	* @param[in[ value value to replace object with
	* @return true on success; false otherwise
	*/
    bool replaceByKey(T = string)(string master_key, string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_replace_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Places a segment of data before the last piece of data stored.
	*
	* @param[in] key key of object whose value we will prepend data to
	* @param[in] value data to prepend to object's value
	* @return true on success; false otherwise
	*/
    bool prepend(T = string)(string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_prepend(memc_,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Places a segment of data before the last piece of data stored. The
	* server on which the object where we will be prepending data is stored
	* on is specified by the master_key parameter.
	*
	* @param[in] master_key key of server where object is stored
	* @param[in] key key of object whose value we will prepend data to
	* @param[in] value data to prepend to object's value
	* @return true on success; false otherwise
	*/
    bool prependByKey(T = string)(string master_key, string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_prepend_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Places a segment of data at the end of the last piece of data stored.
	*
	* @param[in] key key of object whose value we will append data to
	* @param[in] value data to append to object's value
	* @return true on success; false otherwise
	*/
    bool append(T = string)(string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_append(memc_,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Places a segment of data at the end of the last piece of data stored. The
	* server on which the object where we will be appending data is stored
	* on is specified by the master_key parameter.
	*
	* @param[in] master_key key of server where object is stored
	* @param[in] key key of object whose value we will append data to
	* @param[in] value data to append to object's value
	* @return true on success; false otherwise
	*/
    bool appendByKey(T = string)(string master_key, string key, T tvalue)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_append_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0));
    }

    /**
	* Overwrite data in the server as long as the cas_arg value
	* is still the same in the server.
	*
	* @param[in] key key of object in server
	* @param[in] value value to store for object in server
	* @param[in] cas_arg "cas" value
	*/
    bool cas(T = string)(string key, T tvalue, ulong cas_arg)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_cas(memc_, cast(const char*) key.ptr,
            key.length, cast(const char*) value.ptr, value.length,
            cast(time_t) 0, cast(uint) 0, cas_arg));
    }

    /**
	* Overwrite data in the server as long as the cas_arg value
	* is still the same in the server. The server to use is
	* specified by the master_key parameter.
	*
	* @param[in] master_key specifies server to operate on
	* @param[in] key key of object in server
	* @param[in] value value to store for object in server
	* @param[in] cas_arg "cas" value
	*/
    bool casByKey(T = string)(string master_key, string key, T tvalue, ulong cas_arg)
    {
        auto value = to!string(tvalue);
        return memcached_success(memcached_cas_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(const char*) value.ptr,
            value.length, cast(time_t) 0, cast(uint) 0, cas_arg));
    }

    /**
	* Delete an object from the server specified by the key given.
	*
	* @param[in] key key of object to delete
	* @param[in] expiration time to delete the object after
	* @return true on success; false otherwise
	*/
    bool del(string key, int expiration = 0)
    {
        return memcached_success(memcached_delete(memc_,
            cast(const char*) key.ptr, key.length, cast(time_t) expiration));
    }

    /**
	* Delete an object from the server specified by the key given.
	*
	* @param[in] master_key specifies server to remove object from
	* @param[in] key key of object to delete
	* @param[in] expiration time to delete the object after
	* @return true on success; false otherwise
	*/
    bool delByKey(string master_key, string key, int expiration = 0)
    {
        return memcached_success(memcached_delete_by_key(memc_,
            cast(const char*) master_key.ptr, master_key.length,
            cast(const char*) key.ptr, key.length, cast(time_t) expiration));
    }

    /**
	* Wipe the contents of memcached servers.
	*
	* @param[in] expiration time to wait until wiping contents of
	*                       memcached servers
	* @return true on success; false otherwise
	*/
    bool flush(int expiration = 0)
    {
        return memcached_success(memcached_flush(memc_, cast(time_t) expiration));
    }

    /**
	* Get the library version string.
	* @return std::string containing a copy of the library version string.
	*/
    const string libVersion()
    {
        const char* ver = memcached_lib_version();
        return fromCString(ver);
    }

    /**
	* Retrieve memcached statistics. Populate a std::map with the retrieved
	* stats. Each server will map to another std::map of the key:value stats.
	*
	* @param[out] stats_map a std::map to be populated with the memcached
	*                       stats
	* @return true on success; false otherwise
	*/
    /*
	bool getStats(std::map< std::string, std::map<std::string, std::string> >& stats_map)
	{
		memcached_return_t rc;
		memcached_stat_st *stats= memcached_stat(memc_, null, &rc);

		if (rc != MEMCACHED_SUCCESS &&
			rc != MEMCACHED_SOME_ERRORS)
		{
			return false;
		}

		uint server_count= memcached_server_count(memc_);

		/*
		* For each memcached server, construct a std::map for its stats and add
		* it to the std::map of overall stats.
		*/
    /*
		for (uint x= 0; x < server_count; x++)
		{
			const memcached_instance_st * instance= memcached_server_instance_by_position(memc_, x);
		std::ostringstream strstm;
		std::string server_name(memcached_server_name(instance));
			server_name.append(":");
			strstm << memcached_server_port(instance);
			server_name.append(strstm.str());

		std::map<std::string, std::string> server_stats;
			char **list= memcached_stat_get_keys(memc_, &stats[x], &rc);
			for (char** ptr= list; *ptr; ptr++)
			{
				char *value= memcached_stat_get_value(memc_, &stats[x], *ptr, &rc);
				server_stats[*ptr]= value;
				free(value);
			}

			stats_map[server_name]= server_stats;
			free(list);
		}

		memcached_stat_free(memc_, stats);
		return true;
	}
*/
private:
    memcached_st* memc_;
};
