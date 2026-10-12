# GENERATED FILE -- DO NOT EDIT. Rendered from packaging/homebrew/Formula/vmmbox.rb.in
# in github.com/ericcurtin/vmmbox and pushed here by its release workflow.
#
# Installs the prebuilt release binary: building from source would need a Rust
# toolchain on every user's machine for a binary CI has already built and
# tested for these exact platforms.
class Vmmbox < Formula
  desc "Accelerated Linux VMs on QEMU that mirror your user and share your home"
  homepage "https://github.com/ericcurtin/vmmbox"
  license "Apache-2.0"

  # vmmbox needs ssh and curl: macOS ships both, and Linux machines have them.
  # On macOS it needs nothing else from Homebrew: it downloads its own QEMU,
  # built with the virtio-fs support Homebrew's lacks, the first time it is used
  # (`vmmbox setup` does it sooner). A formula cannot do that itself: Homebrew's
  # sandbox does not let post_install write to the user's home.
  uses_from_macos "curl"

  on_macos do
    # Only Apple silicon is supported on macOS; this gives Intel Macs a clear
    # Homebrew error instead of a missing download.
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/ericcurtin/vmmbox/releases/download/v0.1.39/vmmbox-aarch64-apple-darwin"
      sha256 "f9469c71f3c7f14fc325cef263530ac5d0467a8cfeba2332fe4feb9009d265e8"
    end
  end

  on_linux do
    # On Linux QEMU and the virtio-fs server come from Homebrew or the system.
    depends_on "qemu"
    depends_on "virtiofsd"

    # Homebrew on Linux runs on x86_64 and arm64 only, and both have a build.
    on_intel do
      url "https://github.com/ericcurtin/vmmbox/releases/download/v0.1.39/vmmbox-x86_64-unknown-linux-musl"
      sha256 "1c08d8081f760ed6c3103477328fb3a21e56b57a50516fa86c5ba855143874cd"
    end
    on_arm do
      url "https://github.com/ericcurtin/vmmbox/releases/download/v0.1.39/vmmbox-aarch64-unknown-linux-musl"
      sha256 "bb9c670eebf59a57cbd3c9819d942958c6eee637066fba14a919bb0e4338a7bb"
    end
  end

  def install
    # The staged file keeps its vmmbox-<triple> asset name.
    bin.install Dir["vmmbox-*"].first => "vmmbox"
  end

  def caveats
    gui = if OS.mac?
      <<~EOS
        GUI apps (vmmbox run ubuntu google-chrome) open as windows on your desktop
        once a Wayland compositor and waypipe are installed. They come from a
        third-party tap, so Homebrew needs you to ask for them explicitly:

          brew install J-x-Z/tap/cocoa-way J-x-Z/tap/waypipe-darwin

        The first time you start a VM, vmmbox downloads its own QEMU (about 11 MB)
        into ~/.local/share/vmmbox; `vmmbox setup` does that now.
      EOS
    else
      <<~EOS
        Virtual machines use KVM; your user must be able to open /dev/kvm:

          sudo usermod -aG kvm $USER   # then log in again

        GUI apps additionally need waypipe (install your distribution's package)
        and a running Wayland session.
      EOS
    end
    <<~EOS
      Get a shell in a VM (it is pulled, created and started if need be):

        vmmbox run ubuntu bash

      #{gui}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vmmbox --version")

    # An empty store exercises argument handling and the data directory without
    # needing a hypervisor.
    ENV["VMMBOX_HOME"] = testpath/"vmmbox"
    assert_match "No images", shell_output("#{bin}/vmmbox images")
    assert_match "No VMs", shell_output("#{bin}/vmmbox ps")
  end
end
