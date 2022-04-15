#import the xcodeproj ruby gem
require 'xcodeproj'
min_argc = 4
if ARGV.length < min_argc
	puts "you must input more or equal than #{min_argc} args"
	puts "usage: ruby add-remove-files.rb <xcodeproj path> <group> <add/remove> <files ...>"
	exit 1
end
for arg in ARGV
	puts arg
end
#define the path to your .xcodeproj file
project_path = ARGV[0]
group_name = ARGV[1]
command = ARGV[2]
files_arg = ARGV[3..]

#open the xcode project
project = Xcodeproj::Project.open(project_path)
puts "#{project.groups}"

#find the group on which you want to add the file
group = project.main_group[group_name]
if group == nil
	puts "group: #{group_name} not found"
	exit 2
end

#add the file reference to the projects first target
if command == "add"
	#get the file reference for the file to add
	input_files = []
	for arg in files_arg
		file = group.new_file(arg)
		input_files.push(file)
	end

	main_target = project.targets.first
	main_target.add_file_references(input_files)
elsif command == "remove"
	for arg in files_arg
		file = group.find_file_by_path(arg)
		if file != nil
			file.remove_from_project()
		end
	end
	# there will be increasing references under group named "Recovered References"
	# as we delete source files, this is done by xcode, just clear the group
	# and we cannot refer "Recovered References" with main_group["Recovered References"]
	for g in project.groups
		if g.name == "Recovered References"
			puts "removing references"
			g.remove_from_project()
		end
	end
else
	puts "unknown arg: #{command}"
end

#finally, save the project
project.save
