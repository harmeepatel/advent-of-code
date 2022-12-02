use std::{
    fs::File,
    io::{prelude::*, BufReader},
};

fn main() {
    let f = File::open("input.txt").unwrap();
    let f = BufReader::new(f);

    // a
    let mut cals: Vec<i32> = Vec::new();
    let mut cal = 0;
    for line in f.lines() {
        let line = line.ok().unwrap();
        if line.is_empty() {
            cals.push(cal);
            cal = 0;
            continue;
        }
        cal = cal + line.parse::<i32>().unwrap();
    }
    cals.sort();
    cals.reverse();
    let max = cals.iter().max().unwrap();
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
