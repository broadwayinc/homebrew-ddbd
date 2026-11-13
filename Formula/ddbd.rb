# Written by tools/formula.sh in the DDBD repository for each release; change that script, not this file.
class Ddbd < Formula
  desc "Lightweight schemaless record database server"
  homepage "https://ddbd.skapi.com"
  version "0.3.2"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.2/ddbd-0.3.2-macos-aarch64.tar.gz"
      sha256 "9735ea912989d5c4a60b4e5d74f4d14c441c56dcc726a2f2d3dafeb717d6cf40"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.2/ddbd-0.3.2-macos-x86_64.tar.gz"
      sha256 "0b0e4475c27debe8c8f0b967a1c751547d5ce78b6caa3038e2b6ad00bd76528c"
    end
  end

  on_linux do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.2/ddbd-0.3.2-linux-aarch64.tar.gz"
      sha256 "78d4cb21ef756af8c475ede699672f3f2ec48a0f5c7a7658941102a1141e4921"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.2/ddbd-0.3.2-linux-x86_64.tar.gz"
      sha256 "0e237a178753e1c227da6c2b232469e5832451adf0fe1f8e5b879f8b858b635b"
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
