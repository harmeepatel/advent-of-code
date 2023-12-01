use std::collections::HashMap;

fn main() {
    let f = include_str!("input5");
    let mut containers: HashMap<i32, Vec<char>> = HashMap::new();

    // a
    for line in f.lines().take(8) {
        for (idx, i) in (1..34).step_by(4).enumerate() {
            let mut id: i32 = i - (idx as i32 * 4 - idx as i32);
            if i == 1 {
                id = 1;
            }
            containers
                .entry(id)
                .and_modify(|c| c.push(line.chars().nth(i as usize).unwrap()))
                .or_insert_with(|| {
                    let mut c = Vec::new();
                    c.push(line.chars().nth(i as usize).unwrap());
                    c
                });
        }
    }
    for (_, val) in containers.iter_mut() {
        val.reverse();
    }

    // let containers: HashMap<i32, Vec<char>> =
    dbg!(containers);
    // b
}
