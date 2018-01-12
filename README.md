# randFreq
Simple tool for estimating frequencies of random variables.  
https://github.com/YujiSODE/randFreq  
>Copyright (c) 2017 Yuji SODE \<yuji.sode@gmail.com\>  
>This software is released under the MIT License.  
>See LICENSE or http://opensource.org/licenses/mit-license.php
______
## 1. Synopsis

**Shell**  
`tclsh randFreq.tcl "X0" ?"X1" ? ... "Xn"??;`  

- `X0`: lists of numerical values e.g., 0.5 0.2 1.0
- `X1` to `Xn`: optional lists of numerical values

**Tcl**  
`::randFreq::getFreq values;`  
It returns estimated frequencies from given data set.
- `$values`: a list of numerical lists e.g., `{{v11 v12 ... v1n} ... {vM1 ... vMm}}`

`::randFreq::outputFreq values ?joinChar?;`  
It outputs estimated frequencies as utf-8 encoded text in the current directory.
- `$values`: a list of numerical lists e.g., `{{v11 v12 ... v1n} ... {vM1 ... vMm}}`
- `$joinChar`: a join character; tab character is default value

`::randFreq::loadFile filePath char ?encoding?;`  
It reads a given file and returns a list of numerical list.
- `$filePath`: filePath of a given file
- `$char`: a character used in order to split loaded data
- `$encoding`: an optional encoding of given file

## 2. Script
It requires Tcl/Tk 8.6+.
- `randFreq.tcl`
