#!/bin/sh
# -*- scheme -*-
exec guile -e "(@@ (codemac cmd gcalsync) main)" -s "$0" "$@"
!#
(define-module (codemac cmd gcalsync)
  #:use-module (gnutls)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 iconv)
  #:use-module (web uri)
  #:use-module (web server)
  #:use-module (web client))

(define *google-oauth2* "https://accounts.google.com/o/oauth2/v2/auth")

;; token response uri

;; read client id
(define *clientid* "471533009918-7413qdk89t5cv5lbpmi5psmmt8fpu4le.apps.googleusercontent.com")
(define *email* "codemac@gmail.com")
(define *generation* 1)


(define (google-oauth2-handler req body)
  (format #t "req~%~a~%" req)
  (format #t "body~%~a~%" body))

;;
;; response_type - code - For installed applications, use a value of
;; code, indicating that the Google OAuth 2.0 endpoint should return
;; an authorization code.
;;
;; client_id - The client ID you obtain from the Developers Console. -
;; Identifies the client that is making the request. The value passed
;; in this parameter must exactly match the value shown in the Google
;; Developers Console.
;;
;; redirect_uri - http://localhost:port, urn:ietf:wg:oauth:2.0:oob, or
;; urn:ietf:wg:oauth:2.0:oob:auto - Determines how the response is
;; sent to your app. For more details, see Choosing a redirect URI.

;; scope - Space-delimited set of scope strings. - Identifies the
;; Google API access that your application is requesting. The values
;; passed in this parameter inform the consent screen that is shown to
;; the user. There may be an inverse relationship between the number
;; of permissions requested and the likelihood of obtaining user
;; consent. For information about available login scopes, see Login
;; scopes. To see the available scopes for all Google APIs, visit the
;; APIs Explorer.

;; state - Any string - Provides any state information that might be
;; useful to your application upon receipt of the response. The Google
;; Authorization Server roundtrips this parameter, so your application
;; receives the same value it sent. Possible uses include redirecting
;; the user to the correct resource in your site, nonces, and
;; cross-site-request-forgery mitigations.

;; login_hint - email address or sub identifier - When your
;; application knows which user it is trying to authenticate, it can
;; provide this parameter as a hint to the Authentication
;; Server. Passing this hint will either pre-fill the email box on the
;; sign-in form or select the proper multi-login session, thereby
;; simplifying the login flow.
;;
;; Handling the response and making a token request
;;
;; The response to the initial authentication request includes an
;; authorization code (code), which your application can exchange for
;; an access token and a refresh token. To make this token request,
;; send an HTTP POST request to the /oauth2/v4/token endpoint, and
;; include the following parameters:
;;
;; Field 		Description
;; code 		The authorization code returned from the initial request.
;; client_id 		The client ID you obtained from the Google Developers Console.
;; client_secret 	The client secret you obtained from the Developers Console (optional
;;			  for clients registered as Android, iOS or Chrome applications).
;; redirect_uri 	The redirect URI you obtained from the Developers Console.
;; grant_type 		As defined in the OAuth 2.0 specification, this field must contain
;; 			  a value of authorization_code.

;;The actual request might look like the following:

;; POST /oauth2/v4/token HTTP/1.1
;; Host: www.googleapis.com
;; Content-Type: application/x-www-form-urlencoded
;; 
;; code=4/v6xr77ewYqhvHSyW6UJ1w7jKwAzu&
;; client_id=8819981768.apps.googleusercontent.com&
;; client_secret=your_client_secret&
;; redirect_uri=https://oauth2-login-demo.appspot.com/code&
;; grant_type=authorization_code
;; 
;; A successful response to this request contains the following fields:
;;
;; Field 		Description
;; access_token 	The token that can be sent to a Google API.
;; refresh_token 	A token that may be used to obtain a new access
;; 			  token, included by default for installed applications.
;; 			  Refresh tokens are valid until the user revokes access.
;; expires_in 		The remaining lifetime of the access token.
;; token_type 		Identifies the type of token returned. Currently, this
;; 			  field always has the value Bearer.
;; 
;; Note: Other fields may be included in the response, and your
;; application should not treat this as an error. The set shown above
;; is the minimum set.
;; 
;; A successful response is returned as a JSON object, similar to the
;; following:
;; 
;; {
;;   "access_token":"1/fFAGRNJru1FTz70BzhT3Zg",
;;   "expires_in":3920,
;;   "token_type":"Bearer",
;;   "refresh_token":"1/xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI"
;; }


;; oauth2 flow:
;; request initial token
;;
(define (main args)
  (system (string-append "firefox \"" *google-oauth2*
  			 "?response_type=code"
  			 "&client_id=" *clientid*
  			 "&redirect_uri=" "http://localhost:8080"
  			 "&scope=https://www.googleapis.com/auth/calendar.readonly"
  			 "&login_hint=" *email*
  			 "\" "))
  
  (run-server google-oauth2-handler 'http '(#:port 8080))
  (receive (response respbody)
      
      (let ((body (string-append "code=" *code*
				 "&client_id=" *clientid*
				 "&client_secret=" *secret*
				 "&grant_type=authorization_code") ))
	(https-post "https://www.googleapis.com/oauth2/v4/token"
		    #:body body
		    #:headers `((content-type . (application/x-www-form-urlencoded))
				(content-length . ,(string-length body)))))
    (format #t "response ~a~%body: ~a~%" response respbody)))
