# Written by tools/formula.sh in the DDBD repository for each release; change that script, not this file.
class Ddbd < Formula
  desc "Lightweight schemaless record database server"
  homepage "https://ddbd.skapi.com"
  version "0.2.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.2.0/ddbd-0.2.0-macos-aarch64.tar.gz"
      sha256 "aa84549bdf861d2dce25429815f4ff010a836c431d106245e088d33f87b7d33c"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.2.0/ddbd-0.2.0-macos-x86_64.tar.gz"
      sha256 "118103c8f614fa4a3a9d705a527a87f4e0003ede11dc62eecfabc5d380f36645"
    end
  end

  on_linux do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.2.0/ddbd-0.2.0-linux-aarch64.tar.gz"
      sha256 "486ca722fcc803ea885339c793ea73c12c65251ab3ae5c037e317dc91bac1995"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.2.0/ddbd-0.2.0-linux-x86_64.tar.gz"
      sha256 "e530a28cbeba56ad554ff0fe66b3389c3a5c9220cd3d396771f85eb059bb70b0"
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
