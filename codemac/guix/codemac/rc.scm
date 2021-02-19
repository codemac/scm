(define-module (codemac rc)
  #:use-module (gnu packages)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages bison)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix utils))

(define-public rc-byron
 (package (inherit rc)
 (name "rc-byron")
 (version "ceb59bb2a644f4ebc1645fe15f1063029579fa7c")
 (source (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/rakitzis/rc")
                (commit version)))
          (sha256
           (base32
            "1q0c6dq5f8aapcq0gg5vf9fs1ibcjij433vvyrjg0lx6icbz75sp"))
          (file-name (git-file-name name version))))
  (native-inputs
    `(("bison" ,bison)
      ,@(package-native-inputs rc)))))

