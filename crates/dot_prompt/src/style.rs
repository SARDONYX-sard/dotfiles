use crate::Target;

#[derive(Clone, Copy)]
pub enum Color {
    Reset,
    Bold,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
}

impl Color {
    const fn code(self) -> &'static str {
        match self {
            Self::Reset => "0",
            Self::Bold => "1",
            Self::Red => "31",
            Self::Green => "32",
            Self::Yellow => "33",
            Self::Blue => "34",
            Self::Magenta => "35",
            Self::Cyan => "36",
        }
    }
}

pub struct Painter {
    target: Target,
}

impl Painter {
    pub const fn new(target: Target) -> Self {
        Self { target }
    }

    pub fn paint(&self, color: Color, text: &str) -> String {
        let (open, close) = match self.target {
            Target::Bash => ("\x01", "\x02"),
            Target::Plain => ("", ""),
        };
        format!(
            "{open}\x1b[{}m{close}{text}{open}\x1b[0m{close}",
            color.code()
        )
    }
}
