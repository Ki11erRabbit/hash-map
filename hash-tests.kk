pub import hash


fun test_insert() {
    var map := hashmap()

    for(0, 1000) fn (i) {
        print("Inserting " ++ i.show() ++ " into map ")
        i.show().hash().println()
        map := map.insert(i.show(), i)
        ()
    }
}

fun test_get() {
    var map := hashmap()

    for(0, 1000) fn (i) {
        print("Inserting " ++ i.show() ++ " into map ")
        i.show().hash().println()
        map := map.insert(i.show(), i)
        ()
    }

    for(0, 1000) fn (i) {
        print("Getting " ++ i.show() ++ " from map ")
        i.show().hash().println()
        match map.get(i.show()) {
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

fun main() {
   
    (handler {
        ctl throw-exn(exn) {
            print("Exception: ")
            exn.show().println()
            ()
        }}) fn (){
            test_insert()
        }
    
    with handler 
        ctl throw-exn(exn) {
            print("Exception: ")
            exn.show().println()
            ()
        }
    test_get()
}

