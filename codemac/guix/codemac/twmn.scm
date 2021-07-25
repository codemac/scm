(define-module (codemac twmn)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu))

;;
;; pkgdesc="A notification system for tiling window managers"
;; arch=('any')
;; url="https://github.com/sboli/twmn"
;; license=('LGPL3')
;; provides=('notification-daemon')
;; depends=('qt5-base' 'qt5-x11extras' 'boost-libs>=1.46' 'libxext' 'libxkbcommon-x11')
;; makedepends=('git' 'pkg-config' 'boost>=1.46')
;; conflicts=('twmn')
;; source=("${_name}::git+https://github.com/sboli/${_name}.git")
;; sha256sums=('SKIP')

(define-public twmn
  (package
   (name "twmn")
   (version "5b92ac5d8c805a536211cb8dcee987247c0e6707")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/sboli/twmn.git")
                  (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
		"0nhd7apm7j9gv2bic289hami30ghvlayqa1dx8l8f8k5dr9vjanx"))))
   (native-inputs
    `(("git" ,git)
      ("pkg-config" ,pkg-config)
      ("qtbase" ,qtbase)
      ("qtx11extras" ,qtx11extras)
      ("boost" ,boost)))
   (inputs
    `(("libxext" ,libxext)
      ("libxkbcommon" ,libxkbcommon)))
   (build-system gnu-build-system)
   (arguments
    `(#:phases
      (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (invoke "qmake")))))))
   (home-page "https://github.com/sboli/twmn")
   (synopsis "A notification system for tiling window managers")
   (description "A notification system for tiling window managers")
   (license license:lgpl3+)))
