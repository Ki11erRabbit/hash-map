pub import hash


fun test_insert() {
    var map : hashmap<int,int> := hashmap(compare : (int, int) -> order)


    
    with fun hash(x : int) { hasher(x) }
    for(0, 1000) fn (i) {
        println("Inserting " ++ i.show() ++ " into map ")
        map := map.insert(i, i)
        ()
    }
}

fun test_get() {
    var map : hashmap<int,int> := hashmap(compare : (int, int) -> order)

    with fun hash(x : int) { hasher(x) }
    for(0, 1000) fn (i) {
        println("Inserting " ++ i.show() ++ " into map ")
        map := map.insert(i, i)
        ()
    }

    for(0, 1000) fn (i) {
        println("Getting " ++ i.show() ++ " from map ")
        match map.get(i) {
            Nothing -> {
                print("Nothing")
            }
            Just(value) -> {
                print("Just(" ++ value.show() ++ ")")
            }
        }
        println("")
        ()
    }
}

fun test_pop() {
    var map : hashmap<int,int> := hashmap(compare : (int, int) -> order)
    with fun hash(x : int) { hasher(x) }
    for(0, 1000) fn (i) {
        println("Inserting " ++ i.show() ++ " into map ")
        map := map.insert(i, i)
        ()
    }

    for(0, 1000) fn (i) {
        println("Popping " ++ i.show() ++ " from map ")
        map.pop(i)
        ()
    }
}

fun main() {
   
    (handler {
        ctl throw-exn(exn) {
            print("Exception: ")
            exn.show().println()
            ()
        }}) fn (){
            test_insert()
        }
    
    (handler {
        ctl throw-exn(exn) {
            print("Exception: ")
            exn.show().println()
            ()
        }}) fn () {
            test_get()
        }
        
    (handler {
        ctl throw-exn(exn) {
            print("Exception: ")
            exn.show().println()
            ()
        }}) fn () {
            test_pop()
        }
}

