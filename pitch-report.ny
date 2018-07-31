;nyquist plug-in
;type analyze
;name "Pitch Report..."
;version 4
;codetype lisp
;action "Detecting Fundamental Frequency..."
;copyright "by Stephen Bannasch and Steve Daulton (www.easyspacepro.com).\nReleased under GPL v2.\n"

;info "Click the Debug button to view report ..."

;control sample-time "Sample Time" real "0.125 0.5 (s), size for frequency estimation" 0.25 0.125 0.5

;control sample-step-time "Sample Step Time" real "0.0625 0.5 (s), step forward for each calculation" 0.125 0.0625 0.5

;control sample-start-time "Sample Start Time" real "0.0 .0 (s), start processing at this time" 0.25 0.0 0.5

;control sample-stop-time "Sample Stop Time" real "1.0 5.0 (s), stop processing after this time" 3.0 1.0 5.0

;control report-type "Report Type" choice "Full" "Summary" 0

;; Initializations
(setq time 0.0)

(setq sample-length (round (* sample-time *sound-srate*)))
(setq sample-index 0)

(setq f0 nil)       ; initialise detected frequency
(setq confidence 1.0) ; initialise confidence
(setq *float-format* "%1.3f")

(setf sndcopy (snd-copy *track*))

(psetq min-hz 40 max-hz 1000)

;; Set range in steps (MIDI note numbers)
(psetq minstep (hz-to-step min-hz)
       maxstep (hz-to-step max-hz))

;;; format Frequency output
(defun pretty-frequency (val  &optional (show-units t))
  (setq units "Hz")
  (setq *float-format* "%1.2f")
  (if show-units
    (format nil "~a ~a" val units)
    (format nil "~a" val)))

;;; format Confidence output
(defun pretty-confidence (val)
  (setq *float-format* "%1.3f")
  (format nil "~a" val))

;;; format RMS output
(defun pretty-rms (val)
  (setq *float-format* "%1.3f")
  (format nil "~a" val))

;;; format Time output
(defun pretty-time (val)
  (setq *float-format* "%1.3f")
  (format nil "~a" val))

;;; mean of list of numbers
(defun mean (vals)
  (/ (apply #'+ vals)
     (length vals)))

;;; variance of list of numbers
(defun variance (vals)
  (let* ((m (mean vals))
        (ms (mapcar (lambda (item)
          (expt (- item m) 2)) vals)))
    (/ (apply #'+ ms)
     (length ms))))

;;; standard deviation of list of numbers
(defun stdev (vals)
  (sqrt (variance vals)))

;;; Apply YIN to first DUR seconds
(defun getyin (sig dur)
  (let ((srate (min *sound-srate* (* 8 max-hz))))
    (if (< srate *sound-srate*)
        (progn
          (setf sig
            (if (arrayp sig)
                (sum
                  (extract-abs 0 dur (force-srate srate (aref sig 0)))
                  (extract-abs 0 dur (force-srate srate (aref sig 1))))
                (extract-abs 0 dur (force-srate srate sig))))
          (setq srate (snd-srate sig)))
        (setf sig
          (if (arrayp sig)
              (sum
                (extract-abs 0 dur (aref sig 0))
                (extract-abs 0 dur (aref sig 1)))
              (extract-abs 0 dur sig))))
    (let ((stepsize (truncate  (/ (* 4 srate) min-hz))))
      (yin sig minstep maxstep stepsize))))

;;; Find most confident frequency from YIN results
(defun bestguess (yin-out)
  (setq confidence 1.0)
  (do ((step (snd-fetch (aref yin-out 0))(snd-fetch (aref yin-out 0)))
       (conf (snd-fetch (aref yin-out 1))(snd-fetch (aref yin-out 1))))
      ((not step))
    (when (and (= conf conf)  ; protect against nan
               (< conf confidence))
      (setq confidence conf)
      (setq f0 step)))
  f0)

;;; calculate RMS from sound
(defun calc-rms (snd)
  (let* ((rms-snd (rms (snd-copy snd)))
    (len (snd-length rms-snd 100))
    (rms-array (snd-fetch-array rms-snd len len))
    (sum 0))
    (dotimes (i len (/ sum len))
      (setf sum (+ sum (aref rms-array i))))))

(defun print-project-header ()
  (format t "project\t~a~%date\t~a~%time\t~a~%sample-time\t~a~%sample-step-time\t~a~%sample-stop-time\t~a~%tracks\t~a~%~%"
    (get '*project* 'name )
    (get '*system-time* 'ISO-DATE)
    (get '*system-time* 'TIME)
    sample-time
    sample-step-time
    sample-stop-time
    (length (get '*selection* 'tracks ))))

;;; print list of values delimited with tab characters
(defun print-line (l)
  (if l
    (progn
      (if (cdr l)
        (format t "~a\t" (car l))
        (format t "~a~%" (car l)))
      (print-line (cdr l)))))

;;; print list of results line by line
(defun print-results (results)
  (if results
    (progn
      (print-line (car results))
      (print-results (cdr results)))))

;;;
(defun get-column (vars index &optional (column nil) test test2  )
  (if vars
    (progn
      (push (nth index (car vars)) column)
      (get-column (cdr vars) index column))
    (reverse column)))

;;;
(defun get-column (vars index &optional (column nil))
  (if vars
    (progn
      (push (nth index (car vars)) column)
      (get-column (cdr vars) index column))
    (reverse column)))

(defun generate-frequency-table ()
  (let ((track-index (get '*track* 'index))
        (audio-block nil)
        (line nil)
        (results nil))
    (if (= 1 track-index) (print-project-header))
    (do* ((sample-step (round (* *sound-srate* sample-step-time))
            (round (* *sound-srate* (- (+ time sample-step-time) (/ sample-index *sound-srate*)))))
          (ar (snd-fetch-array sndcopy sample-length sample-step)
            (snd-fetch-array sndcopy sample-length sample-step)))
        ((> time sample-stop-time) "Results in debug log")
      (setf audio-block (snd-from-array 0 *sound-srate* ar))

      (setf line (list
        time
        (step-to-hz (bestguess (getyin audio-block sample-time)))
        (- 1 confidence)
        (calc-rms audio-block)))
      ; (print-line line)
      (push line results)

      ; (format t "~a\t~a\t~a\t~a~%"
      ;   (pretty-time time)
      ;   (pretty-frequency (step-to-hz (bestguess (getyin audio-block sample-time))) nil)
      ;   (pretty-confidence (- 1 confidence))
      ;   (pretty-rms (calc-rms audio-block)))
      (setq sample-index (+ sample-index sample-step))
      (setq time (/ sample-index *sound-srate*)))
    (setf results (reverse results))
    (format t "track\t~a~%number\t~a~%average freq\t~a~%variance\t~a~%stdev\t~a~%~a\t~a\t~a\t~a~%"
      (get '*track* 'name )
      track-index
      (mean (get-column results 1))
      (variance (get-column results 1))
      (stdev (get-column results 1))
      "time" "frequency" "confidence" "RMS")
    (print-results results)
    (format t "~%~%~%~%~%~%~%~%~%~%")))

(generate-frequency-table)
