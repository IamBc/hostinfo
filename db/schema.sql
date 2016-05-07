CREATE TABLE host_info(id SERIAL PRIMARY KEY,
                         root_ssh_pub_key TEXT NOT NULL,
                         primary_ip TEXT NOT NULL UNIQUE,
                         free_space_mb INTEGER NOT NULL
                         );
