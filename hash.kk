
module hash

pub effect cmp<k> {
    fun cmp(x: k, y: k) : order
}


pub fun hash(str : string) : int {
    var m : int := 1000000000 + 9;
    var p_pow : int := 1;
    str.list().foldl(0) fn (hash_value : int, c : char) {
        val hash_value = (hash_value + (c.int() + 1) * p_pow) % m;
        p_pow := (p_pow * 31) % m;
        hash_value
    }
}

pub type to_string_r
    String(s : string)
    NoString


pub effect to_string<s> {
    fun to_string(value : s) : to_string_r
}


/*extern import
    c file "hash-inline.c"

pub extern hash(str : string) : int
    c "kk_hash"*/

struct pair<a,b> {
    fst : a
    snd : b
}

fun first<a,b>(pair : pair<a,b>) : a {
    pair.fst
}

fun second<a,b>(pair : pair<a,b>) : b {
    pair.snd
}

pub struct hashmap<a,b> {
    amount : int
    data : list<maybe<list<pair<a,b>>>>
}


pub fun hashmap() : hashmap<a,b> {
    Hashmap(0, [Nothing])
}


fun rehash<a,b>(map: hashmap<a,b>) : <div, exn, to_string<a>|_e> hashmap<a,b> {
    /*val flat_table = map.data.flatmap() fn (lst : maybe<list<pair<string,a>>>) {
        match lst {
            Nothing -> Nil
            Just(lst) -> lst
        }
    }*/
    var new_table := [Nothing]
    for(0, map.data.length() * 2) fn (i) {
        new_table ++ [Nothing]
        ()
    }
    val table = map.data
    table.foreach() fn (lst) {
        match lst {
            Nothing -> ()
            Just(lst) -> {
                lst.foreach() fn (pair) {
                    val str = match to_string(pair.fst)
                        String(s) -> s
                        NoString -> throw("Item could not be converted to string")

                    val hash_value = hash(str) % (map.data.length() * 2);
                    match new_table[hash_value] {
                        Nothing -> {
                            //new_table[hash_value] := Just([pair])
                            new_table := new_table.take(hash_value) ++ Cons(Just([pair]),new_table.drop(hash_value + 1))
                        }
                        Just(lst) -> {
                            match lst {
                                Nothing -> ()
                                Just(row) -> {
                                    //new_table[hash_value] := Just(lst ++ [pair])
                                    new_table := new_table.take(hash_value) ++ Cons(Just(row ++ [pair]), new_table.drop(hash_value + 1))
                                    ()
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    Hashmap(0,new_table) 
}

pub fun insert<b>(map: hashmap<int,b>, key : int, value : b) : <pure|e> hashmap<int,b> {
    with fun to_string(value : int) { String(value.show())}
    with fun cmp(x : int, y : int ) { compare(x,y) }
    insert_logic(map, key, value)
}

pub fun insert_logic<a,b>(map : hashmap<a,b>, key : a, value : b) : <cmp<a>, to_string<a>,exn,div|_e> hashmap<a,b>{
    val new_map = if map.amount / 2 > map.data.length() then {
        map.rehash()
    } else {
        map
    }

    val str = match to_string(key)
        String(s) -> s
        NoString -> throw("Item could not be converted to string")

    val hash_value = hash(str) % new_map.data.length();
    match new_map.data[hash_value] {
        Nothing -> {
            throw("Hashmap too small for key " ++ hash_value.show() ++ " and length " ++ new_map.data.length().show())
        }
        Just(lst) -> {
            match lst {
                Nothing -> {
                    new_map(data = new_map.data.take(hash_value) ++ Cons(Just([Pair(key,value)]), new_map.data.drop(hash_value + 1)), amount = new_map.amount + 1)
                }
                Just(row) -> {
                    val new_row = row.filter() fn (pair) {
                        match cmp(pair.fst, key) {
                            Lt -> True
                            Eq -> False
                            Gt -> True
                        }
                    }
                    new_map(data = new_map.data.take(hash_value) ++ Cons(Just(new_row ++ [Pair(key,value)]), new_map.data.drop(hash_value + 1)), amount = new_map.amount + 1)
                }
            }
        }
    }
}

pub fun get<b>(map : hashmap<int,b>, key : int) : <pure|_e> maybe<b> {
    with fun to_string(value : int) { String(value.show())}
    with fun cmp(x : int, y : int ) { compare(x,y)}
    get_logic(map, key)
}

pub fun get_logic<a,b>(map : hashmap<a,b>, key : a) : <cmp<a>, div, exn,to_string<a>|_e> maybe<b> {
    val str = match to_string(key)
        String(s) -> s
        NoString -> throw("Item could not be converted to string")
    val hash_value = str.hash() % map.data.length();
    match map.data[hash_value] {
        Nothing -> Nothing
        Just(mlist) -> {
            match mlist {
                Nothing -> Nothing
                Just(list) -> {
                    var value := Nothing
                    list.foreach() fn (pair) {
                        match cmp(pair.fst, key) {
                            Lt -> ()
                            Eq -> value := Just(pair.snd)
                            Gt -> ()
                        }
                    }
                    value
                }
            }
        }
    }
}

pub fun pop<b>(map : hashmap<int,b>, key : int) : <pure|_e> hashmap<int,b> {
    with fun to_string(value : int) { String(value.show())}
    with fun cmp(x : int, y : int) { compare(x,y) }
    pop_logic(map, key)
}

pub fun pop_logic<a,b>(map : hashmap<a,b>, key : a) : <to_string<a>, cmp<a>, exn, div|_e> hashmap<a,b> {
    val str = match to_string(key)
        String(s) -> s
        NoString -> throw("Item could not be converted to string")
    val hash_value = str.hash() % map.data.length()
    match map.data[hash_value] {
        Nothing -> map
        Just(mlist) -> {
            match mlist {
                Nothing -> map
                Just(list) -> {
                    var new_list := list.filter() fn (pair) {
                        match cmp(pair.fst, key) {
                            Lt -> True
                            Eq -> False
                            Gt -> True
                        }
                    }
                    map(data = map.data.take(hash_value) ++ Cons(Just(new_list), map.data.drop(hash_value + 1)), amount = map.amount - 1)
                }
            }
        }
    }
}