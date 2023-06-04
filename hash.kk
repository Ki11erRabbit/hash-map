
module hash

pub fun hash(str : string) : int {
    var m : int := 1000000000 + 9;
    var p_pow : int := 1;
    str.list().foldl(0) fn (hash_value : int, c : char) {
        val hash_value = (hash_value + (c.int() + 1) * p_pow) % m;
        p_pow := (p_pow * 31) % m;
        hash_value
    }
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

pub struct hashmap<a> {
    amount : int
    data : list<maybe<list<pair<string,a>>>>
}


pub fun hashmap() : hashmap<a> {
    Hashmap(0, [Nothing])
}


fun rehash<a>(map: hashmap<a>) : <div|_e> hashmap<a> {
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
                    val hash_value = hash(pair.fst) % (map.data.length() * 2);
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

pub fun insert<a>(map : hashmap<a>, key : string, value : a) : <console,div|_e> hashmap<a>{
    val new_map = if map.amount / 2 > map.data.length() then {
        map.rehash()
    } else {
        map
    }

    val hash_value = hash(key) % new_map.data.length();
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
                        pair.fst != key
                    }
                    new_map(data = new_map.data.take(hash_value) ++ Cons(Just(new_row ++ [Pair(key,value)]), new_map.data.drop(hash_value + 1)), amount = new_map.amount + 1)
                }
            }
        }
    }
}

pub fun get<a>(map : hashmap<a>, key : string) : <div|_e> maybe<a> {
    val hash_value = key.hash() % map.data.length();
    match map.data[hash_value] {
        Nothing -> Nothing
        Just(mlist) -> {
            match mlist {
                Nothing -> Nothing
                Just(list) -> {
                    var value := Nothing
                    list.foreach() fn (pair) {
                        if pair.fst == key then {
                            value := Just(pair.snd)
                        } else {
                            ()
                        }
                    }
                    value
                }
            }
        }
    }
}

