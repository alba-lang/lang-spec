"use strict"

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




/*********************************/
/* Continuation                  */
/*********************************/

/* Bounce type, done and more */

function done (a) {return [0,a]}
function more (f) {return [1,f]}

function iter (b) {
    for(;;){
        switch (b[0]) {
            case 0:
                return b[1]
            default:
                b = b[1]()
        }
    }
}






/* From here on untested!!! */

function pure (a) {
    return (k) => k(a)
}

function bind (m, f) {
    //return (k) => {return m (f (a,k))}
    return (k) => {return m ((a) => more ((e) => {return f (a,k)} ))}
}

function run (m) {
    return iter (m, (x) => {return done(x)})
}






/****************************/
/* Factorial                */
/****************************/


function factCPS(n){
    return (k) => {
        return [1, (e) => {
            if (n <= 1){
                return k(1)
            } else {
                return factCPS (n - 1) ((res) => {return k (n * res)})
            }
        }]
    }
}

function factB (n, k) {
    function next (n,k) {
        (e) => {
            return (
                if (n <= 1) { return k(1) }
                else {
                    return factB (n - 1,
                                  (res) => {return k (n * res)})
                }
            )
        }
    }
    return more (next (n,k))
}

function fact(n) {
    return iter( factCPS (n) (done))
}


/****************************/
/* Trees                    */
/****************************/


var empty = [0]

function node (l,x,r) {return [1,l,x,r]}


function preorderCPS (t, lst) {
    switch (t[0]) {
        case 0:
            return pure (lst)
        default:
            return bind (
                pure (lst),
                (b) => {
                    return bind(
                        preorderCPS (t[3], b),
                        (bR) => {return preorderCPS (t[1], bR)}
                    )})
    }
}


function preorder (t) {return run(preorderCPS (t,nil))}
