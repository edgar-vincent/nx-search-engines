;;;; nx-search-engines.lisp

(in-package #:nx-search-engines)

(defmacro define-search-engine (name (&key shortcut fallback-url base-search-url documentation)
                                &body keywords)
  "Defines a new `nyxt:search-engine' called NAME and having FALLBACK-URL.
`nyxt:search-url' of the new engine is built from BASE-SEARCH-URL and KEYWORDS.

BASE-SEARCH-URL is a control string with one placeholder (e.g.,
\"example.com/?q=~a\") each keyword in KEYWORDS is a list of a
form (KEYWORD URI-PARAMETER VALUES), where VALUES is either
- an association list of possible values and their URI representations, or
- a function to process the value provided by the user.

Example:"
  (flet ((supplied-p (symbol)
           (intern (format nil "~s-SUPPLIED-P" symbol)
                   (symbol-package symbol)))
         (make-cond (arg-name values)
           `(cond
              ,@(loop :for value :in values
                      :collect
                      `((equal ,arg-name ,(first value))
                        ,(second value))
                      :into clauses
                      :finally (return (append clauses (list `(t ,arg-name))))))))
    `(defun ,name (&key
                     (fallback-url ,fallback-url)
                     (shortcut ,shortcut)
                     ,@(mapcar #'(lambda (k)
                                   (list (first k)                 ; name
                                         (if (eq (first (third k)) :function)
                                             nil
                                             (first (first (third k)))) ; default value
                                         (supplied-p (first k))))  ; supplied-p
                               keywords))
       ,documentation
       (make-instance
        'nyxt:search-engine
        :shortcut shortcut
        :fallback-url fallback-url
        :search-url (format nil "~a~{~a~}"
                            ,base-search-url
                            (delete
                             nil
                             (list
                              ,@(loop :for (arg-name uri-parameter values)
                                        :in keywords
                                      :collect
                                      `(when ,(supplied-p arg-name)
                                         (format nil "&~a=~a"
                                                 ,uri-parameter
                                                 ,(if (eq (first values) :function)
                                                      `(funcall ,(second values) ,arg-name)
                                                      (make-cond arg-name values))))))))))))

(define-search-engine duckduckgo
    (:shortcut "duckduckgo"
     :fallback-url "https://duckduckgo.com/"
     :base-search-url "https://duckduckgo.com/?q=~a")
  ;;; Theming
  (theme "kae" ((:default  "")
                (:basic    "b")
                (:contrast "c")
                (:dark     "d")
                (:gray     "g")
                (:terminal "t")))
  ;;; Privacy
  (get-requests "kg" ((t "")
                      (nil "p"))) ;; Use POST requests.
  (video-playback "k5" ((:prompt-me "")
                        (:always-ddg "1")
                        (:always-third-party "2")))
  ;; See https://help.duckduckgo.com/results/rduckduckgocom/
  (redirect "kd" ((t "")
                  (nil "-1")))
  ;;; General
  ;; abbr. means the abbreviation I came up with based on what DDG
  ;; provides. It's mostly just removing the -en suffix from the
  ;; region name, like :india-en -> :india
  (region "kl" ((:all "")
                (:argentina   "ar-es")
                (:australia   "au-en")
                (:austria     "at-de")
                (:belgium-fr  "be-fr")
                (:belgium-nl  "be-nl")
                (:brazil      "br-pt")
                (:bulgaria    "bg-bg")
                (:canada-en   "ca-en")
                (:canada-fr   "ca-fr")
                (:catalonia   "ct-ca")
                (:chile       "cl-es")
                (:china       "cn-zh")
                (:colombia    "co-es")
                (:croatia     "hr-hr")
                (:czech-republic "cz-cs")
                (:denmark     "dk-da")
                (:estonia     "ee-et")
                (:finland     "fi-fi")
                (:france      "fr-fr")
                (:germany     "de-de")
                (:greece      "gr-el")
                (:hong-kong   "hk-tzh")
                (:hungary     "hu-hu")
                (:india-en    "in-en")
                (:india       "in-en")   ; abbr.
                (:indonesia-en "id-en")
                (:indonesia   "id-en")   ; abbr.
                (:ireland     "ie-en")
                (:israel-en   "il-en")
                (:israel      "il-en")   ; abbr.
                (:italy       "it-it")
                (:japan       "jp-jp")
                (:korea       "kr-kr")
                (:latvia      "lv-lv")
                (:lithuania   "lt-lt")
                (:malaysia-en "my-en")
                (:malaysia    "my-en")   ; abbr.
                (:mexico      "mx-es")
                (:netherlands "nl-nl")
                (:new-zealand "nz-en")
                (:norway      "no-no")
                (:pakistan-en "pk-en")
                (:peru        "pe-es")
                (:philippines-en "ph-en")
                (:philippines "ph-en")   ; abbr.
                (:poland      "pl-pl")
                (:portugal    "pt-pt")
                (:romania     "ro-ro")
                (:russia      "ru-ru")
                (:russian-federation "ru-ru") ; abbr.
                (:saudi-arabia "xa-ar")
                (:singapore   "sg-en")
                (:slovakia    "sk-sk")
                (:slovenia    "sl-sl")
                (:south-africa "za-en")
                (:spain-ca    "es-ca")
                (:spain-es    "es-es")
                (:spain       "es-es")   ; abbr.
                (:sweden      "se-sv")
                (:switzerland-de "ch-de")
                (:switzerland-fr "ch-fr")
                (:taiwan "tw-tzh")
                (:thailand-en "th-en")
                (:thailand    "th-en")   ; abbr.
                (:turkey      "tr-tr")
                (:us-english  "us-en")
                (:us-en       "us-en")   ; abbr.
                (:us          "us-en")   ; abbr.
                (:us-spanish  "us-es")
                (:us-es       "us-es")   ; abbr.
                (:ukraine     "ua-uk")
                (:united-kingdom "uk-en")
                (:uk "uk-en")            ; abbr.
                (:vietnam-en  "vn-en")
                (:vietnam     "vn-en"))) ; abbr.
  ;; TODO: Write it.
  (language "kad" ((:default "")))
  (safe-search "kp" ((:moderate "")
                     (:strict   "1")
                     (:off      "-2")))
  (instant-answers "kz" ((t "")
                         (nil "-1")))
  (infinite-scroll-for-media "kav" ((t "")
                                    (nil "-1")))
  (infinite-scroll "kav" ((nil "")
                          (t "1")))
  (autocomplete-suggestions ((t "")
                             (nil "-1")))
  (open-in-new-tab "kn" ((nil "")
                         (t   "1")))
  (advertisements "k1"  ((t "")
                         (nil "-1")))
  (keyboard-shortcuts "kk" ((t "")
                            (nil "-1")))
  (units-of-measure "kaj" ((:no-preference "")
                           (:metric "m")
                           (:us-based "u")))
  (map-rendering "kay" ((:not-set "")
                        (:best-available "b")
                        (:image-tiles "i")))
  (page-break-numbers "kv" ((:on "")
                            (:off "-1")
                            (:lines "l")))
  (install-duckduckgo "kak" ((t "")
                             (nil "-1")))
  (install-reminders "kax" ((t "")
                            (nil "-1")))
  (privacy-newsletter "kaq" ((t "")
                             (nil "-1")))
  (newsletter-reminders "kap" ((t "")
                               (nil "-1")))
  (homepage-privacy-tips "kao" ((t "")
                                (nil "-1")))
  (help-improve-duckduckgo "kau" ((t "")
                                  (nil "-1")))
  ;;; Appearance
  (font "kt" (("Proxima Nova" "")
              (:proxima-nova  "")
              ("Arial" "a")
              (:arial "a")
              ("Century Gothic" "c")
              (:century-gothic "c")
              ("Georgia" "g")
              (:georgia "g")
              ("Helvetica" "h")
              (:helvetica "h")
              ("Helvetica Neue" "u")
              (:helvetica-neue "u")
              ("Sans Serif" "n")
              (:sans-serif "n")
              ("Segoe UI" "e")
              (:segoe-ui "e")
              ("Serif" "s")
              (:serif "s")
              ("Times" "t")
              (:times "t")
              ("Tahoma" "o")
              (:tahoma "o")
              ("Trebuchet MS" "b")
              (:trebuchet-ms "b")
              ("Verdana" "v")
              (:verdana "v")))
  (font-size "ks" ((:large "")
                   (:small "s")
                   (:medium "m")
                   (:larger "l")
                   (:largest "t")))
  (page-width "kw" ((:normal "")
                    (:wide "w")
                    (:super-wide "s")))
  (center-alignment "km" ((nil "")
                          (t "m")))
  (background-color "k7" ((:default "ffffff")))
  (header-behavior "ko" ((:on-dynamic "")
                         (:on-fixed "1")
                         (:off "-1")
                         (:on-scrolling "s")))
  (header-color "kj" ((:default "ffffff")))
  (result-title-font "ka" (("Proxima Nova" "")
                           (:proxima-nova  "")
                           ("Arial" "a")
                           (:arial "a")
                           ("Century Gothic" "c")
                           (:century-gothic "c")
                           ("Georgia" "g")
                           (:georgia "g")
                           ("Helvetica" "h")
                           (:helvetica "h")
                           ("Helvetica Neue" "u")
                           (:helvetica-neue "u")
                           ("Sans Serif" "n")
                           (:sans-serif "n")
                           ("Segoe UI" "e")
                           (:segoe-ui "e")
                           ("Serif" "s")
                           (:serif "s")
                           ("Times" "t")
                           (:times "t")
                           ("Tahoma" "o")
                           (:tahoma "o")
                           ("Trebuchet MS" "b")
                           (:trebuchet-ms "b")
                           ("Verdana" "v")
                           (:verdana "v")))
  (result-title-color "k9" ((:default "084999")))
  (result-visited-title-color "kaa" ((:default "6c00a2")))
  (result-title-underline "ku" ((nil "")
                                (t "1")))
  (result-description-color "k8" ((:default "494949")))
  (result-url-color "kx" ((:default "3f6e35")))
  (result-module-color "k21" ((:default "ffffff")))
  (result-full-urls "kaf" ((t "")
                           (nil "-1")))
  (result-urls-above-snippet "kaf" ((t "")
                                    (nil "-1")))
  (result-visible-checkmark "k18" ((nil "")
                                   (t "1")))
  (site-icons "kf" ((t "")
                    (nil "-1"))))

(define-search-engine google
    (:shortcut "google"
     :fallback-url "google.com"
     :base-search-url "google.com/search?q=~a"
     :documentation "")
  (safe-search "safe" ((t   "strict")
                       (nil "images")))
  (object "tbm" ((:all      "")
                 (:image    "isch")
                 (:video    "vid")
                 (:news     "nws")
                 (:shopping "shop")
                 (:books    "bks")
                 (:finance  "fin"))))

(define-search-engine wordnet (:shortcut "wordnet"
                               :fallback-url "http://wordnetweb.princeton.edu/perl/webwn"
                               :base-search-url "http://wordnetweb.princeton.edu/perl/webwn?s=~a"
                               :documentation "`nyxt:search-engine' for WordNet.

To use it, disable force-https-mode for wordnetweb.princeton.edu or
add auto-mode rule that will manage that for you!

Arguments mean:
SHORTCUT -- the shortcut you need to input to use this search engine. Set to \"wordnet\" by default.
SHOW-EXAMPLES -- Show example sentences. T by default.
SHOW-GLOSSES -- Show definitions. T by default.
SHOW-WORD-FREQUENCIES -- Show word frequency counts. NIL by default.
SHOW-DB-LOCATIONS -- Show WordNet database locations for this word. NIL by default.
SHOW-LEXICAL-FILE-INFO -- Show lexical file word belongs to. NIL by default.
SHOW-LEXICAL-FILE-NUMBERS -- Show number of the word in the lexical file. NIL by default.
SHOW-SENSE-KEYS -- Show symbols for senses of the word. NIL by default.
SHOW-SENSE-NUMBERS -- Show sense numbers. NIL by default.

A sensible non-default example:
\(wordnet :shortcut \"wn\"
         :show-word-frequencies t
         :show-sense-numbers t
         :show-examples nil)

This search engine, invokable with \"wn\", will show:
- NO example sentences,
- glosses,
- frequency counts,
- sense-numbers.")
  (show-examples             "o0" ((t "1")  (nil "")))
  (show-glosses              "o1" ((t "1")  (nil "")))
  (show-word-frequencies     "o2" ((nil "") (t "1")))
  (show-db-locations         "o3" ((nil "") (t "1")))
  (show-lexical-file-info    "o4" ((nil "") (t "1")))
  (show-lexical-file-numbers "o5" ((nil "") (t "1")))
  (show-sense-keys           "o6" ((nil "") (t "1")))
  (show-sense-numbers        "o7" ((nil "") (t "1"))))
