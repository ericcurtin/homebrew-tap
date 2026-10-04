# GENERATED FILE -- DO NOT EDIT. Rendered from packaging/homebrew/Formula/vmmbox.rb.in
# in github.com/ericcurtin/vmmbox and pushed here by its release workflow.
#
# Installs the prebuilt release binary: building from source would need a Rust
# toolchain on every user's machine for a binary CI has already built and
# tested for these exact platforms.
class Vmmbox < Formula
  desc "Accelerated Linux VMs on QEMU that mirror your user and share your home"
  homepage "https://github.com/ericcurtin/vmmbox"
  license "GPL-2.0-only"

  # The hypervisor front end. vmmbox itself also needs ssh and curl: macOS ships
  # both, and Linux machines have them.
  depends_on "qemu"
  uses_from_macos "curl"

  on_macos do
    on_arm do
      url "https://github.com/ericcurtin/vmmbox/releases/download/v0.1.1/vmmbox-aarch64-apple-darwin"
      sha256 "ff00e3b4288b3cc3c884d5dfe4b19a97ea99f942e2daf135109076e66799627d"
    end
    on_intel do
      url "https://github.com/ericcurtin/vmmbox/releases/download/v0.1.1/vmmbox-x86_64-apple-darwin"
      sha256 "6c68d7412b03486b942c8a2edd1650eb1958d1471e194475c39cbac7bdcedcc6"
    end
  end

  on_linux do
    # Only x86_64 is supported on Linux; this gives other architectures a clear
    # Homebrew error instead of a missing download.
    depends_on arch: :x86_64

    on_intel do
      url "https://github.com/ericcurtin/vmmbox/releases/download/v0.1.1/vmmbox-x86_64-unknown-linux-musl"
      sha256 "b2ba169af1de544cafcecf0ac44353811bc3359070d76c148bf6adefdaf02df5"
    end
  end

  def install
    # The staged file keeps its vmmbox-<triple> asset name.
    bin.install Dir["vmmbox-*"].first => "vmmbox"
  end

  def caveats
    gui = if OS.mac?
      <<~EOS
        GUI apps (vmmbox exec ubuntu google-chrome) open as windows on your desktop
        once a Wayland compositor and waypipe are installed. They come from a
        third-party tap, so Homebrew needs you to ask for them explicitly:

          brew install J-x-Z/tap/cocoa-way J-x-Z/tap/waypipe-darwin
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
      Start a VM and get a shell in it:

        vmmbox start ubuntu
        vmmbox exec ubuntu bash

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
