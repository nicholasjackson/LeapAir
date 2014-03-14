require 'asrake'

current = Dir.pwd

args = ASRake::Mxmlc.new "bin/App.swf"
args.target_player = 11.9
args.source_path << 'src'
args.file_specs = 'src/com/mands/di/LeapTest.as'
args.isAIR = true
args.debug = false

task :build => args do
	cp_u "application.xml", "bin/"	
end

task :run => [:build] do
	flex = ENV["FLEX_HOME"]
	sh "#{flex}/bin/adl -profile extendedDesktop #{current}/bin/application.xml"
end