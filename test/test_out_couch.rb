require "fluent/test"
require "fluent/plugin/out_couch"

class CouchOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end
  
  CONFIG = %[
    type couch
    database fluent
  ]

  CONFIG_UPDATE_DOC = %[
    type couch
    database fluent
    doc_key_field key
    update_docs true
  ]

  CONFIG_JSONPATH = %[
    type couch
    database fluent
    doc_key_field key
    doc_key_jsonpath $.nested.key
  ]

  def create_driver(config = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::CouchOutput).configure(config)
  end

  def test_configure
    d = create_driver
    assert_equal('fluent', d.instance.database)
    assert_equal('localhost', d.instance.host)
    assert_equal('5984', d.instance.port)
    assert_equal('http', d.instance.protocol)
    assert_nil(d.instance.refresh_view_index)
    assert_nil(d.instance.user)
    assert_nil(d.instance.password)
    assert_false(d.instance.instance_variable_get(:@update_docs))
    assert_nil(d.instance.doc_key_field)
    assert_nil(d.instance.doc_key_jsonpath)
  end

  def test_write
    d = create_driver
    previous_rows = d.instance.db.all_docs["total_rows"]
    time = Time.now.to_i
    d.emit({"message" => "record"}, time)
    d.run
    rows = d.instance.db.all_docs["total_rows"]
    assert_equal(rows, previous_rows + 1)
  end

  def test_write_update_doc
    d = create_driver(CONFIG_UPDATE_DOC)
    time = Time.now.to_i
    d.emit({"key" => "record-1", "message" => "record"}, time)
    d.run
    previous_rows = d.instance.db.all_docs["total_rows"]
    d.emit({"key" => "record-1", "message" => "record-mod"}, time)
    d.run
    rows = d.instance.db.all_docs["total_rows"]
    record = d.instance.db.get("record-1")
    assert_equal(rows, previous_rows)
    assert_equal("record-mod", record["message"])
  end

  def test_write_doc_key_jsonoath
    d = create_driver(CONFIG_JSONPATH)
    time = Time.now.to_i
    d.emit({"nested" => {"key" => "record-nested", "message" => "record"}}, time)
    d.run
    record = d.instance.db.get("record-nested")
    assert_equal({"key" => "record-nested", "message" => "record"}, record["nested"])
  end
end
