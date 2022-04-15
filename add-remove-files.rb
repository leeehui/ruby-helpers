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
group = ARGV[1]
command = ARGV[2]

#open the xcode project
project = Xcodeproj::Project.open(project_path)

#find the group on which you want to add the file
group = project.main_group[group]

#get the file reference for the file to add
input_files = []
for arg in ARGV[2..]
	file = group.new_file(arg)
	input_files.push(file)
end

#add the file reference to the projects first target
if command == "add"
	main_target = project.targets.first
	main_target.add_file_references(input_files)
elsif command == "remove"
	input_files.each{|file|file.remove_from_project()}
else
	puts "unknown arg: #{command}"
end

#finally, save the project
project.save
