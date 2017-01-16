require "fluent/test"
require "fluent/plugin/out_couch"

class CouchOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  DATABASE_NAME = "fluent_test"
  COUCHHOST = ENV['COUCHHOST'] || "http://127.0.0.1:5984"

  CONFIG = %[
    database #{DATABASE_NAME}
  ]

  CONFIG_UPDATE_DOC = %[
    database #{DATABASE_NAME}
    doc_key_field key
    update_docs true
  ]

  CONFIG_JSONPATH = %[
    database #{DATABASE_NAME}
    doc_key_field key
    doc_key_jsonpath $.nested.key
  ]

  CONFIG_DESIGN = %[
    database #{DATABASE_NAME}
    doc_key_field key
    refresh_view_index d01
  ]

  def prepare_db
    @cr = CouchRest.new(COUCHHOST)
    @db = @cr.database(DATABASE_NAME)
    @db.delete! rescue nil
    @cr.create_db(DATABASE_NAME)
  end

  def create_driver(config = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::CouchOutput).configure(config)
  end

  def test_configure
    d = create_driver
    assert_equal(DATABASE_NAME, d.instance.database)
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

  class WriteTest < self
    def setup
      @d = create_driver
      prepare_db
    end

    def teardown
      @db.delete!
    end

    def test_write
      previous_rows = @d.instance.db.all_docs["total_rows"]
      time = Time.now.to_i
      @d.emit({"message" => "record"}, time)
      @d.run
      rows = @d.instance.db.all_docs["total_rows"]
      assert_equal(rows, previous_rows + 1)
    end
  end

  class WriteWithUpdateDocTest < self
    def setup
      @d = create_driver(CONFIG_UPDATE_DOC)
      prepare_db
    end

    def teardown
      @db.delete!
    end

    def test_write
      time = Time.now.to_i
      @d.emit({"key" => "record-1", "message" => "record"}, time)
      @d.run
      previous_rows = @d.instance.db.all_docs["total_rows"]
      @d.emit({"key" => "record-1", "message" => "record-mod"}, time)
      @d.run
      rows = @d.instance.db.all_docs["total_rows"]
      record = @d.instance.db.get("record-1")
      assert_equal(rows, previous_rows)
      assert_equal("record-mod", record["message"])
    end
  end

  class WriteWithJsonpathTest < self
    def setup
      @d = create_driver(CONFIG_JSONPATH)
      prepare_db
    end

    def teardown
      @db.delete!
    end

    def test_write
      time = Time.now.to_i
      @d.emit({"nested" => {"key" => "record-nested", "message" => "record"}}, time)
      @d.run
      record = @d.instance.db.get("record-nested")
      assert_equal({"key" => "record-nested", "message" => "record"}, record["nested"])
    end
  end

  class WriteWithDesignTest < self
    def setup
      @d = create_driver(CONFIG_DESIGN)
      prepare_db
      setup_design
    end

    def setup_design
      message_by_key = {
        :map => 'function(doc) {
          if (doc._id == "record-design") {
            emit(doc._id, doc.message);
          }
        }',
      }
      @db.delete_doc db.get("_design/d01") rescue nil
      @db.save_doc({
        "_id" => "_design/d01",
        :views => {
          :messages => message_by_key
        }
      })
    end

    def teardown
      @db.delete!
    end

    def test_write
      time = Time.now.to_i
      @d.emit({"key" => "record-design", "message" => "record"}, time)
      @d.run
      record = @d.instance.db.get("record-design")
      assert_equal("record", record["message"])
    end
  end
end
