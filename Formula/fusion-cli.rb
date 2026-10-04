class FusionCli < Formula
  include Language::Python::Virtualenv

  desc "Typed CAD commands and optional AI chat for Autodesk Fusion"
  homepage "https://deandiasti.github.io/fusion-cli/"
  url "https://github.com/DeanDiasti/fusion-cli/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "6e63ad27b1a1151128da6aafa07282d0808d91692db79e854b20a45cfcbaa8fa"
  license "GPL-3.0-only"

  depends_on :macos
  depends_on "python@3.14"

  # This community tap intentionally uses checksummed upstream wheels.
  # Autodesk Fusion is installed separately; this is not a core formula.
  resource "annotated-types" do
    url "https://files.pythonhosted.org/packages/99/91/8acff4f5e50511b911bbccb72b8628a49c68ce14148cd9f6431094859a90/annotated_types-0.8.0-py3-none-any.whl", using: :nounzip
    sha256 "f072f4d804ea359e4eaf198b1af7a8b0943881a87f31bb764f8bf219bb9419e0"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/49/d3/b8441a820a491ddfc024b0b0cf0393375b75ea13866d9c66727e54c2fc80/typing_extensions-4.16.0-py3-none-any.whl", using: :nounzip
    sha256 "481caa481374e813c1b176ada14e97f1f67a4539ce9cfeb3f350d78d6370c2e8"
  end

  resource "typing-inspection" do
    url "https://files.pythonhosted.org/packages/67/81/4add07e5172b7ac40d8ed5ff580409a7801a4fe26d529bdd915401dabfbe/typing_inspection-0.4.4-py3-none-any.whl", using: :nounzip
    sha256 "65b8397ba37ccbce054456aaccddfc91e6e3083c92824df348d96ca832f3f147"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl", using: :nounzip
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  on_arm do
    resource "pydantic-core" do
      url "https://files.pythonhosted.org/packages/ae/d5/d8a4eb6d6c7f66b91dd37c576d76e9e60fba900caf5372c17bcf949febc2/pydantic_core-2.46.5-cp314-cp314-macosx_11_0_arm64.whl", using: :nounzip
      sha256 "1a353f84de772f423b5ffb11d7ae352fbbef0f446f3c0b0af0f8236d7233606e"
    end
  end

  on_intel do
    resource "pydantic-core" do
      url "https://files.pythonhosted.org/packages/8e/8a/14596f2a8367da50cf7cbac48169ee5d9c8e11d486a3b527082384630c72/pydantic_core-2.46.5-cp314-cp314-macosx_10_12_x86_64.whl", using: :nounzip
      sha256 "c1c43ad4339643d70ebb8124e1305a7dab423001eff58bb41a0f731adbc98355"
    end
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/eb/47/c95ffc2009878c7aac0c5e08528022dcb885933252a88b5f170058014464/pydantic-2.13.5-py3-none-any.whl", using: :nounzip
    sha256 "346a034f080da3755d8e9cb5e00e8b07de1d39e4f6e2c87d8ab7cafa0b269a73"
  end

  on_arm do
    resource "openai-codex-cli-bin" do
      url "https://files.pythonhosted.org/packages/96/56/ee6e0ae89813d68ca12c19ab4cb4ddce30281b6d3f4dc46370f03b493f58/openai_codex_cli_bin-0.154.0-py3-none-macosx_11_0_arm64.whl", using: :nounzip
      sha256 "4f32974a4379e58f5d2677c4d5097aeaeef7e249c04ca8d66b569503999ba53b"
    end
  end

  on_intel do
    resource "openai-codex-cli-bin" do
      url "https://files.pythonhosted.org/packages/d9/c5/4bd3ca28d82d54a5aae89d7106a81062f66bc113e24aa684a03855603586/openai_codex_cli_bin-0.154.0-py3-none-macosx_10_9_x86_64.whl", using: :nounzip
      sha256 "ce74d702b77f0e18df24cc47f5f5c14d88ce84a5df59ea07c0169bc92d0a98e2"
    end
  end

  resource "openai-codex" do
    url "https://files.pythonhosted.org/packages/a4/66/bdadb71a855aebc965f21b721239cf4a265aa7c78cfcd0ab87ae4a44b68e/openai_codex-0.154.0-py3-none-any.whl", using: :nounzip
    sha256 "b5f354e1280621d0f5e28313ecf6974d2a98bcf0b088dbe791dc6df5044d2214"
  end

  def install
    libexec.install "agent", "fusion_addin", "scripts", "requirements.txt"
    venv = virtualenv_create(libexec/".venv", "python3.14", system_site_packages: false)
    resources.each do |package|
      package.stage do
        system "python3.14", "-m", "pip", "--python=#{venv.root}/bin/python", "install",
               "--no-index", "--no-deps", "--disable-pip-version-check", package.downloader.basename
      end
    end
    system venv.root/"bin/python", "-c", "import openai_codex"
    (bin/"fusion").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/.venv/bin/python" "#{opt_libexec}/agent/fusion_cli.py" "$@"
    SH
    (bin/"fusion-install-addin").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/.venv/bin/python" "#{opt_libexec}/scripts/install_addin.py" "$@"
    SH
  end

  def caveats
    <<~EOS
      Autodesk Fusion must be installed separately.
      Save work, stop CadBot, then run:
        fusion-install-addin
      Restart Fusion and run CadBot from Scripts and Add-Ins.
      Repeat fusion-install-addin after every brew upgrade, before brew cleanup.
      Optional AI chat requires Codex sign-in. Offline help does not.
      Uninstalling this formula does not remove the separately installed add-in or history.
    EOS
  end

  test do
    require "json"
    assert_match "fusion design inspect", shell_output("#{bin}/fusion help")
    assert_match "--distance-mm", shell_output("#{bin}/fusion design sketches offset --help")
    version_info = JSON.parse(shell_output("#{bin}/fusion --version"))
    assert_equal 3, version_info.fetch("protocol")
    assert_match(/\A[0-9a-f]{16}\z/, version_info.fetch("build"))
    destination = testpath/"CadBot"
    system bin/"fusion-install-addin", "--destination", destination
    assert_path_exists destination/"CadBot.py"
    token = destination/".bridge_token"
    assert_operator token.read.strip.length, :>=, 32
    assert_equal 0600, token.stat.mode & 0777
    runtime = JSON.parse((destination/"runtime_config.json").read)
    system runtime.fetch("python"), "-c", "import openai_codex"
    assert_match "--distance-mm", shell_output("#{runtime.fetch('python')} #{destination}/agent/fusion_cli.py design sketches offset --help")
    original_token = token.read
    system bin/"fusion-install-addin", "--destination", destination
    assert_equal original_token, token.read
    assert_equal 1, testpath.glob("CadBot.backup.*").length
  end
end
