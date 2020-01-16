
proc create_or_update_build_dir { } {

	global build_dir project_dir abi_dir tool_dir cross_dev_prefix include_dirs
	global cppflags cflags cxxflags ldflags ldlibs project_name

	if {![file exists $build_dir]} {
		file mkdir $build_dir }

	set orig_pwd [pwd]
	cd $build_dir

	set cmd { }
	lappend cmd cmake
	lappend cmd "-DCMAKE_MODULE_PATH=[file join $tool_dir cmake Modules]"
	lappend cmd "-DCMAKE_SYSTEM_NAME=Genode"
	lappend cmd "-DCMAKE_C_COMPILER=${cross_dev_prefix}gcc"
	lappend cmd "-DCMAKE_CXX_COMPILER=${cross_dev_prefix}g++"
	lappend cmd "-DCMAKE_C_FLAGS='$cflags $cppflags'"
	lappend cmd "-DCMAKE_CXX_FLAGS='$cxxflags $cppflags'"
	lappend cmd "-DCMAKE_EXE_LINKER_FLAGS='-nostdlib $ldflags $ldlibs'"


	lappend cmd [file join $project_dir src]

	diag "create build directory via command:" {*}$cmd

	if {[catch {exec -ignorestderr {*}$cmd | sed "s/^/\[$project_name:cmake\] /" >@ stdout} msg]} {
		exit_with_error "build-directory creation via cmake failed:\n" $msg }

	cd $orig_pwd
}


proc build { } {
	global build_dir jobs project_name verbose

	set cmd [list make -C $build_dir "-j$jobs"]

	if {$verbose == 0} {
		lappend cmd "-s" }

	if {[catch {exec -ignorestderr {*}$cmd | sed "s/^/\[$project_name:cmake\] /" >@ stdout} msg]} {
		exit_with_error "build via cmake failed:\n" $msg }
}