#[derive(Debug, PartialEq, Clone, Copy)]
enum Play {
    Rock,
    Paper,
    Scissors,
}

#[derive(Debug, PartialEq, Clone, Copy)]
enum Res {
    Draw,
    Win,
    Loose,
}

trait Beats {
    fn beats(&self, play: Play) -> Res;
}

trait ResPlay {
    fn play(&self, res: Res) -> Play;
}

impl Beats for Play {
    fn beats(&self, play: Play) -> Res {
        if self == &play {
            return Res::Draw;
        }
        match self {
            Play::Rock => {
                if play == Play::Paper {
                    return Res::Loose;
                }
            }
            Play::Paper => {
                if play == Play::Scissors {
                    return Res::Loose;
                }
            }
            Play::Scissors => {
                if play == Play::Rock {
                    return Res::Loose;
                }
            }
        };
        Res::Win
    }
}
impl ResPlay for Play {
    fn play(&self, res: Res) -> Play {
        match res {
            Res::Draw => {
                return *self;
            }
            Res::Win => {
                return match self {
                    Play::Rock => Play::Paper,
                    Play::Paper => Play::Scissors,
                    Play::Scissors => Play::Rock,
                };
            }
            Res::Loose => {
                return match &self {
                    Play::Rock => Play::Scissors,
                    Play::Paper => Play::Rock,
                    Play::Scissors => Play::Paper,
                }
            }
        };
    }
}

fn get_score(tup: &(Play, Play)) -> i32 {
    let play_scr = match tup.1 {
        Play::Rock => 1,
        Play::Paper => 2,
        Play::Scissors => 3,
    };
    let res = match tup.1.beats(tup.0) {
        Res::Draw => 3,
        Res::Win => 6,
        Res::Loose => 0,
    };

    play_scr + res
}

fn main() {
    let f = include_str!("input2");
    let mut inputs: Vec<(Play, Play)> = Vec::new();

    // a
    for line in f.lines() {
        let play = line.split(' ').collect::<Vec<_>>();
        let play1 = match play[0] {
            "A" => Play::Rock,
            "B" => Play::Paper,
            "C" => Play::Scissors,
            _ => panic!("haha"),
        };
        let play2 = match play[1] {
            "X" => Play::Rock,
            "Y" => Play::Paper,
            "Z" => Play::Scissors,
            _ => panic!("haha"),
        };

        inputs.push((play1, play2));
    }

    let mut score: i32 = inputs.iter().map(|s| get_score(s)).sum();
    dbg!(score);

    // b
    let mut inputs: Vec<(Play, Res)> = Vec::new();
    for line in f.lines() {
        let play = line.split(' ').collect::<Vec<_>>();
        let p = match play[0] {
            "A" => Play::Rock,
            "B" => Play::Paper,
            "C" => Play::Scissors,
            _ => panic!("haha"),
        };
        let res = match play[1] {
            "X" => Res::Loose,
            "Y" => Res::Draw,
            "Z" => Res::Win,
            _ => panic!("haha"),
        };

        inputs.push((p, res));
    }
    let plays = inputs.iter().map(|s| s.0.play(s.1)).collect::<Vec<Play>>();
    score = 0;
    for i in 0..plays.len() {
        score = score + get_score(&(inputs[i].0, plays[i]));
    }
    dbg!(score);
}
