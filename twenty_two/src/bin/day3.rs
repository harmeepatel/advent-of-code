use std::collections::{HashMap, HashSet};

fn main() {
    let f = include_str!("input3");
    let mut inputs: Vec<String> = Vec::new();
    let mut p_sum = 0;

    // a
    for line in f.lines() {
        inputs.push(String::from(line));
        let line = String::from(line);
        let mid = &line.len() / 2;
        let (a, b) = line.split_at(mid);

        for i in a.chars() {
            if b.contains(i) {
                if i.is_lowercase() {
                    p_sum += i as i32 - 96;
                    break;
                } else {
                    p_sum += i as i32 - 38;
                    break;
                }
            }
        }
    }
    dbg!(p_sum);

    // b
    p_sum = 0;
    for i in inputs.chunks(3) {
        let i: Vec<_> = i
            .to_vec()
            .iter()
            .map(|s| s.chars().collect::<HashSet<char>>())
            .collect();
        let mut h: HashMap<char, i32> = HashMap::new();
        for j in i.iter() {
            for k in j.iter() {
                h.entry(*k).and_modify(|v| *v += 1).or_insert(1);
            }
        }
        let a = h
            .iter()
            .find_map(|(k, v)| if *v == 3 { Some(k) } else { None })
            .unwrap();
        if a.is_lowercase() {
            p_sum += *a as i32 - 96;
        } else {
            p_sum += *a as i32 - 38;
        }
    }
    dbg!(p_sum);
}
