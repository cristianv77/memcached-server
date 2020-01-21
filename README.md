# memcached-server

RETRIEVAL COMMANDS
-   get: get key 
                returns 
                VALUE key flag size
                value
        example: get country
                returns 
                VALUE country 0 7
                Uruguay
        NOTE: It is posible to ask for more than one key. For this, keys must be separated by a comma (","), with no spaces. For example "get country,city".
-   gets: gets key
                returns 
                VALUE key flag size cas
                value
        example: gets country
                returns 
                VALUE country 0 7 1
                Uruguay
        NOTE: It is posible to ask for more than one key. For this, keys must be separated by a comma (","), with no spaces. For example "gets country,city".
STORAGE COMMANDS
-   set: set key flag ttl size
                return:
                    - STORED in case all parameters are correct.
        example: set country 0 0 7
                Uruguay
                returns 
                STORED
-   add: add key flag ttl size
                return:
                    - STORED in case it is added correctly.
                    - NOT STORED in case the key already exists.
        example: add country 0 0 7
                Uruguay
                returns 
                STORED
-   replace: replace key flag ttl size
                return:
                    - STORED in case it is replaced correctly.
                    - NOT STORED in case the key does not exists.
        example: replace country 0 0 7
                Uruguay
                returns 
                STORED
-   append: append key flag ttl size
                return:
                    - STORED in case it is appended correctly.
                    - NOT STORED in case the key does not exists.
        example: append country 0 0 7
                Uruguay
                returns 
                STORED
-   prepend: prepend key flag ttl size
                return:
                    - STORED in case it is updated correctly.
                    - NOT STORED in case the key does not exists.
        example: prepend country 0 0 7
                Uruguay
                returns 
                STORED
-   cas: cas key flag ttl size cas
                return:
                    - STORED in case it is updated correctly.
                    - NOT FOUND in case the key does not exists.
                    - EXISTS in case the key is already updated.
        example: cas country 0 0 7 1
                Uruguay
                returns 
                STORED

NOTE: If TTL is 0 for any of the STORAGE COMMANDS, then the key will never expirate in the server. Otherwise, TTL will be the expiration time in seconds since it is stored.

Run server:
For running the server, you must run the command "ruby run_server.rb" in cmd or terminal.

Run client:
For running a client, you must run the command "ruby run_client.rb" in cmd or terminal.

Getting started:
1. First of all, run the server.
2. Then, run the client, and then connect to the server (For this, you must write "telnet", which is the command selected for connection. The connection is mandatory for sending commands to the server, if not, an error will be displayed).
NOTE: For more information during execution, it is posible to execute the command "help" or the command "-h". Both of them prints the same information on the console.

For running tests
For running tests, you must run the command "ruby test.rb" in cmd or terminal. 
NOTE: For running the client tests, the server must be running. 

