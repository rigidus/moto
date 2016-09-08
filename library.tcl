#!/usr/bin/wish

package require Img

proc int x { expr int($x) }

proc ShowPixel {x y i} {
    set c "- - -"
    catch { set c [$::img1 get $x $y] }
    # wm title . "$x $y #$i : $c"
    return "$x $y #$i : $c"
}

proc ShowColor {w x y} {
    # idea: RS
    set color ""
    set id [$w find withtag current]
    if {$id>0} {
        set xx $x
        set yy $y
        foreach {x0 y0 x1 y1} [$w bbox $id] break
        incr xx -$x0
        incr yy -$x0
        #wm title . "$x $y #$id : $x0 $y0  $x1 $y1 : $xx $yy"
        #return

        switch -- [$w type $id] {
            image {set color [[$w itemcget $id -image] get $xx $yy]}
            line - polygon - rectangle - oval - text {
                set cName [$w itemcget $id -fill]
                set color [winfo rgb $w $cName]
            }
        }

        wm title . "$x $y #$id $xx $yy = $color"
        return "$x $y #$id $xx $yy = $color"
    } else {
        wm title . "$x $y"
        return "$x $y"
    }
}

set fn library.gif
set img1 [image create photo -file $fn]
set width  [image width $img1]
set height [image height $img1]
set img2 [image create photo -width $width -height $height]

pack [canvas .c -width $width -height $height]

# bind . <Configure> {wm title . "Canvas Example (Height = [winfo height .c] / Width = [winfo width .c])"}


for {set yi 0} {$yi < $height} {incr yi} {
    set white_cnt 0
    for {set xi 0} {$xi < $width} {incr xi} {
        lassign [$img1 get $xi $yi] r g b
        set avg [expr ($r + $g + $b) / 3]
        # puts $avg
        if { $yi > 0 && $xi > 0} {
            if { $avg < 200 } {
                $img2 put [format "#%02x%02x%02x" 0 0 0 ] -to \
                    $xi $yi [expr $xi - 1] [expr $yi - 1]
            } else {
                set white_cnt [expr $white_cnt + 1]
                $img2 put [format "#%02x%02x%02x" 255 255 255 ] -to \
                    $xi $yi [expr $xi - 1] [expr $yi - 1]
            }
        }
    }
    if { $white_cnt == [expr $width - 1] } {
        if { $yi > 0} {
            $img2 put [format "#%02x%02x%02x" 220 220 220 ] -to \
                0 $yi $width [expr $yi - 1]
        }
    }
}

.c create image  0  0 -image $img2 -anchor nw -tag Copy1

# .c create text  55  95  -text "ABC"     -fill white
# .c create rect 125  25  145  45         -fill red
# .c create oval  25 125   45 145         -fill green
# .c create line  15 100   70 125         -fill blue
# .c create poly 100  65  130  65 100  20 -fill cyan -outline black

#bind .c <Motion> { ShowPixel    [int [%W canvasx %x]] [int [%W canvasy %y]] [%W find withtag current] }
bind .c <Motion> { ShowColor %W [int [%W canvasx %x]] [int [%W canvasy %y]] }
