# Written by tools/formula.sh in the DDBD repository for each release; change that script, not this file.
class Ddbd < Formula
  desc "Lightweight schemaless record database server"
  homepage "https://ddbd.skapi.com"
  version "0.3.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.0/ddbd-0.3.0-macos-aarch64.tar.gz"
      sha256 "b44bf2da624e11f0e17f0bc85feda13b15a02b6168cf864ed353be09d876308a"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.0/ddbd-0.3.0-macos-x86_64.tar.gz"
      sha256 "7ba338f9853fb0161010986c84c4dc40e979a43a85fc190dba1c8d0510b86906"
    end
  end

  on_linux do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.0/ddbd-0.3.0-linux-aarch64.tar.gz"
      sha256 "560979dc26b27d0999afa3e52af9d6c0a0e736977816039f066f157338ae59ad"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.0/ddbd-0.3.0-linux-x86_64.tar.gz"
      sha256 "51737fa27bb8f658df6fd984d377b876b9aed3198c9ba04bc840b0a6aed31fde"
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
