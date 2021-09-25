do-many input [input ...]
           -h/-help (This Screen)
           -app (app to do many of) (*Mandatory*)
           -path (path to the many files) (*Mandatory*)
           -ext (files extension to look for in the path) (*Mandatory*)
           -extra (command agruments for app besides many file)

     You don't have to use the switches, If you don't order matters

     do-many ripcoder "C:\Videos\" "mkv" "-onlynorm"
                            IS THE SAME AS
     do-many -app ripcoder -path "C:\Videos\" -ext "mkv" -extra "-onlynorm"
