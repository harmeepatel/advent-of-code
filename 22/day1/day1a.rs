use std::{
    fs::File,
    io::{prelude::*, BufReader},
};

fn main() {
    let f = File::open("input.txt").unwrap();
    let f = BufReader::new(f);
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

        // println!("{}", line.unwrap().parse::<usize>().unwrap());
    }
    let mut max = 0;
    for cal in cals {
        if cal > max {
            max = cal
        }
    }
    dbg!(max);
}
