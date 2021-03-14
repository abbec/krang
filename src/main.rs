fn main() {
    println!("Starting REPL");
    if let Err(e) = krang::repl() {
        eprintln!("{}", e);
        ::std::process::exit(1);
    }
}
