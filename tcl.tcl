#!/usr/bin/tclsh

set size_of_char 16
set msg "слава роботам"
set key "нашсуперключ."

puts "msg \n $msg"
puts "key \n $key"

proc splitter { size param {args {}} } {
    # Разбивает входную последовательность =param=
    # на подпоследовательности размером =size=.
    # Если остается хвост, размером меньше size
    # - сигнализирует ошибку"
    set len [string length $param]
    if {$len >= $size} {
        set args [lindex $args 0]
        lappend args [string range $param 0 $size-1]
        splitter $size [string range $param $size end] $args
    } else {
        if { 0 == $len } {
            return [lindex $args 0]
        } else {
            error $param
        }
    }
}

# puts [splitter 2 "sdfergergerg"] ;# => sd fe rg er ge rg

proc integer->bit-list { int {args {}} } {
    # Преобразует входное число в список битов
    if { $int > 0 } {
        set args [lindex $args 0]
        set i [expr $int / 2]
        set r [expr $int % 2]
        integer->bit-list $i [linsert $args 0 $r]
    } else {
        if { 0 == [llength [lindex $args 0]] } {
            [linsert $args 0 $r]
        } else {
            return [lindex $args 0]
        }
    }
}

# puts [integer->bit-list 13] ;# => 1 1 0 1

proc string->bit-list { str } {
    global size_of_char
    set acc {}
    foreach char [split $str ""] {
        set char_code  [scan $char %c]
        set bit_list   [integer->bit-list $char_code]
        set append_cnt [expr { $size_of_char - [llength $bit_list]}]
        set appender   [split [string repeat "0" $append_cnt] ""]
        set result     [concat $appender $bit_list]
        set acc        [concat $acc $result]
    }
    return $acc
}

puts "msg bit-list \n [string->bit-list $msg]"
puts "key bit-list \n [string->bit-list $key]"

proc crypt { msg key } {
    set idx 0;
    set max [llength $msg]
    set result {}
    while { $idx < $max } {
        set result [concat $result [expr [lindex $msg $idx] ^ [lindex $key $idx]]]
        incr idx
    }
    return $result
}

puts "encrypted \n [crypt [string->bit-list $msg] [string->bit-list $key]]"

proc show { bit_list } {
    set result {}
    foreach item [splitter 4 [join $bit_list ""]] {
        switch $item {
            0000 { set res 0 }
            0001 { set res 1 }
            0010 { set res 2 }
            0011 { set res 3 }
            0100 { set res 4 }
            0101 { set res 5 }
            0110 { set res 6 }
            0111 { set res 7 }
            1000 { set res 8 }
            1001 { set res 9 }
            1010 { set res A }
            1011 { set res B }
            1100 { set res C }
            1101 { set res D }
            1110 { set res E }
            1111 { set res F }
        }
        set result [concat $result $res]
    }
    return [join $result ""]
}

puts "show \n [show [crypt [string->bit-list $msg] [string->bit-list $key]]]"

proc unshow { hex_string } {
    set result {}
    foreach item [split $hex_string ""] {
        switch $item {
            0 { set res 0000 }
            1 { set res 0001 }
            2 { set res 0010 }
            3 { set res 0011 }
            4 { set res 0100 }
            5 { set res 0101 }
            6 { set res 0110 }
            7 { set res 0111 }
            8 { set res 1000 }
            9 { set res 1001 }
            A { set res 1010 }
            B { set res 1011 }
            C { set res 1100 }
            D { set res 1101 }
            E { set res 1110 }
            F { set res 1111 }
        }
        set result [concat $result $res]
    }
    return [split [join $result ""] ""]
}

puts "unshow \n [unshow [show [crypt [string->bit-list $msg] [string->bit-list $key]]]]"

puts "decrypted bit-list \n [crypt [unshow [show [crypt [string->bit-list $msg] [string->bit-list $key]]]] [string->bit-list $key]]"


proc bit-list->integer { bit_list {args {}} } {
    # Преобразует список битов в число
    set acc 0
    set idx 0
    set max [expr [llength $bit_list] - 1]
    while {$idx <= $max} {
        set pos [expr $max - $idx]
        if { 1 == [lindex $bit_list $pos] } {
            set acc [expr $acc + { round(pow(2, $idx)) }]
        }
        incr idx
    }
    return $acc
}

# puts [bit-list->integer [integer->bit-list 11]] ;# => 11

proc bit-list->string { bit_list } {
    global size_of_char
    set acc {}
    foreach code [splitter $size_of_char [join $bit_list ""]] {
        set char [format "%c" [bit-list->integer [split $code ""]]]
        if { 0 == [llength $char] } {
            set acc [concat $acc {" "}]
        } else {
            set acc [concat $acc $char]
        }
    }
    return [join $acc ""]
}

puts "decrypted \n [bit-list->string [crypt [unshow [show [crypt [string->bit-list $msg] [string->bit-list $key]]]] [string->bit-list $key]]]"
