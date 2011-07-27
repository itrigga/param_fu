# allow this to be used outside of full Rails init
this_dir =  File.dirname(__FILE__)
$: << this_dir unless $:.include?(this_dir)

require 'trigga/param_fu'