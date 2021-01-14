set PROJECT_NAME ProjectCPU
set SOURCE_FILES {projectCPU2020.v blram.v}
if {  [ file exists $PROJECT_NAME.xise ] } {
	file delete $PROJECT_NAME.xise
	file delete $PROJECT_NAME.gise
}

project new $PROJECT_NAME.xise
project set family Spartan3E
project set device xc3s100e
project set package cp132
project set speed -4

# add all the source HDLs and ucf
foreach filename $SOURCE_FILES {
    xfile add $filename
}
# get top
set top [project get top]
# get project properties available
#set props2 [project properties]
#puts "Project Properties for top-level module $top" $props2
# do synthesis
process run "Synthesize - XST" 
