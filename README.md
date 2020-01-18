# memcached-server

RETRIEVAL COMMANDS
-   get: get <key> 
                returns 
                VALUE <key> <flag> <size>
                <value>
    example: get country
                returns 
                VALUE country 0 7
                Uruguay
-   gets: gets <key>
                returns 
                VALUE <key> <flag> <size> <cas>
                <value>
    example: gets country
                returns 
                VALUE country 0 7 1
                Uruguay

STORAGE COMMANDS
-   set: set <flag> <ttl> <size>
                return:
                    - STORED
                    - NOT STORED
-   add: add <flag> <ttl> <size>
                return:
                    - STORED
                    - NOT STORED
-   replace: replace <flag> <ttl> <size>
                return:
                    - STORED
                    - NOT STORED
-   append: append <flag> <ttl> <size>
                return:
                    - STORED
                    - NOT STORED
-   prepend: prepend <flag> <ttl> <size>
                return:
                    - STORED
                    - NOT STORED
-   cas: cas <flag> <ttl> <size> <cas>
                return:
                    - STORED
                    - NOT STORED