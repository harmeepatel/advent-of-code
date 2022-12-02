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

        // println!("{}", line.unwrap().parse::<usize>().unwrap());
    }
    let mut max = 0;
    for cal in cals.iter() {
        if *cal > max {
            max = *cal
        }
    }
    dbg!(max);

    // b
    let mut total = 0;
    for _ in 0..3 {
        let mut max = 0;
        for cal in cals.iter() {
            if *cal > max {
                max = *cal
            }
        }
        total = total + max;
        cals.remove(cals.iter().position(|&x| x == max).unwrap());
    }
    dbg!(total);
}
