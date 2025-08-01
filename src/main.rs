use anyhow::{Context, Result};
use clap::{Parser, Subcommand, ValueEnum};
use icns::{IconFamily, IconType};
use image::imageops::FilterType;
use std::fs::File;
use std::io::BufWriter;
use std::path::Path;

#[derive(Parser)]
#[command(name = "png2icns")]
#[command(about = "Convert PNG images to ICNS format")]
#[command(version = "1.0.0")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    /// Input PNG file path
    #[arg(short, long, global = true)]
    input: Option<String>,

    /// Output ICNS file path
    #[arg(short, long, global = true)]
    output: Option<String>,

    /// Quality preset for icon generation
    #[arg(short, long, default_value = "standard", global = true)]
    preset: QualityPreset,

    /// Custom sizes (comma-separated, e.g., "16,32,64,128,256,512")
    #[arg(short, long, global = true)]
    sizes: Option<String>,

    /// Verbose output
    #[arg(short, long, global = true)]
    verbose: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Convert PNG to ICNS (default action)
    Convert {
        /// Input PNG file path
        #[arg(short, long)]
        input: String,

        /// Output ICNS file path
        #[arg(short, long)]
        output: String,
    },
    /// Generate shell completion scripts
    Completion {
        /// Shell type
        #[arg(value_enum)]
        shell: Shell,
    },
}

#[derive(Clone, Debug, ValueEnum)]
enum Shell {
    /// Bash completion
    Bash,
    /// Zsh completion
    Zsh,
    /// Fish completion
    Fish,
    /// PowerShell completion
    #[value(name = "powershell")]
    Pwsh,
}

#[derive(Clone, Debug, ValueEnum)]
enum QualityPreset {
    /// Basic sizes: 16, 32, 128, 256, 512
    Basic,
    /// Standard sizes: 16, 32, 64, 128, 256, 512, 1024
    Standard,
    /// Full sizes: all supported ICNS sizes
    Full,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Some(Commands::Convert {
            ref input,
            ref output,
        }) => {
            convert_image(input, output, &cli)?;
        }
        Some(Commands::Completion { shell }) => {
            generate_completion(shell);
        }
        None => {
            // Default behavior: convert if input and output are provided
            if let (Some(input), Some(output)) = (&cli.input, &cli.output) {
                convert_image(input, output, &cli)?;
            } else {
                eprintln!("Error: Input and output files are required");
                eprintln!("Usage: png2icns -i <INPUT> -o <OUTPUT>");
                eprintln!("       png2icns convert -i <INPUT> -o <OUTPUT>");
                eprintln!("       png2icns completion <SHELL>");
                eprintln!("Run 'png2icns --help' for more information");
                std::process::exit(1);
            }
        }
    }

    Ok(())
}

fn convert_image(input: &str, output: &str, cli: &Cli) -> Result<()> {
    if cli.verbose {
        println!("🖼️  PNG to ICNS Converter");
        println!("Input: {input}");
        println!("Output: {output}");
        println!("Preset: {:?}", cli.preset);
    }

    // Check if input file exists
    if !Path::new(input).exists() {
        anyhow::bail!("Input file does not exist: {input}");
    }

    // Load the input PNG image
    let img = image::open(input).with_context(|| format!("Failed to open input image: {input}"))?;

    if cli.verbose {
        println!("✅ Loaded image: {}x{}", img.width(), img.height());
    }

    // Determine sizes to generate
    let sizes = if let Some(custom_sizes) = &cli.sizes {
        parse_custom_sizes(custom_sizes)?
    } else {
        get_preset_sizes(&cli.preset)
    };

    if cli.verbose {
        println!("📏 Generating sizes: {sizes:?}");
    }

    // Create ICNS icon family
    let mut icon_family = IconFamily::new();
    let mut added_count = 0;

    // Generate icons for each size
    for &size in &sizes {
        if cli.verbose {
            println!("🔄 Processing size: {size}x{size}");
        }

        let _icon_type = match size_to_icon_type(size) {
            Some(t) => t,
            None => {
                if cli.verbose {
                    println!("⚠️  Skipping unsupported size: {size}");
                }
                continue;
            }
        };

        // Resize image
        let resized = img.resize_exact(size, size, FilterType::Lanczos3);

        // Convert to RGBA8
        let rgba_image = resized.to_rgba8();

        // Create ICNS image
        match icns::Image::from_data(icns::PixelFormat::RGBA, size, size, rgba_image.into_raw()) {
            Ok(icns_image) => {
                // Add to icon family
                match icon_family.add_icon(&icns_image) {
                    Ok(_) => {
                        added_count += 1;
                        if cli.verbose {
                            println!("✅ Added {size}x{size} icon");
                        }
                    }
                    Err(e) => {
                        if cli.verbose {
                            println!("⚠️  Failed to add {size}x{size} icon: {e}");
                        }
                    }
                }
            }
            Err(e) => {
                if cli.verbose {
                    println!("⚠️  Failed to create {size}x{size} icon: {e}");
                }
            }
        }
    }

    if added_count == 0 {
        anyhow::bail!("No icons were successfully added to the ICNS file");
    }

    if cli.verbose {
        println!("📊 Total icons added: {added_count}");
    }

    // Create output directory if it doesn't exist
    if let Some(parent) = Path::new(output).parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("Failed to create output directory: {parent:?}"))?;
    }

    // Write ICNS file
    let output_file =
        File::create(output).with_context(|| format!("Failed to create output file: {output}"))?;

    let mut writer = BufWriter::new(output_file);
    icon_family
        .write(&mut writer)
        .with_context(|| "Failed to write ICNS file")?;

    if cli.verbose {
        println!("🎉 Successfully created ICNS file: {output}");

        // Show file size
        if let Ok(metadata) = std::fs::metadata(output) {
            println!("📊 File size: {} bytes", metadata.len());
        }
    } else {
        println!("✅ Converted {input} -> {output}");
    }

    Ok(())
}

fn generate_completion(shell: Shell) {
    match shell {
        Shell::Bash => print_bash_completion(),
        Shell::Zsh => print_zsh_completion(),
        Shell::Fish => print_fish_completion(),
        Shell::Pwsh => print_powershell_completion(),
    }
}

fn print_bash_completion() {
    println!(
        r#"#!/bin/bash
# Bash completion for png2icns

_png2icns_completions() {{
    local cur prev opts
    COMPREPLY=()
    cur="${{COMP_WORDS[COMP_CWORD]}}"
    prev="${{COMP_WORDS[COMP_CWORD-1]}}"
    
    opts="-i --input -o --output -p --preset -s --sizes -v --verbose -h --help -V --version convert completion"
    presets="basic standard full"
    shells="bash zsh fish powershell"
    
    case "${{prev}}" in
        -i|--input)
            # Complete PNG files
            COMPREPLY=( $(compgen -f -X "!*.png" -- ${{cur}}) )
            return 0
            ;;
        -o|--output)
            # Complete ICNS files
            COMPREPLY=( $(compgen -f -X "!*.icns" -- ${{cur}}) )
            return 0
            ;;
        -p|--preset)
            # Complete presets
            COMPREPLY=( $(compgen -W "${{presets}}" -- ${{cur}}) )
            return 0
            ;;
        -s|--sizes)
            # Complete common sizes
            COMPREPLY=( $(compgen -W "16,32,64,128,256,512" -- ${{cur}}) )
            return 0
            ;;
        completion)
            # Complete shell types
            COMPREPLY=( $(compgen -W "${{shells}}" -- ${{cur}}) )
            return 0
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "${{opts}}" -- ${{cur}}) )
    return 0
}}

complete -F _png2icns_completions png2icns"#
    );
}

fn print_zsh_completion() {
    println!(
        r#"#compdef png2icns

_png2icns() {{
    local context state line
    typeset -A opt_args

    _arguments \
        '(-i --input){{-i,--input}}'[Input PNG file path]:PNG file:_files -g "*.png"' \
        '(-o --output){{-o,--output}}'[Output ICNS file path]:ICNS file:_files -g "*.icns"' \
        '(-p --preset){{-p,--preset}}'[Quality preset]:preset:(basic standard full)' \
        '(-s --sizes){{-s,--sizes}}'[Custom sizes]:sizes:' \
        '(-v --verbose){{-v,--verbose}}'[Verbose output]' \
        '(-h --help){{-h,--help}}'[Show help]' \
        '(-V --version){{-V,--version}}'[Show version]' \
        '1: :_png2icns_commands' \
        '*:: :->args'

    case $state in
        args)
            case $words[1] in
                convert)
                    _arguments \
                        '(-i --input){{-i,--input}}'[Input PNG file path]:PNG file:_files -g "*.png"' \
                        '(-o --output){{-o,--output}}'[Output ICNS file path]:ICNS file:_files -g "*.icns"'
                    ;;
                completion)
                    _arguments \
                        '1:shell:(bash zsh fish powershell)'
                    ;;
            esac
            ;;
    esac
}}

_png2icns_commands() {{
    local commands
    commands=(
        'convert:Convert PNG to ICNS'
        'completion:Generate shell completion scripts'
    )
    _describe 'commands' commands
}}

_png2icns "$@""#
    );
}

fn print_fish_completion() {
    println!(
        r#"# Fish completion for png2icns

complete -c png2icns -s i -l input -d "Input PNG file path" -F
complete -c png2icns -s o -l output -d "Output ICNS file path" -F
complete -c png2icns -s p -l preset -d "Quality preset" -xa "basic standard full"
complete -c png2icns -s s -l sizes -d "Custom sizes"
complete -c png2icns -s v -l verbose -d "Verbose output"
complete -c png2icns -s h -l help -d "Show help"
complete -c png2icns -s V -l version -d "Show version"

# Subcommands
complete -c png2icns -f -n "__fish_use_subcommand" -a "convert" -d "Convert PNG to ICNS"
complete -c png2icns -f -n "__fish_use_subcommand" -a "completion" -d "Generate shell completion scripts"

# Completion subcommand
complete -c png2icns -f -n "__fish_seen_subcommand_from completion" -a "bash zsh fish powershell" -d "Shell type"

# Convert subcommand
complete -c png2icns -n "__fish_seen_subcommand_from convert" -s i -l input -d "Input PNG file path" -F
complete -c png2icns -n "__fish_seen_subcommand_from convert" -s o -l output -d "Output ICNS file path" -F"#
    );
}

fn print_powershell_completion() {
    println!(
        r#"# PowerShell completion for png2icns

Register-ArgumentCompleter -Native -CommandName png2icns -ScriptBlock {{
    param($commandName, $wordToComplete, $cursorPosition)
    
    $completions = @()
    
    switch -regex ($wordToComplete) {{
        '^-i$|^--input$' {{
            $completions += Get-ChildItem -Path "*.png" | ForEach-Object {{ $_.Name }}
        }}
        '^-o$|^--output$' {{
            $completions += @("output.icns")
        }}
        '^-p$|^--preset$' {{
            $completions += @("basic", "standard", "full")
        }}
        '^-s$|^--sizes$' {{
            $completions += @("16,32,64,128,256,512")
        }}
        '^completion$' {{
            $completions += @("bash", "zsh", "fish", "powershell")
        }}
        default {{
            $completions += @("-i", "--input", "-o", "--output", "-p", "--preset", "-s", "--sizes", "-v", "--verbose", "-h", "--help", "-V", "--version", "convert", "completion")
        }}
    }}
    
    $completions | Where-Object {{ $_ -like "$wordToComplete*" }}
}}"#
    );
}

fn parse_custom_sizes(sizes_str: &str) -> Result<Vec<u32>> {
    sizes_str
        .split(',')
        .map(|s| {
            s.trim()
                .parse::<u32>()
                .with_context(|| format!("Invalid size: {s}"))
        })
        .collect()
}

fn get_preset_sizes(preset: &QualityPreset) -> Vec<u32> {
    match preset {
        QualityPreset::Basic => vec![16, 32, 128, 256, 512],
        QualityPreset::Standard => vec![16, 32, 64, 128, 256, 512],
        QualityPreset::Full => vec![16, 32, 64, 128, 256, 512],
    }
}

fn size_to_icon_type(size: u32) -> Option<IconType> {
    match size {
        16 => Some(IconType::RGB24_16x16),
        32 => Some(IconType::RGB24_32x32),
        64 => Some(IconType::RGBA32_64x64),
        128 => Some(IconType::RGB24_128x128),
        256 => Some(IconType::RGBA32_256x256),
        512 => Some(IconType::RGBA32_512x512),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_custom_sizes() {
        let result = parse_custom_sizes("16,32,64").unwrap();
        assert_eq!(result, vec![16, 32, 64]);
    }

    #[test]
    fn test_size_to_icon_type() {
        assert_eq!(size_to_icon_type(16), Some(IconType::RGB24_16x16));
        assert_eq!(size_to_icon_type(32), Some(IconType::RGB24_32x32));
        assert_eq!(size_to_icon_type(64), Some(IconType::RGBA32_64x64));
        assert_eq!(size_to_icon_type(999), None);
    }

    #[test]
    fn test_preset_sizes() {
        let basic = get_preset_sizes(&QualityPreset::Basic);
        assert!(basic.contains(&16));
        assert!(basic.contains(&512));

        let standard = get_preset_sizes(&QualityPreset::Standard);
        assert!(standard.contains(&512));
        assert!(!standard.contains(&1024)); // 1024 is no longer supported
    }
}
