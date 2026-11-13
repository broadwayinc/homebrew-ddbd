# Written by tools/formula.sh in the DDBD repository for each release; change that script, not this file.
class Ddbd < Formula
  desc "Lightweight schemaless record database server"
  homepage "https://ddbd.skapi.com"
  version "0.3.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.1/ddbd-0.3.1-macos-aarch64.tar.gz"
      sha256 "6ad5b26b5aeb2355c2f8e603d1fa6499732f279761d487ddfffefd7d0a99de47"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.1/ddbd-0.3.1-macos-x86_64.tar.gz"
      sha256 "aadd816def881e2527f00acf0cce38ea21ef97926d2c145a94f93232c242e572"
    end
  end

  on_linux do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.1/ddbd-0.3.1-linux-aarch64.tar.gz"
      sha256 "fd21e7b3c4de3239fb6da70f1aa59ceb77acd1df2e162fe02d3152bbc3ae385e"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.1/ddbd-0.3.1-linux-x86_64.tar.gz"
      sha256 "4145270288440f01c0a6d77bac90914f5eb20634c10fdb453d5375bc80cd821a"
    end
  end

  livecheck do
    url "https://cdn.broadwayinc.com/get/ddbd/latest"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install "ddbd"
    prefix.install "LICENSE", "NOTICE", "THIRD-PARTY-NOTICES"
  end

  # A data folder for `brew services`, made once and kept across upgrades. It listens on this machine
  # only (127.0.0.1:7070, plain HTTP); its settings are in ddbd.toml.
  def post_install
    return if (var/"ddbd/ddbd.toml").exist?

    system bin/"ddbd", "init", "--data", var/"ddbd", "--bind", "127.0.0.1"
  end

  def caveats
    <<~EOS
      A data folder is set up at #{var}/ddbd, listening on 127.0.0.1:7070 (plain HTTP).
      Its settings are in #{var}/ddbd/ddbd.toml.

      Once it runs (brew services start ddbd), add the first user:
        ddbd admin --data #{var}/ddbd user add <name> --level 00
      To have ddbd commands find this folder without --data:
        export DDBD_DATA=#{var}/ddbd
    EOS
  end

  service do
    run [opt_bin/"ddbd", "start", "--data", var/"ddbd"]
    # started again after a crash, but not after `ddbd stop`
    keep_alive crashed: true
    working_dir var/"ddbd"
    log_path var/"log/ddbd.log"
    error_log_path var/"log/ddbd.log"
  end

  test do
    assert_equal "ddbd #{version}", shell_output("#{bin}/ddbd version").strip
    system bin/"ddbd", "init", "--data", testpath/"data", "--bind", "127.0.0.1"
    assert_path_exists testpath/"data/ddbd.toml"
  end
end
