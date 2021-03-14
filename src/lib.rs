mod lexer;

use std::io::{stdin, stdout, BufRead, Write};

use tokio::runtime;

pub fn repl() -> Result<(), String> {
    let lexer = lexer::Lexer::new();

    #[cfg(target_os = "wasi")]
    let runtime = runtime::Builder::new_current_thread().build().unwrap();
    #[cfg(not(target_os = "wasi"))]
    let runtime = runtime::Runtime::new().unwrap();

    let mut line = String::new();
    println!("  This is the REPL, type an expression followed by <enter>");
    println!("  To exit, press ctrl-d");
    loop {
        print!("-> ");
        stdout().flush().unwrap();

        match stdin().lock().read_line(&mut line) {
            Ok(br) => {
                if br == 0 {
                    println!("bye!");
                    return Ok(());
                }

                runtime.block_on(async {
                    let token_stream = lexer.run(&line).await;
                    println!("{:#?}", token_stream);
                })
            }
            Err(e) => return Err(format!("Failed to get REPL line: {}", e)),
        }
    }
}

pub fn eval_file() {}

pub fn eval_string() {}
