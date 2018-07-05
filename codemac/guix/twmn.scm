(define-module (twmn)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake))

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
                "1awi71jdv3mhjrmar2d4z1i90kn7apd7aq1w31sh6w4yibz9kiyj"))))
   ;; (native-inputs
   ;;  `(,git ,pkg-config ,boost))
   ;; (inputs
   ;;  `(,qt5-base ,qt5-x11extras ,boost-libs ,libext ,libxkbcommon-x11))
   (build-system cmake-build-system)
   (home-page "https://github.com/sboli/twmn")
   (synopsis "A notification system for tiling window managers")
   (description "A notification system for tiling window managers")
   (license license:lgpl3+)))
