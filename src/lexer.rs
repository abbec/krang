#[derive(Debug, Clone)]
pub struct Lexer;

#[derive(Debug)]
pub enum Token {
    LeftParen,
    RightParen,
}

impl Lexer {
    pub fn new() -> Self {
        Self
    }

    pub async fn run(&self, _content: &str) -> Vec<Token> {
        vec![ Token::LeftParen, Token::RightParen ]
    }
}

#[cfg(test)]
mod tests {}
