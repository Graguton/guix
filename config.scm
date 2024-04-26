(use-modules
  (gnu)
  (nongnu packages linux)
  (nongnu system linux-initrd))

(use-service-modules cups desktop networking ssh xorg)

(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "America/New_York")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "ethan-pc")

  ;; User accounts configuration ('root' is implicit).
  (users (cons* (user-account
                  (name "ethan")
                  (comment "Ethan")
                  (group "users")
                  (home-directory "/home/ethan")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; System-wide installed packages. Users can also install packages
  ;; under their own account using 'guix search KEYWORD' and 'guix install PACKAGE'.
  (packages (append (list (specification->package "hyprland") (specification->package "greetd") (specification->package "wlgreet"))
                    %base-packages))

  ;; System services configuration.
  (services
   (append
    (list
     (service greetd-service-type
              (greetd-configuration
               (terminals
                (list
                 (greetd-terminal-configuration
                  (terminal-vt "1")
                  (terminal-switch #t)
                  (default-session-command
                   (greetd-wlgreet-session
                    (wlgreet wlgreet)
                    (command (file-append hyprland "/bin/hyprland"))
                    (command-args '("--config" "/etc/hypr/hyprland.conf"))
                    (output-mode "all")
                    (scale 1)
                    (background '(0 0 0 0.9))
                    (headline '(1 1 1 1))
                    (prompt '(1 1 1 1))
                    (prompt-error '(1 1 1 1))
                    (border '(1 1 1 1))
                    (extra-env '(("XDG_SESSION_TYPE" . "wayland") ("XDG_SEAT" . "seat0") ("XDG_VTNR" . "1"))))))))))
     (service network-manager-service-type)
     (service wpa-supplicant-service-type)
     (service ntp-service-type)
     (service cups-service-type))
    %base-services))

  (bootloader (bootloader-configuration
               (bootloader grub-bootloader)
               (targets (list "/dev/sda"))
               (keyboard-layout keyboard-layout)))

  (swap-devices (list (swap-space
                       (target (uuid "c72b5311-7a3a-4873-a73b-cb4cc3cd0b37")))))

  ;; File systems configuration. UUIDs can be obtained by running 'blkid'.
  (file-systems (cons* (file-system
                        (mount-point "/")
                        (device (uuid "1f3cc259-3679-4ac1-871b-d94cc8bc097c"
                                      (type "ext4")))
                        (file-system
                         (mount-point "/home")
                         (device (uuid "4a6451e3-12da-4139-9faa-c78c936c9e58"
                                       (type "ext4"))))
                        %base-file-systems))))
