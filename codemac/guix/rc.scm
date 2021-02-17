(define-module (rc)
  #:use-module (guix packages)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages)
  #:use-module (guix utils))

(package
 (name "rc-master")
 (inherit rc)
 (version "ceb59bb2a644f4ebc1645fe15f1063029579fa7c")
 (source (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/rakitzis/rc")
                (commit version)))
          (sha256
           (base32
            "0vj1h4pcg13vxsiydmmk87dr2sra9h4gwx0c4q6fjsiw4in78rrd"))
          (file-name (git-file-name name version)))))

