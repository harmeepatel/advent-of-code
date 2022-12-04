fn main() {
    let f = include_str!("input1");

    // a
    let mut cals: Vec<i32> = Vec::new();
    let mut cal = 0;
    for line in f.lines() {
        if line.is_empty() {
            cals.push(cal);
            cal = 0;
            continue;
        }
        cal = cal + line.parse::<i32>().unwrap();
    }
    cals.sort();
    cals.reverse();
    let max = cals.iter().max();
    dbg!(max);

    // b
    let mut total = 0;
    for _ in 0..3 {
        let max = *cals.iter().max().unwrap();
        total = total + max;
        cals.remove(cals.iter().position(|&x| x == max).unwrap());
    }
    dbg!(total);
}
