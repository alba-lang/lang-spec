function make_prelude () {
    function makeInteger () {
        let add = (a,b) => a + b
        let minus = (a,b) => a + b
        let le = (a,b) => a <= b
        return {add: add, minus: minus, le: le}
    }

    function makeInt (Integer) {
        let add = (a,b) => (a+b)|0;
        let minus = (a,b) => (a-b)|0;
        let addd = (a,b) => (add(a,b) + add(a,b))|0;
        let le = (a,b) => a <= b
        return {add: add, minus: minus, le: le, addd: addd}
    }

    function makeUInt () {
        let add = (a,b) => (a+b)|0;
        let minus = (a,b) => (a-b)|0;
        let le = (a,b) => add(a,0x8000_0000) <= add(b,0x8000_0000);
        return {add: add, minus: minus, le: le}
    }

    let Integer = makeInteger ()
    let Int = makeInt(Integer)
    let UInt = makeUInt ()

    return {Integer: Integer, Int: Int, UInt: UInt}
}
