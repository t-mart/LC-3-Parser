require 'rubygems'
gem 'minitest' #ensure we're using the gem, not the builtin
require 'minitest/autorun'

class TestParser < MiniTest::Unit::TestCase
  def asm_parse form
    #substitute form into parser.asm's TEST_FORM string var
    #save this file as parser_test.asm
    #lc3as parser_test.asm
    #simp -f parser_test.obj
    #search output for validity ("VALID" | "INVALID")
    #return valid boolean
    

    parser = File.new(@parser_path, "r")
    code = parser.read
    parser.close

    code.sub! "TEST_FORM .STRINGZ \"\"", "TEST_FORM .STRINGZ \"#{form}\""

    test_parser = File.new(@test_parser_path, "w")
    test_parser.write(code)
    test_parser.close

    `lc3as #{@test_parser_path}`

    output = `simp -f #{@test_parser_obj_path}`

    #because searching for valid will be true for both cases
    return !output.include?('Invalid')
  end

  def c_parse form
    return system "./parser #{form}"
  end

  def setup
    #TODO
    #make sure the code compiles correctly
    #fail if not
    #also, make sure failure in setup actuall works...might need to be in a
    #test only
    
    @parser_path = "parser.asm"
    @test_parser_path = "parser_test.asm"
    @test_parser_obj_path = File.basename(@test_parser_path, File.extname(@test_parser_path)) + ".obj"
  end

  def teardown
    #remove all test files
    `rm #{File.basename(@test_parser_path, File.extname(@test_parser_path))}.*` 
  end
  
  def test_bad_form_all_binary_operators
    form = 'AAAA'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_not_form
    form = 'Nq'
    assert_equal c_parse(form), asm_parse(form)
  end

  #sloppy, i know, to just label test_number, but there should be an easier way
  #to do this....i prolly just don't know it yet
  def test_0
    form = 'a'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_1
    form = 'b'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_2
    form = 'Nd'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_3
    form = 'Bxy'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_4
    form = 'CNdApq'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_5
    form = 'DBpcCrNt'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_6
    form = 'B1y'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_7
    form = '!'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_8
    form = 'NNNNNN'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_9
    form = 'B a'
    assert_equal c_parse(form), asm_parse(form)
  end

  def test_10
    form = 'hello world!'
    assert_equal c_parse(form), asm_parse(form)
  end
end
