require 'test_helper'

describe WireClient::Converter do
  include WireClient::Converter::InstanceMethods

  describe :convert_text do
    it 'should convert special chars' do
      assert_equal convert_text('10€'), '10E'
      assert_equal convert_text('info@bundesbank.de'), 'info(at)bundesbank.de'
      assert_equal convert_text('abc_def'), 'abc-def'
    end

    it 'should not change allowed special character' do
      assert_equal convert_text('üöäÜÖÄß'), 'üöäÜÖÄß'
      assert_equal convert_text('&*$%'), '&*$%'
    end

    it 'should convert line breaks' do
      assert_equal convert_text("one\ntwo"), 'one two'
      assert_equal convert_text("one\ntwo\n"), 'one two'
      assert_equal convert_text("\none\ntwo\n"), 'one two'
      assert_equal convert_text("one\n\ntwo"), 'one two'
    end

    it 'should convert number' do
      assert_equal convert_text(1234), '1234'
    end

    it 'should remove invalid chars' do
      assert_equal convert_text('"=<>!'), ''
    end

    it 'should not touch valid chars' do
      assert_equal convert_text("abc-ABC-0123- ':?,-(+.)/"),
                   "abc-ABC-0123- ':?,-(+.)/"
    end

    it 'should not touch nil' do
      assert_nil convert_text(nil)
    end
  end

  describe :convert_decimal do
    it "should convert Integer to BigDecimal" do
      assert_equal convert_decimal(42), BigDecimal('42.00')
    end

    it "should convert Float to BigDecimal" do
      assert_equal convert_decimal(42.12), BigDecimal('42.12')
    end

    it 'should round' do
      assert_equal convert_decimal(1.345), BigDecimal('1.35')
    end

    it 'should not touch nil' do
      assert_nil convert_decimal(nil)
    end

    it 'should not convert zero value' do
      assert_nil convert_decimal(0)
    end

    it 'should not convert negative value' do
      assert_nil convert_decimal(-3)
    end

    it 'should not convert invalid value' do
      assert_nil convert_decimal('xyz')
      assert_nil convert_decimal('NaN')
      assert_nil convert_decimal('Infinity')
    end
  end
end
