require 'rake/clean'

#remove these when cleaning
CLEAN.include('*.o')
#remove these when clobbering
#clobbering includes cleaning
CLOBBER.include('parser','parser.obj', 'parser.sym')

#default task when just running 'rake'
task :default => 'c:run'

namespace :c do

  src = FileList['*.c']
  obj = src.ext('o')

  #to make any .o file, you need it's .c file, and then compile
  rule '.o' => '.c' do |t|
    sh "gcc -c -o #{t.name} #{t.source}"
  end

  #to make parser, you need all the obj files, then link
  file "parser" => obj do
    sh "gcc -o parser #{obj}"
  end

  desc "build parser.c into parser.o"
  task :compile => 'parser.o'

  desc "link parser.o into parser"
  task :link => 'parser' do
  end

  desc "run parser"
  task :run => "parser" do
    sh "./parser"
  end
end

namespace :asm do

  src = FileList['*.asm']
  obj = src.ext('obj')
  sym = src.ext('sym')

  #to make any obj file, you need to lc3as its .asm
  rule '.obj' => '.asm' do |t|
    sh "lc3as #{t.source}"
  end

  #to make any sym file, you need to lc3as its .asm
  #kinda redundant since lc3as creates both .obj and .sym, but just in case one
  #of them gets deleted, we need BOTH rules
  rule '.sym' => '.asm' do |t|
    sh "lc3as #{t.source}"
  end

  desc "assemble parser"
  task :assemble => obj + sym

  desc "run with simp"
  task :simp => obj + sym do
    sh "simp #{obj}"
  end

  desc "run with complx"
  task :complx => obj + sym do
    sh "complx #{obj}"
  end
end
