(define-module (mbsync-oauth)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cyrus-sasl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu))

;; provides=('notification-daemon')
;; depends=('qt5-base' 'qt5-x11extras' 'boost-libs>=1.46' 'libxext' 'libxkbcommon-x11')
;; makedepends=('git' 'pkg-config' 'boost>=1.46')

(define-public sasl-oauth2
  (package
   (name "sasl-oauth2")
   (version "c1d7cd0719c233c89307b7406f92a01602a85993")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/robn/sasl2-oauth")
                  (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
		"03xz40qjsznwb2z83ngm27yrvpg26z4jdzzafgclaqv1q9w0nkzd"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases (modify-phases %standard-phases
                 (add-after
                   'unpack 'autoconf
                   (lambda _
		     (invoke "autoreconf" "-vfi")
		     (substitute* "plugin_common.c"
				  (("#include <sasl/sasl.h>\n")
				   "#include <stddef.h>\n#include <sasl/sasl.h>\n")))))))
   (native-inputs
    `(("autoconf" ,autoconf)
      ("automake" ,automake)
      ("cyrus-sasl" ,cyrus-sasl)
      ("glibc" ,glibc)
      ("libtool" ,libtool)))
   (home-page "https://github.com/robn/sasl2-oauth")
   (synopsis "A sasl oauth2 plugin for libsasl")
   (description "A sasl oauth2 plugin for libsasl")
   (license license:isc)))

;(define-public cyrus-sasl-oauth2
;  (package (inherit cyrus-sasl)
;	   (name "cyrus-sasl-oauth2")
;	   (synopsis "cyrus-sasl with oauth2")
;	   (propagated-inputs
;	    `(("sasl-oauth2" ,sasl-oauth)))
;	   (inputs
;	    `(("gdbm" ,gdbm)
;	      ("mit-krb5" ,mit-krb5)
;	      ("sasl-oauth2" ,sasl-oauth)
;	      ("openssl" ,openssl)))))

; (define-public isync-oauth2
;   (package (inherit isync)
; 	   (name "isync-oauth2")
; 	   (synopsis "A sasl xoauth2 enabled mbsync")
; 	   (inputs
; 	    `(("bdb" ,bdb)
; 	      ("cyrus-sasl-oauth2" ,cyrus-sasl-oauth2)
; 	      ("openssl" ,openssl)
; 	      ("zlib" ,zlib)
; 	      ("sasl-oauth2" ,sasl-oauth2)))))
