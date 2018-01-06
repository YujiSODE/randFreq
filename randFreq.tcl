#randFreq
#randFreq.tcl
##===================================================================
#	Copyright (c) 2018 Yuji SODE <yuji.sode@gmail.com>
#
#	This software is released under the MIT License.
#	See LICENSE or http://opensource.org/licenses/mit-license.php
##===================================================================
#Simple tool for estimating frequencies of random variables.
#M-set numerical values: {{v11 v12 ... v1N} ... {vM1 ... vMN}}
#available minimum dataset size (M) is 2
#=== Synopsis ===
#** Shell **
#tclsh randFreq.tcl "X0" "X1" ?"Xn"?;
#
# - $X0 and $X1: lists of numerical values e.g., 0.5 0.2 1.0
# - $Xn: an optional list of numerical values
#--------------------------------------------------------------------
#** Tcl **
#1)
#::randFreq::getFreq values;
#It returns estimated frequencies from given data set.
#
# - $values: a list of numerical lists e.g., {{v11 v12 ... v1n} ... {vM1 ... vMm}}
#   available minimum dataset size M is 2
#
#2)
#::randFreq::outputFreq values ?joinChar?;
#It outputs estimated frequencies as utf-8 encoded text in the current directory.
#
# - $values: a list of numerical lists e.g., {{v11 v12 ... v1n} ... {vM1 ... vMm}}
#   available minimum dataset size M is 2
# - $joinChar: a join character; tab character is default value
##===================================================================
set auto_noexec 1;
package require Tcl 8.6;
#=== <namespace: randFreq> ===
namespace eval ::randFreq {
	#****** variables ******
	# - $dv: step value
	# - $classV: class values
	# - $freq: an array that has frequencies list
	# - $result: a list of results
	variable dv 0.0;
	variable classV {};
	variable freq;array set freq {};
	variable result {};
	#****** Procedures ******
	#procedure that sets class values
	proc setClassValue {min step max} {
		# - $min,$step and $max are numerical values
		variable dv;variable classV;
		set classV {};
		set dv [format %.4f [expr {$step!=0.0?$step:1.0}]];
		set i [format {%.4f} $min];
		while {$i<$max} {
			lappend classV [format {%.4f} $i];
			set i [format {%.4f} [expr {$i+$dv}]];
		};
		lappend classV [format {%.4f} $max];
		return [set classV [lsort -real -increasing $classV]];
	};
	#procedure that classifies a given value if the value is in the preset range
	proc classify {v} {
		# - $v is a numerical value
		variable classV;variable dv;
		set i 0;
		#N is list size of $classV
		set N [llength $classV];
		foreach e $classV {
			if {!($v<$e)&&($v<($e+$dv))} {
				return $e;
			} else {
				if {$i<($N-1)} {continue;} else {return $v;};
			};
			incr i 1;
		};
	};
	#procedure that estimates average and standard deviation from given values list
	proc stat {name v} {
		# - $name: a name or value of a given variable
		# - $v: a list of numerical values; minimum list size is 2
		#avg and std is average and standard deviation
		set avg 0.0;
		set std 0.0;
		#N is list size of given list
		set N [llength $v];
		#--- average ---
		foreach e $v {
			set avg [expr {$avg+$e}];
		};
		set avg [expr {$avg/$N}];
		#--- standard deviation ---
		foreach e $v {
			set std [expr {$std+($e-$avg)**2}];
		};
		set std [expr {sqrt($std/($N-1))}];
		return [list $name $avg $std];
	};
	#procedure that estimates frequencies from given data set
	proc getFreq {values} {
		# - $values: a list of numerical lists e.g., {{v11 v12 ... v1n} ... {vM1 ... vMm}}
		#   available minimum dataset size M is 2
#== To do ==
#if {[llength $values]<1|| ...} {return -code error {dataset size is too small};};
		puts stdout {Please input data range (minimum step maximum)?};
		#range is data range
		set range [gets stdin];
		if {[llength $range]!=3} {
			::randFreq::setClassValue 0.0 0.2 1.0;
		} else {
			::randFreq::setClassValue [lindex $range 0] [lindex $range 1] [lindex $range 2];
		};
		variable classV;variable dv;variable freq;variable result;
		#min and max are the minimum value and the maximum value in $classV
		set min [lindex $classV 0];
		set max [lindex $classV end];
		#data is a list of classified values
		set data {};
		#initializing freq and result
		array unset freq;
		set result {};
		lappend result "[llength $values]_datasets";
		lappend result {variables averages standard_deviations};
		foreach e $classV {set freq($e) {};};
		#classifying values that belong to the range between $max and $min
		foreach l $values {
			#loop for each data set
			lappend data [lmap e $l {if {$e<$min||$e>$max} {continue;};::randFreq::classify $e;}];
		};
		foreach e $classV {
			set freq($e) [lmap l $data {set f0 [lsearch -all -exact $l $e];list [expr {[lindex $f0 0]<0?0:[llength $f0]}];}];
			lappend result [::randFreq::stat $e $freq($e)];
		};
		#parray freq;
		return $result;
	};
	#procedure that outputs result as utf-8 encoded text in the current directory
	proc outputFreq {values {joinChar \t}} {
		# - $values: a list of numerical lists e.g., {{v11 v12 ... v1n} ... {vM1 ... vMm}}
		#   available minimum dataset size M is 2
		# - $joinChar: a join character; tab character is default value
		set R [::randFreq::getFreq $values];
		set C [open "[clock seconds]dataFreq.txt" w];
		fconfigure $C -encoding utf-8;
		foreach e $R {
			puts -nonewline $C "[join $e $joinChar]\n";
		};
		puts stdout $R;
		close $C;unset C R;
	};
};
#=== shell ===
if {$argc>0} {
	foreach e [::randFreq::getFreq $argv] {
		puts stdout "$e\n";
	};
};
