
module hash


pub effect hash<h> {
    fun hash(x : h) : int
}

pub fun hasher(str : string) : int {
    var m : int := 1000000000 + 9;
    var p_pow : int := 1;
    str.list().foldl(0) fn (hash_value : int, c : char) {
        val hash_value = (hash_value + (c.int() + 1) * p_pow) % m;
        p_pow := (p_pow * 31) % m;
        hash_value
    }
}

pub fun hasher(x : int) : int {
    x
}

pub fun hasher(x : float64) : int {
    x.int()
}

pub fun hasher(x : bool) : int {
    if x then 1 else 0
}

pub fun hasher(x : char) : int {
    (x.int() + 1) % (1000000000 + 9)
}



/*extern import
    c file "hash-inline.c"

pub extern hash(str : string) : int
    c "kk_hash"*/

pub struct pair<a,b> {
    fst : a
    snd : b
}

pub struct hashmap<a,b> {
    amount : int
    data : list<maybe<list<pair<a,b>>>>
    cmp : (a,a) -> order
}


pub fun hashmap(cmp : (a,a) -> order) : hashmap<a,b> {
    Hashmap(0, [Nothing], cmp)
}

pub fun make-hashmap<a,b>(list : list<pair<a,b>>, cmp : (a,a) -> order) : <div,hash<a>|_e> hashmap<a,b> {
    list.foldl(hashmap(cmp)) fn (map, pair) {
        map.insert(pair.fst, pair.snd)
    }
}

fun rehash<a,b>(map: hashmap<a,b>) : <div, hash<a>|_e> hashmap<a,b> {
    
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
                            new_table := new_table.take(hash_value) ++ Cons(Just([pair]),new_table.drop(hash_value + 1))
                        }
                        Just(lst) -> {
                            match lst {
                                Nothing -> ()
                                Just(row) -> {
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
    Hashmap(map.amount,new_table,map.cmp) 
}


pub fun insert<a,b>(map : hashmap<a,b>, key : a, value : b) : <hash<a>,exn,div|_e> hashmap<a,b>{
    val new_map = if map.amount / 2 > map.data.length() then {
        map.rehash()
    } else {
        map
    }


    val hash_value = key.hash() % new_map.data.length();
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
                        match (map.cmp)(pair.fst, key) {
                            Lt -> True
                            Eq -> False
                            Gt -> True
                        }
                    }

                    new_map(data = new_map.data.take(hash_value) ++ Cons(Just(Cons(Pair(key,value), new_row)), new_map.data.drop(hash_value + 1)), amount = new_map.amount + 1)
                }
            }
        }
    }
}


pub fun get<a,b>(map : hashmap<a,b>, key : a) : <div,hash<a>|_e> maybe<b> {
    
    val hash_value = key.hash() % map.data.length();
    match map.data[hash_value] {
        Nothing -> Nothing
        Just(mlist) -> {
            match mlist {
                Nothing -> Nothing
                Just(list) -> {
                    var value := Nothing
                    match list[key.hash() % list.length()] {
                        Nothing -> Nothing
                        Just(pair) -> {
                            match (map.cmp)(pair.fst, key) {
                                Lt -> Nothing
                                Eq -> Just(pair.snd)
                                Gt -> Nothing
                            }
                        }
                    }
                }
            }
        }
    }
}


pub fun remove<a,b>(map : hashmap<a,b>, key : a) : <hash<a>, div|_e> hashmap<a,b> {
    
    val hash_value = key.hash() % map.data.length()
    match map.data[hash_value] {
        Nothing -> map
        Just(mlist) -> {
            match mlist {
                Nothing -> map
                Just(list) -> {
                    
                    var new_list := list.filter() fn (pair) {
                        match (map.cmp)(pair.fst, key) {
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

pub fun contains<a,b>(map : hashmap<a,b>, key : a) : <div,hash<a>|_e> bool {
    match map.get(key) {
        Nothing -> False
        Just(_) -> True
    }
}

pub fun list<a,b>(map : hashmap<a,b>) : <div|_e> list<pair<a,b>> {
    var list := []
    map.data.reverse().foreach() fn (row) {
        match row {
            Nothing -> ()
            Just(row) -> {
                row.foreach() fn (pair) {
                    list := Cons(pair, list)
                    ()
                }
            }
        }
    }
    list
}

pub fun keys<a,b>(hashmap : hashmap<a,b>) : <div|_e> list<a> {
    hashmap.list().map() fn (pair) {
        pair.fst
    }
}

pub fun values<a,b>(hashmap : hashmap<a,b>) : <div|_e> list<b> {
    hashmap.list().map() fn (pair) {
        pair.snd
    }
}

pub fun length<a,b>(map : hashmap<a,b>) : int {
    map.amount
}


struct hashset<a>
    amount : int
    data : list<maybe<list<a>>>
    cmp : (a,a) -> order


pub fun hashset(cmp : (a,a) -> order) : hashset<a> {
    Hashset(0, [Nothing], cmp)
}

pub fun make-hashset(list : list<a>, cmp : (a,a) -> order) : <div,exn, hash<a>|_e> hashset<a> {
    list.foldl(hashset(cmp)) fn (set, key) {
        set.insert(key)
    }
}

fun rehash<a>(set: hashset<a>) : <div, hash<a>|_e> hashset<a> {
    
    var new_table := [Nothing]
    for(0, set.data.length() * 2) fn (i) {
        new_table ++ [Nothing]
        ()
    }
    val table = set.data
    table.foreach() fn (lst) {
        match lst {
            Nothing -> ()
            Just(lst) -> {
                lst.foreach() fn (value) {
                    val hash_value = hash(value) % (set.data.length() * 2);
                    match new_table[hash_value] {
                        Nothing -> {
                            new_table := new_table.take(hash_value) ++ Cons(Just([value]),new_table.drop(hash_value + 1))
                        }
                        Just(lst) -> {
                            match lst {
                                Nothing -> ()
                                Just(row) -> {
                                    new_table := new_table.take(hash_value) ++ Cons(Just(row ++ [value]), new_table.drop(hash_value + 1))
                                    ()
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    Hashset(set.amount,new_table,set.cmp) 
}

pub fun insert<a>(set : hashset<a>, key : a) : <hash<a>,exn,div|_e> hashset<a> {
    val new_set = if set.amount / 2 > set.data.length() then {
        set.rehash()
    } else {
        set
    }

    val hash_value = key.hash() % new_set.data.length();
    match new_set.data[hash_value] {
        Nothing -> {
            throw("Hashset too small for key " ++ hash_value.show() ++ " and length " ++ new_set.data.length().show())
        }
        Just(lst) -> {
            match lst {
                Nothing -> {
                    new_set(data = new_set.data.take(hash_value) ++ Cons(Just([key]), new_set.data.drop(hash_value + 1)), amount = new_set.amount + 1)
                }
                Just(row) -> {
                    val new_row = row.filter() fn (k) {
                        match (new_set.cmp)(k, key) {
                            Lt -> True
                            Eq -> False
                            Gt -> True
                        }
                    }

                    new_set(data = new_set.data.take(hash_value) ++ Cons(Just(Cons(key, new_row)), new_set.data.drop(hash_value + 1)), amount = new_set.amount + 1)
                }
            }
        }
    }
}

pub fun get<a>(set : hashset<a>, key : a) : <div,hash<a>|_e> maybe<a> {
        
        val hash_value = key.hash() % set.data.length();
        match set.data[hash_value] {
            Nothing -> Nothing
            Just(lst) -> {
                match lst {
                    Nothing -> Nothing
                    Just(list) -> {
                        var value := Nothing
                        match list[key.hash() % list.length()] {
                            Nothing -> Nothing
                            Just(value) -> {
                                match (set.cmp)(value, key) {
                                    Lt -> Nothing
                                    Eq -> Just(value)
                                    Gt -> Nothing
                                }
                            }
                        }
                    }
                }
            }
        }
}

pub fun remove<a>(set : hashset<a>, key : a) : <hash<a>,div|_e> hashset<a> {
        
        val hash_value = key.hash() % set.data.length()
        match set.data[hash_value] {
            Nothing -> set
            Just(mlist) -> {
                match mlist {
                    Nothing -> set
                    Just(list) -> {
                        
                        var new_list := list.filter() fn (value) {
                            match (set.cmp)(value, key) {
                                Lt -> True
                                Eq -> False
                                Gt -> True
                            }
                        }
                        set(data = set.data.take(hash_value) ++ Cons(Just(new_list), set.data.drop(hash_value + 1)), amount = set.amount - 1)
                    }
                }
            }
        }
}

pub fun contains<a>(set : hashset<a>, key : a) : <div,hash<a>|_e> bool {
    match set.get(key) {
        Nothing -> False
        Just(_) -> True
    }
}

pub fun list<a>(set : hashset<a>) : <div|_e> list<a> {
    var list := []
    set.data.reverse().foreach() fn (row) {
        match row {
            Nothing -> ()
            Just(row) -> {
                row.foreach() fn (value) {
                    list := Cons(value, list)
                    ()
                }
            }
        }
    }
    list
}

pub fun length<a>(set : hashset<a>) : <div|_e> int {
    set.amount
}