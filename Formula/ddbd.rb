# Written by tools/formula.sh in the DDBD repository for each release; change that script, not this file.
class Ddbd < Formula
  desc "Lightweight schemaless record database server"
  homepage "https://ddbd.skapi.com"
  version "0.3.3"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.3/ddbd-0.3.3-macos-aarch64.tar.gz"
      sha256 "4b6e0c951673bb0f24ebf048a1575f7e684a3d3d2d54a434f63e22de44376d4d"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.3/ddbd-0.3.3-macos-x86_64.tar.gz"
      sha256 "8b07baca199acc273cde0d16fc91a6bcc545af11d2ed2228e0ee8c9961b9a3f8"
    end
  end

  on_linux do
    on_arm do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.3/ddbd-0.3.3-linux-aarch64.tar.gz"
      sha256 "89b024542b88722bd1b7a7979fb83f697c8064921429ba327f5a10e118086d48"
    end
    on_intel do
      url "https://cdn.broadwayinc.com/get/ddbd/0.3.3/ddbd-0.3.3-linux-x86_64.tar.gz"
      sha256 "e239791c5d182a0d9eeaf98bd3cb50a366a66d52717b22b228f997bed8d85966"
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
