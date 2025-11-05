use zed_extension_api as zed;

struct ObjcExtension;

impl zed::Extension for ObjcExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        let path = worktree
            .which("clangd")
            .ok_or_else(|| "clangd must be installed and available in PATH".to_string())?;

        Ok(zed::Command {
            command: path,
            args: vec![
                // Use compile_commands.json if available
                "--compile-commands-dir".to_string(),
                worktree.root_path(),
                // Enable background indexing for better performance
                "--background-index".to_string(),
                // Reduce log verbosity
                "--log=error".to_string(),
                // Enable header insertion with include-what-you-use style
                "--header-insertion=iwyu".to_string(),
                // Use #import instead of #include for Objective-C (important for ObjC!)
                "--import-insertions".to_string(),
                // Enable clang-tidy checks
                "--clang-tidy".to_string(),
                // Enable completion edits near cursor (dot-to-arrow conversion)
                "--completion-style=detailed".to_string(),
                // Set number of workers for background index
                "-j=4".to_string(),
            ],
            env: Default::default(),
        })
    }
}

zed::register_extension!(ObjcExtension);
