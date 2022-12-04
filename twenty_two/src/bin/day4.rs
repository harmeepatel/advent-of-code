fn main() {
    let f = include_str!("input4");
    let mut input: Vec<Vec<i32>> = Vec::new();

    // a
    for line in f.lines() {
        let elves = line.split(',');
        for i in elves {
            let range: Vec<i32> = i.split('-').map(|a| a.parse::<i32>().unwrap()).collect();
            let a: Vec<i32> = (range[0]..range[1] + 1).collect();
            input.push(a);
        }
    }

    let mut free_elves = 0;
    for i in input.chunks(2) {
        if i[0].iter().all(|a| i[1].contains(a)) {
            free_elves += 1;
        } else if i[1].iter().all(|a| i[0].contains(a)) {
            free_elves += 1;
        }
    }

    dbg!(free_elves);
    // b
    free_elves = 0;
    for i in input.chunks(2) {
        if i[0].iter().any(|a| i[1].contains(a)) {
            free_elves += 1;
        } else if i[1].iter().any(|a| i[0].contains(a)) {
            free_elves += 1;
        }
    }

    dbg!(free_elves);
}
