use zed_extension_api as zed;

struct ObjcExtension;

impl zed::Extension for ObjcExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        _worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        // Objective-C doesn't have a dedicated language server in this basic implementation
        // Future implementations could add clangd or sourcekit-lsp support
        Err("No language server configured for Objective-C".into())
    }
}

zed::register_extension!(ObjcExtension);
