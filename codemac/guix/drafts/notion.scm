(define-module (notion)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu))

(define-public notion
  (package
   (name "notion")
   ;; tag 4.0.2 from github
   (version "96485f000f3dac1e4671706f91306f094f3cc994")
   (source (origin
	    (method git-fetch)
	    (uri (git-reference
		  (url "https://github.com/raboof/notion")
		  (commit version))
		 (file-name (git-file-name name version))
		 (sha256
		  (base32 "00000000000000000000000000000000000000000000")))))
   (build-system gnu-build-system)))

