class FusionCli < Formula
  desc "Typed CAD commands and verified Design checkpoints for Autodesk Fusion"
  homepage "https://deandiasti.github.io/fusion-cli/"
  url "https://github.com/DeanDiasti/fusion-cli/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "6b4c27d414675715a09a152cefdf652eac7be0cdb5c61a2a55f08ec1d6150519"
  license "GPL-3.0-only"

  depends_on :macos
  depends_on "python@3.14"

  def install
    libexec.install "cli", "fusion_addin", "scripts"
    python = Formula["python@3.14"].opt_bin/"python3.14"
    (bin/"fusion").write <<~SH
      #!/bin/sh
      exec "#{python}" -S "#{opt_libexec}/cli/fusion_cli.py" "$@"
    SH
    (bin/"fusion-install-addin").write <<~SH
      #!/bin/sh
      exec "#{python}" -S "#{opt_libexec}/scripts/install_addin.py" "$@"
    SH
  end

  def caveats
    <<~EOS
      Autodesk Fusion must be installed separately.
      Save work, stop CadBot, then run:
        fusion-install-addin
      Restart Fusion and run CadBot from Scripts and Add-Ins.
      Repeat fusion-install-addin after every brew upgrade, before brew cleanup.
      Design edits require: fusion checkpoint begin --id NAME
      The CLI uses the Python standard library; no AI account is required.
      Uninstalling this formula does not remove the separately installed add-in or user data.
    EOS
  end

  test do
    require "json"
    assert_match "fusion design inspect", shell_output("#{bin}/fusion help")
    assert_match "--distance-mm", shell_output("#{bin}/fusion design sketches offset --help")
    assert_match "--document-id", shell_output("#{bin}/fusion checkpoint begin --help")
    assert_match "verified chain", shell_output("#{bin}/fusion checkpoint restore --help")
    version_info = JSON.parse(shell_output("#{bin}/fusion --version"))
    assert_equal 4, version_info.fetch("protocol")
    assert_match(/\A[0-9a-f]{16}\z/, version_info.fetch("build"))
    destination = testpath/"CadBot"
    system bin/"fusion-install-addin", "--destination", destination
    assert_path_exists destination/"CadBot.py"
    assert_path_exists destination/"cli/fusion_cli.py"
    assert_path_exists destination/"bridge/dispatch.html"
    %w[chat.py palette agent runtime_config.json].each do |legacy|
      refute_path_exists destination/legacy
    end
    token = destination/".bridge_token"
    assert_operator token.read.strip.length, :>=, 32
    assert_equal 0600, token.stat.mode & 0777
    python = Formula["python@3.14"].opt_bin/"python3.14"
    assert_match "--distance-mm", shell_output("#{python} -S #{destination}/cli/fusion_cli.py design sketches offset --help")
    original_token = token.read
    system bin/"fusion-install-addin", "--destination", destination
    assert_equal original_token, token.read
    assert_equal 1, testpath.glob("CadBot.backup.*").length
  end
end
