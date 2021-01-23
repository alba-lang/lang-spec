function identity (x) { return x }

var nil = [0]

function cons (hd, tl) {
    return [1, hd, tl]
}

var b = cons ('b', nil)
var a = cons ('a', b)

function foldLeft (f, b, xs) {
    while (true) {
        switch (xs[0]) {
        case 0:
            return b
        default:
            b  = f(xs[1], b)        // updates must be done in parallel!
            xs = xs[2]
        }
    }
}


function append (xs, ys) {
    var k = identity
    function nextK (xs, k) {
        return (r) => {return k ([1, xs[1], r])}
    }
    while(true){
        switch (xs[0]){
            case 0:
                return k(ys)
            default:
                k  = nextK(xs,k)
                xs = xs[2]
        }
    }
}

function reverse (xs) {
    var k = identity
    function nextK (xs, k) {
        return (r) => {return k (append(r, cons (xs[1],nil)))}
    }
    while(true) {
        switch (xs[0]){
            case 0:
                return k ([0])
            default:
                k = nextK(xs,k)
                xs = xs[2]
        }
    }
}


function toArray (xs) {
    var arr = []
    while(true){
        switch (xs[0]){
            case 0:
                return arr
            default:
                arr.push(xs[1])
                xs = xs[2]
        }
    }
}


function fromArray (arr) {
    var i = arr.length
    var r = nil
    while (0 < i) {
        i = i - 1
        r = cons (arr[i], r)
    }
    return r
}
