(mac process (myfn) (w/uniq (fh line) `(w/infile fh "/Users/smorin/test.csv" (whiler line (readline fh) nil (,myfn line)))))
(process [let x (tokens _) (when (is (len x) 2) (prn:car:cdr x))])
(quit)