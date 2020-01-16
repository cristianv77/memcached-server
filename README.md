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
-   add: add <flag> <ttl> <size>
-   replace: replace <flag> <ttl> <size>
-   append: append <flag> <ttl> <size>
-   prepend: prepend <flag> <ttl> <size>
-   cas: 