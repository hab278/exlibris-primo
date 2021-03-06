require 'test_helper'

class RecordTest < Test::Unit::TestCase
  
  SEAR_NS = {'sear' => 'http://www.exlibrisgroup.com/xsd/jaguar/search'}
  
  class SubRecord < Exlibris::Primo::Record
    def initialize(parameters={})
      super(parameters)
    end
  end

  def setup
    @record_definition = YAML.load( %{
        base_url: http://bobcat.library.nyu.edu
        resolver_base_url: https://getit.library.nyu.edu/resolve
        vid: NYU
        institution: NYU
        record_id: nyu_aleph000062856 })
    @base_url = @record_definition["base_url"]
    @resolver_base_url = @record_definition["resolver_base_url"]
    @vid = @record_definition["vid"]
    @institution = @record_definition["institution"]
    @valid_record_id = @record_definition["record_id"]
    @invalid_record_id = "INVALID_RECORD"
    @setup_args = { 
      :base_url => @base_url, 
      :resolver_base_url => @resolver_base_url, 
      :vid => @vid, 
      :institution => @institution, 
      :record_id => @valid_record_id }
  end
  
  def testnew
    record = nil
    VCR.use_cassette('record valid record') do
      assert_nothing_raised(){ record = Exlibris::Primo::Record.new(@setup_args) }
      assert_not_nil(record)
      assert_not_nil(record.instance_variable_get(:@record_id))
      assert_not_nil(record.instance_variable_get(:@type))
      assert_not_nil(record.instance_variable_get(:@title))
      assert_not_nil(record.instance_variable_get(:@url))
      assert_not_nil(record.instance_variable_get(:@openurl))
      assert_not_nil(record.instance_variable_get(:@creator))
      assert_not_nil(record.instance_variable_get(:@raw_xml))  
    end
    assert_raise(ArgumentError){ Exlibris::Primo::Record.new(@setup_args.merge({:base_url => nil})) }
    assert_raise(ArgumentError){ Exlibris::Primo::Record.new(@setup_args.merge({:institution => nil})) }
    assert_raise(ArgumentError){ Exlibris::Primo::Record.new(@setup_args.merge({:vid => nil})) }
    assert_raise(ArgumentError){ Exlibris::Primo::Record.new(@setup_args.merge({:record_id => nil})) }
    VCR.use_cassette('record invalid record') do
      assert_raise(RuntimeError){ Exlibris::Primo::Record.new(@setup_args.merge({:record_id => @invalid_record_id})) }
    end
  end

  def testto_hash_function
    VCR.use_cassette('record valid record') do
      record = Exlibris::Primo::Record.new(@setup_args)
      assert((record.to_h.is_a? Hash), "#{record.class} was expected to be a Hash, was #{record.to_h.class}")
      assert(record.to_h["format"], "BOOK")
      assert(record.to_h["title"], "Travels with my aunt")
      assert(record.to_h["author"], "Graham  Greene  1904-1991.")
      assert(record.to_h["url"], "#{@base_url}/primo_library/libweb/action/dlDisplay.do?dym=false&onCampus=false&docId=nyu_aleph000062856&institution=#{@institution}&vid=#{@vid}")
    end
  end

  def testto_json_function
    VCR.use_cassette('record valid record') do
      record = Exlibris::Primo::Record.new(@setup_args)
      assert((record.to_json.is_a? String), "#{record.class} was expected to be a String, was #{record.to_json.class}")
      control_hash = JSON.parse(record.to_json)["record"]["control"]
      assert_equal("000062856", control_hash["sourcerecordid"])
      assert_equal("nyu_aleph", control_hash["sourceid"])
      assert_equal("nyu_aleph000062856", control_hash["recordid"])
      assert_equal("NYU01", control_hash["originalsourceid"])
      assert_equal("NYU01000062856", control_hash["ilsapiid"])
      assert_equal("MARC21", control_hash["sourceformat"])
      assert_equal("Aleph", control_hash["sourcesystem"])
    end
  end

  def testsub_class
    record = nil
    VCR.use_cassette('record sub record') do
      assert_nothing_raised(){ record = SubRecord.new(@setup_args) }    
      assert_not_nil(record)
      assert_raise(ArgumentError){ record = SubRecord.new() }
    end
  end

  def testraw_xml
    VCR.use_cassette('record') do
      record = Exlibris::Primo::Record.new(@setup_args)
      raw_xml = record.instance_variable_get(:@raw_xml)
      assert_not_nil(raw_xml)  
      assert_instance_of(String, raw_xml)
      doc = nil
      assert_nothing_raised(){ doc = Nokogiri::XML.parse(raw_xml) }
      assert_not_nil(doc)
      assert(doc.xpath("//record", doc.namespaces).size > 0)
    end
  end
end