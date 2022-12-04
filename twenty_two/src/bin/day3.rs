fn main() {
    let f = include_str!("input3");
    // let mut inputs: Vec<(_, _)> = Vec::new();
    let mut p_sum = 0;

    let mut c = 0;
    // a
    for line in f.lines() {
        c += 1;
        let line = String::from(line);
        let mid = &line.len() / 2;
        let (a, b) = line.split_at(mid);

        for i in a.chars() {
            if b.contains(i) {
                print!("TRER{} common: {} -> ", c, i);
                if i.is_lowercase() {
                    p_sum += i as i32 - 96;
                    println!("{}", i as i32 - 96);
                } else {
                    p_sum += i as i32 - 38;
                    println!("{}", i as i32 - 38);
                }
            }
        }
    }
    dbg!(p_sum);

    // b
}
