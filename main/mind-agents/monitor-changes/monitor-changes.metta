!(bind! rand (py-atom numpy.random.rand))
!(bind! &newSpace (new-space))
!(bind! &sngSpace (new-space))
(tv_delta 0.1)
;A function that takes the latestTime and a list of times
;and finds the appropriate position to set previous time pointer.
;
;returns: a tuple of previous time and latest time.
(: setPreviousTime (-> Number Expression Expression))
(= (setPreviousTime $latestTime $times)
   (let* 
     (
      ($min-change (match &self (tv_delta $val) $val))
      ($random-num (rand))
      ($interval (+ 5 (* 5 $random-num)))
      ($prevTime (setPreviousTime' (sort' $times rvrs) $latestTime $interval)) ;rvrs signals the function to sort the list in reverse order.
      )
     ($prevTime $latestTime)
     )
   )


(= (setPreviousTime' $times $latest $interval)
   (if (== $times ())
     (default-value)
     (let*
       (
        (($previous $tail) (decons-atom $times)) 
        ;(() (println! ($previous $latest $interval)))
        )
       (if (>= (- $latest $previous) $interval)
         $previous
         (setPreviousTime' $tail $latest $interval)
         )
      )
     )
   )

;a function that removes previous changes with tv and with args from 
;a provided space
(: removePrevChanges (-> Grounded Symbol (->)))
(= (removePrevChanges $space $type)
   (let* (
          ($pred-change-with-tv (Predicate change-with-tv))
          ($pred-change-with-arg (Predicate change-with-arg))
          ($pred-has-dramatic-changes (Predicate has-dramatic-change))
          ($preds (collapse 
                    (let $x 
                      (superpose ($pred-change-with-tv $pred-change-with-arg $pred-has-dramatic-changes))
                      (addPredicate $x $space)
                    )
                  )
                )
          ($old-changes-with-tv (get-incoming $pred-change-with-tv $space $type))
          ($old-changes-with-arg (get-incoming $pred-change-with-arg $space $type))
          ;(() (println! ($old-changes-with-tv $old-changes-with-arg)))
          ($_ (removePrevChanges' $space $old-changes-with-tv))
          ($_ (removePrevChanges' $space $old-changes-with-arg))
          ($_ (update-drmtc-chng-tv $pred-has-dramatic-changes $space (STV 0.0 0.0)))
        )
     ()
    )
   )


(: removePrevChanges' (-> Grounded Symbol (->)))
(= (removePrevChanges' $space $atoms)
   (if (== $atoms ())
     ()
     (let* (
            (($h $t) (decons-atom $atoms))
            ($list-link (out $h ))
            ;(() (println! (remove' $list-link $h)))
            )
        (if (== $h ())
          ()
          (let $_ (let () (remove-atom $space $h) (remove-atom $space (car-atom $list-link))) 
            (removePrevChanges' $space $t)
            )
          )
       )
     )
   )

(= (addPredicate $pred $space)
   (if (== (collapse (match $space $pred $pred)) ())
     (let $_ (add-atom $space $pred) $pred)
     (empty)
     )
   )

(= (update-drmtc-chng-tv $pred $space $ntv)
   (let $r (collapse (match $space ($pred $old-tv) $old-tv)) 
     (if (== $r ())
          (let $_ (add-atom $space ($pred $ntv)) ())
          (let $tv (car-atom $r) (update-atom $space ($pred $tv) ($pred $ntv)))
      )
     )
   )

;a generic sorting algorithm that is able to sort atoms in either increasing and decreasing order.
;pass rvrs to sort in decreasing or () for increasing order
(= (m () $right $cmp) $right)
(= (m $left () $cmp) $left)

(= (m $left $right $cmp)
     (let* (
            (($lh $lt) (decons-atom $left))
            (($rh $rt) (decons-atom $right))
            ($res1 (m $lt $right $cmp))
            ($res2 (m $left $rt $cmp))
            )
       (if ($cmp $lh $rh)
         (cons-atom $lh $res1)
         (cons-atom $rh $res2)
         )
       )
     )

(= (sort' $list $key)
   (if (<= (len $list) 1)
       $list
       (let* (
               ($mid (floor-math (/ (len $list) 2)))
               (($left $right) (splitAt $mid $list))
               ($cmp (if (== rvrs $key) > <=))
             )
             (m (sort' $left $key) (sort' $right $key) $cmp)
       )
   )
)


; Record the changes in the atomspace

(= (record-changes-tv $space $changes-tv)
  (if (== $changes-tv ())()
    (let* 
      (
        (($head $tail) (decons-atom $changes-tv))
        ($_ (add-atom $space (LIST_LINK $head)))
        ($_ (add-atom $space (ReferenceLink ((Predicate change-with-tv) (LIST_LINK $head)))))
      )
        (record-changes-tv $space $tail)
    )
  )
)

(=(record-changes-arg $space $changes-arg)
  (if (== () $changes-arg)()
    (let $_ (add-atom $space (LIST_LINK $changes-arg))
      (add-atom $space (ReferenceLink ((Predicate change-with-arg) (LIST_LINK $changes-arg))))
    )
  )
)



(: compareChanges (-> hyperon::space::DynSpace hyperon::space::DynSpace Expression))
(= (compareChanges $space1 $space2)
    (let* (
        ($space_val_1 (collapse (get-atoms $space1)))

        ($space_val_2 (collapse (get-atoms $space2)))
        ($net (subtraction-atom $space_val_1 $space_val_2))
    )
        ((size-atom $net) $net)
        

    )
)

(: compareSpaceToList (-> hyperon::space::DynSpace Expression Expression))
(= (compareSpaceToList $space $list)
	(let* (
		($space_val (collapse (get-atoms $space)))
		($net (subtraction-atom $space_val $list))
		)
		((size-atom $net) $net)))
;; One option here could be to wrap the timer function
;; But do the logic using the meTTa language. 

;; (= (getTV (constructor (STV $x $y))) (STV $x $y))
;; (: monitorChanges (-> hyperon::space::DynSpace Expression Expression))

(: cogTvMean (-> Expression Number))
(= (cogTvMean (STV $x $y)) (/ (+ $x $y) 2))
(: detectChangesHelper (-> Expression Expression Number Expression Expression))
(= (detectChangesHelper $time $previous_times $delta $accum)
	(if (== $previous_times ())
	  	$accum
		(let* (
		       (($head $tail) (decons-atom $previous_times))
		       ($timeTv (extractTvFromRule $time))
		       ($latestTv (extractTvFromRule $head))
				($prevTvMean (cogTvMean $timeTv))
				($latestTvMean (cogTvMean $latestTv))
				($diff (- $latestTvMean $prevTvMean))

		)
		  (if (< (abs-math $diff) $delta)
		    (let $accum' (union-atom $accum (($time $head)))
		      (detectChangesHelper $time $tail $delta $accum')
		      )	
		      (detectChangesHelper $time $tail $delta $accum)
		  )
	  )))
;;The following function is written for checking 
;; the state of the atomspace. This is between two consecutive time cycles.
(: detectChanges (-> Expression Expression Number Expression Expression))
(= (detectChanges $prev_times $latest_times $delta $accum)
	(if (or (== $prev_times ()) (== $latest_times ()))
		$accum
		(let* (
		       (($head $tail) (decons-atom $latest_times))
			($accum' (detectChangesHelper $head $prev_times $delta $accum))
		)
		  (detectChanges $prev_times $tail $delta $accum')
		)
		
	)
)
;; This function implements the monitor Changes agent based on helper functions
(: monitorChanges (-> hyperon::space::DynSpace Expression))
(= (monitorChanges $space)
	(let* (
		($latestTimes (query $space $maxCycle));; This query is a place holder
		($previousTimes (query $space (- $maxCycle 1)))
		($changesSpace (detectChanges $previousTimes $latestTimes 0.1 ()))
		($diffResult (symmetricDifference $latestTimes $previousTimes))
		($_ (record-changes-with-tv $space $changesSpace))
		($_ (record-changes-with-arg $space $diffResult))

	)
		()

	)

)